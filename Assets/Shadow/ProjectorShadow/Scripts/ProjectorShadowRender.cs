using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Projector))]
[ExecuteInEditMode]
public class ProjectorShadowRender : MonoBehaviour {

	public enum SuperSample {
		x1  = 1,
		x4  = 2,
		x16 = 4,
	}

	public enum MultiSample {
		x1 = 1,
		x2 = 2,
		x4 = 4,
		x8 = 8,
	}

	public enum BlurFilter {
		Uniform = 0,
		Gaussian,
	}

	private RenderTexture shadowTexture;

	private Camera shadowCamera;

	private Projector projector;

	[SerializeField]
	[Tooltip("antialiasing use super sampling")]
	private SuperSample superSampling = SuperSample.x1;

	[SerializeField]
	[Tooltip("antialiasing use muti sampling")]
	private MultiSample mutiSampling = MultiSample.x1;

	[SerializeField]
	[Tooltip("blur mode")]
	public BlurFilter blurFilter = BlurFilter.Uniform;

	[SerializeField]
	[Tooltip("high blur level make shadow more blurry")]
	private int blurLevel = 0;

	[SerializeField]
	[Tooltip("blur filter size")]
	private float blurSize = 0;

	[SerializeField]
	private Color shadowColor = Color.black;
	[SerializeField]
	private int textureWidth = 128;
	[SerializeField]
	private int textureHeight = 128;
	[SerializeField]
	private Material eraseShadowMat;
	[SerializeField]
	private Material downSampleMat;
	[SerializeField]
	private Material blurMat;

	private bool isInitialized = false;

	private int s_Offset;


	public RenderTexture ShadowTexture {
		get { return shadowTexture; }

	}

	public Camera ShadowCamera{
		get{ return shadowCamera; }
	}

	public bool IsInitialized{
		get { return isInitialized; }
	}



	public int TextureWidth{
		get { return textureWidth; }
		set {
			if (textureWidth != value) {
				textureWidth = value;
//				SetTexturePropertyDirty();
			}
		}
	}

	public int TextureHeight{
		get { return textureHeight; }
		set {
			if (textureHeight != value) {
				textureHeight = value;
//				SetTexturePropertyDirty();
			}
		}
	}
	 
	void Awake(){
		Initialize (); 
		InitShaderProperties ();
		//		Shader.SetGlobalTexture
		//		shadowCamera.SetReplacementShader(drawShader,"RenderType");
	}

	void InitShaderProperties(){
		s_Offset = Shader.PropertyToID("_Offset");
	}
	 
	//when script is loaded or a value is changed in the inspector
	void OnValidate(){
		if (!isInitialized)
			return;
		CreateRenderTexture ();
	}
		
	void Initialize(){
		if (isInitialized)
			return;
		projector = GetComponent<Projector> ();
		InitCamera();
		CreateRenderTexture ();
		isInitialized = true;
	}
	 
	void InitCamera(){
		if (shadowCamera == null) {
			shadowCamera = gameObject.GetComponent<Camera> ();
			if (shadowCamera == null) {
				shadowCamera = gameObject.AddComponent<Camera> ();
			}
		} 
		SetupCamera ();
	}

	void SetupCamera(){
		shadowCamera.RemoveAllCommandBuffers ();
		shadowCamera.depth = -100;
		shadowCamera.cullingMask = 0;

		shadowCamera.clearFlags = CameraClearFlags.SolidColor;
		shadowCamera.backgroundColor = new Color(1,1,1,0);
		shadowCamera.useOcclusionCulling = false;
		shadowCamera.renderingPath = RenderingPath.Forward;
		shadowCamera.nearClipPlane = 0.01f;
		shadowCamera.hideFlags = HideFlags.HideInInspector;
		#if UNITY_5_6_OR_NEWER
		shadowCamera.forceIntoRenderTexture = true;
		#endif
		shadowCamera.enabled = true;
	}
	 
	void CreateRenderTexture(){

		if (textureWidth <= 0 || textureHeight <= 0 ) {
			return;
		} 

		RenderTextureFormat textureFormat = RenderTextureFormat.ARGB32;

		if (shadowTexture != null) {
			if (shadowCamera != null) {
				shadowCamera.targetTexture = null;
			}
			DestroyImmediate(shadowTexture);
		}
		shadowTexture  = new RenderTexture(textureWidth, textureHeight, 0, textureFormat, RenderTextureReadWrite.Linear);
		shadowTexture.wrapMode = TextureWrapMode.Clamp;
		shadowTexture.Create ();
		if (shadowCamera != null) {
			shadowCamera.targetTexture = shadowTexture;
		}

		if(projector.material != null){
			projector.material.SetTexture ("_ShadowTex", shadowTexture);
		}

	}

