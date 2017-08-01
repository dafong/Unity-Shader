using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(ProjectorShadowRender))]
[ExecuteInEditMode]
public class DrawWithTag : MonoBehaviour {
	
	private ProjectorShadowRender shadowRender;

	public Shader drawShader;

	void Start(){
		shadowRender = GetComponent<ProjectorShadowRender> ();
		AttachReplacementShader ();
	}

	void AttachReplacementShader(){
		if (drawShader == null || shadowRender == null || !shadowRender.IsInitialized)
			return;
		DetachReplacementShader();
		shadowRender.ShadowCamera.SetReplacementShader (drawShader, "RenderType");
	} 
	 
	void DetachReplacementShader(){
		shadowRender.ShadowCamera.ResetReplacementShader();
	}

	void OnValidate(){
		AttachReplacementShader ();
	}

	void OnEnable(){
		AttachReplacementShader ();
	}

	void OnDisable(){
		DetachReplacementShader ();
	}

	void Destroy(){
		if(shadowRender != null && shadowRender.IsInitialized)
			shadowRender.ShadowCamera.ResetReplacementShader();
	}
}
