using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Projector))]
[ExecuteInEditMode]
public class ProjectorShadowRender : MonoBehaviour {


	private RenderTexture shadowTexture;

	private Camera shadowCamera;

	private Projector projector;

	public int textureWidth = 128;

	public int textureHeight = 128;

	private bool isInitialized = false;


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
		//		Shader.SetGlobalTexture
		//		shadowCamera.SetReplacementShader(drawShader,"RenderType");
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
//		shadowCamera.cullingMask = 0;

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

	void OnDestroy(){
		isInitialized = false;
	}

	void OnPreRender(){
		shadowTexture.DiscardContents();

	}

	void OnPostRender(){
		//		Graphics.SetRenderTarget(renderTexture);
		//		projector.material.SetTexture("_RenderTexture",renderTexture);
//		projector.material.SetTexture ("_ShadowTex", shadowTexture);
	}

//	void LateUpdate(){
//		buffer.DrawRenderer (targetRenderer,material);
//	}

//	void OnEnable(){
//		DetachCommandBuffer ();
//		AttachCommandBuffer ();
//	}
//
//
//	void OnDisable(){
//		DetachCommandBuffer ();
//	}
//
//	void AttachCommandBuffer(){ 
//		buffer = new CommandBuffer ();
//		m_camera.AddCommandBuffer (CameraEvent.BeforeImageEffectsOpaque,buffer);	
//	}
//
//	void DetachCommandBuffer(){
//		if (buffer == null)
//			return;
//		m_camera.RemoveCommandBuffer (CameraEvent.BeforeImageEffectsOpaque, buffer);
//	}
//



}