	bool NeedTemporaryTexture{
		get { 
			return superSampling != SuperSample.x1 
				|| mutiSampling  != MultiSample.x1
				|| IsShadowHasColor;
		}
	}

	bool IsShadowHasColor{
		get { 
			return shadowColor.a != 1 || (shadowColor.r + shadowColor.g + shadowColor.b) != 0;
		}
	}

	void OnEnable(){
		if (shadowCamera != null) {
			shadowCamera.enabled = true;
		}
	}

	void OnDisable(){
		if (shadowCamera != null) {
			shadowCamera.enabled = false;
		}
	}

	void OnPreCull(){
		//before camera cull the scene we fixed the camera's parameter same as projector
		FixCamera ();
		projector.material.SetTexture ("_ShadowTex", shadowTexture);
	}


	void FixCamera(){
		shadowCamera.orthographic = projector.orthographic;
		shadowCamera.orthographicSize = projector.orthographicSize;
		shadowCamera.fieldOfView  = projector.fieldOfView;
		shadowCamera.aspect = projector.aspectRatio;
		shadowCamera.farClipPlane = projector.farClipPlane;
	}

	void EraseShadowOnBoarder(int w, int h){
		float x = 1.0f - 1.0f/w;
		float y = 1.0f - 1.0f/h;
		eraseShadowMat.SetPass(0);
		GL.Begin(GL.LINES);
		GL.Vertex3(-x,-y,0);
		GL.Vertex3( x,-y,0);
		GL.Vertex3( x,-y,0);
		GL.Vertex3( x, y,0);
		GL.Vertex3( x, y,0);
		GL.Vertex3(-x, y,0);
		GL.Vertex3(-x, y,0);
		GL.Vertex3(-x,-y,0);
		GL.End();
	}

	void OnDestroy(){
		isInitialized = false;
	}

	void OnPreRender(){
		shadowTexture.DiscardContents();
		if (NeedTemporaryTexture) {
			//if need temporary texture we must render the camera to temporary texture 
			RenderTexture rt = RenderTexture.GetTemporary (
				textureWidth  * (int)superSampling,
				textureHeight * (int)superSampling,
				0,
				shadowTexture.format, 
				RenderTextureReadWrite.Linear,
				(int)mutiSampling);
			shadowCamera.targetTexture = rt;
		}

	}

	void OnPostRender(){
		RenderTexture src = shadowCamera.targetTexture;
		RenderTexture dst = shadowTexture;
		if (NeedTemporaryTexture) {
			//camera.targetTexture is temporary texture
			if (blurLevel > 0) {
				//if need blur we blit src to another temporary texture
				dst = RenderTexture.GetTemporary (
					textureWidth,
					textureHeight,
					0,
					shadowTexture.format,
					RenderTextureReadWrite.Linear);
				dst.filterMode = FilterMode.Bilinear;
			}
			downSampleMat.color = shadowColor;
			int pass = 2;
			Graphics.Blit (src, dst, downSampleMat, IsShadowHasColor ? pass + 1 : pass );
			//here the src is temporary so must be release
			shadowCamera.targetTexture = shadowTexture;
			RenderTexture.ReleaseTemporary (src);
			src = dst;
		}

		dst = shadowTexture;
		if (blurLevel > 0) {
			if (blurLevel > 1) {
				dst = RenderTexture.GetTemporary (
					textureWidth,
					textureHeight,
					0,
					shadowTexture.format,
					RenderTextureReadWrite.Linear);
				dst.filterMode = FilterMode.Bilinear;
				dst.wrapMode   = TextureWrapMode.Clamp;
			}
				
			float offsetH = blurSize / textureWidth;
			float offsetV = blurSize / textureHeight;
			blurMat.SetVector (s_Offset, new Vector4 (offsetH,offsetV,0,0));

			for (int i = 0; i < blurLevel - 1; i++) {
				Graphics.Blit (src, dst, blurMat);
				src.DiscardContents ();
				RenderTexture temp = src;
				src = dst;
				dst = temp;
			}
			if (dst != shadowTexture) {
				RenderTexture.ReleaseTemporary (dst);
				dst = shadowTexture;
			}
			Graphics.Blit (src, dst, blurMat);
			RenderTexture.ReleaseTemporary (src); 

		}

		Graphics.SetRenderTarget(shadowTexture);
		EraseShadowOnBoarder (textureWidth, textureHeight);
	}


}
