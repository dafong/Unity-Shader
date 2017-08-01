using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(ProjectorShadowRender))]
[ExecuteInEditMode]
public class DrawWithTarget : MonoBehaviour {

	[System.Serializable]
	public struct ReplaceShader {
		public string renderType;
		public Shader shader;
	}

	public Transform target;

	public Material shadowMaterial;

	private ProjectorShadowRender shadowRender;

	private CommandBuffer cmdBuffer;

	private Camera shadowCamera;

	public bool renderChildren;

	private LayerMask layerMask;

	private ReplaceShader[] replacementShaders;

	private bool isCommandBufferDirty;

	private Dictionary<Material, Material> replacedMaterialCache;
	// public properties
	public Transform Target{
		get { return target; }
		set {
			if (target != value) {
				target = value;
				SetCommandBufferDirty();
			}
		}
	}

	public bool RenderChildren{
		get { return renderChildren; }
		set {
			if (renderChildren != value) {
				renderChildren = value;
				SetCommandBufferDirty();
			}
		}
	}

	public LayerMask LayerMask{
		get { return layerMask; }
		set {
			if (layerMask != value) {
				layerMask = value;
				if (renderChildren) {
					SetCommandBufferDirty();
				}
			}
		}
	}

	public Material ShadowMaterial{
		get { return shadowMaterial; }
		set {
			if (shadowMaterial != value) {
				shadowMaterial = value;
				SetCommandBufferDirty();
			}
		}
	}

	public ReplaceShader[] ReplacementShaders{
		get { return replacementShaders; }
		set {
			replacementShaders = value;
			SetCommandBufferDirty();
		}
	}

	public void SetCommandBufferDirty(){
		isCommandBufferDirty = true;
	}


	void Start(){
		shadowRender = GetComponent<ProjectorShadowRender> ();
		shadowCamera = shadowRender.ShadowCamera;
		CreateCommandBuffer ();
	}
	 
	void CreateCommandBuffer(){
		cmdBuffer = new CommandBuffer();
		AttachCommandBuffer ();
	}

	void AttachCommandBuffer(){
		DetachCommandBuffer ();
		if (cmdBuffer == null || shadowCamera == null)
			return;
		shadowCamera.AddCommandBuffer (CameraEvent.BeforeImageEffectsOpaque, cmdBuffer);
	}
	 
	void DetachCommandBuffer(){
		if (cmdBuffer == null || shadowCamera == null)
			return;
		shadowCamera.RemoveCommandBuffer (CameraEvent.BeforeImageEffectsOpaque, cmdBuffer);
	}

	void OnValidate(){
		if (cmdBuffer != null) {
			UpdateCommandBuffer();
		}
	}

	void OnEnable(){
		if (cmdBuffer == null) {
			CreateCommandBuffer();
		}
		AttachCommandBuffer ();
	}

	void OnDisable(){
		DetachCommandBuffer ();
	}

	void OnPreCull(){
		if (isCommandBufferDirty) {
			UpdateCommandBuffer();
		}
	}

	public void UpdateCommandBuffer(){
		if (target == null) {
			return;
		}

		cmdBuffer.Clear();
		int materialCount = replacementShaders == null ? 0 : replacementShaders.Length;
		if (renderChildren) {
			Renderer[] renderers = target.gameObject.GetComponentsInChildren<Renderer>();
			for (int i = -1; i < materialCount; ++i) {
				foreach (Renderer renderer in renderers) {
					if ((layerMask & (1 << renderer.gameObject.layer)) != 0) {
						AddDrawCommand(renderer, i);
					}
				}
			}
		}
		else {
			Renderer renderer = target.gameObject.GetComponent<Renderer>();
			if (renderer != null) {
				for (int i = -1; i < materialCount; ++i) {
					AddDrawCommand(renderer, i);
				}
			}

		}
		isCommandBufferDirty = false;
	}

	void AddDrawCommand(Renderer renderer, int renderTypeIndex){
		
		Material[] materials = renderer.sharedMaterials;
		for (int i = 0; i < materials.Length; ++i) {
			Material m = materials[i];
			if (m == null) {
				Debug.LogWarning("The target object has a null material!", renderer);
				continue;
			}
			string renderType = m.GetTag("RenderType", false);
			if (m.shader.name == "Standard") {
				if (m.IsKeywordEnabled("_ALPHABLEND_ON") || m.IsKeywordEnabled("_ALPHATEST_ON") || m.IsKeywordEnabled("_ALPHAPREMULTIPLY_ON")) {
					renderType = "Transparent";
				}
			}

			int foundIndex = -1;
			if (replacementShaders != null && !string.IsNullOrEmpty(renderType)) {
				for (int index = 0; index < replacementShaders.Length; ++index) {
					if (renderType == replacementShaders[index].renderType) {
						foundIndex = index;
						Shader shader = replacementShaders[index].shader;
						if (renderTypeIndex == index && shader != null) {
							if (replacedMaterialCache == null) {
								replacedMaterialCache = new Dictionary<Material, Material>();
							}
							Material replacedMaterial;
							if (!replacedMaterialCache.TryGetValue(m, out replacedMaterial)) {
								replacedMaterial = new Material(m);
								replacedMaterial.shader = shader;
								replacedMaterial.hideFlags = HideFlags.HideAndDontSave;
								replacedMaterialCache.Add(m, replacedMaterial);
							}
							else {
								replacedMaterial.CopyPropertiesFromMaterial(m);
								replacedMaterial.shader = shader;
							}
							cmdBuffer.DrawRenderer(renderer, replacedMaterial, i);
						}
						break;
					}
				}
			}
			if (foundIndex == -1 && renderTypeIndex == -1) {
				cmdBuffer.DrawRenderer(renderer, shadowMaterial, i);
			}
		}
	}

	void OnDestroy(){
		if (cmdBuffer != null) {
			cmdBuffer.Dispose();
			cmdBuffer = null;
		}
	}

}
