using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class STRender : MonoBehaviour {

	public RenderTexture renderTexture;

	public Camera m_camera;

	private CommandBuffer buffer;

	public Renderer targetRenderer;

	public Shader drawShader;

	private Material material;

	private Projector projector;

	void Awake(){
		material = new Material (drawShader);
		projector = GetComponent<Projector> ();
		m_camera.SetReplacementShader(drawShader,"RenderType");
	}

	void OnPreRender(){
		renderTexture.DiscardContents ();
	}

	void LateUpdate(){
//		buffer.DrawRenderer (targetRenderer,material);
	}

	void OnEnable(){
		DetachCommandBuffer ();
		AttachCommandBuffer ();
	}


	void OnDisable(){
		DetachCommandBuffer ();
	}

	void AttachCommandBuffer(){ 
		buffer = new CommandBuffer ();
		m_camera.AddCommandBuffer (CameraEvent.BeforeImageEffectsOpaque,buffer);	
	}

	void DetachCommandBuffer(){
		if (buffer == null)
			return;
		m_camera.RemoveCommandBuffer (CameraEvent.BeforeImageEffectsOpaque, buffer);
	}


	void OnPostRender(){
//		Graphics.SetRenderTarget(renderTexture);
		projector.material.SetTexture("_RenderTexture",renderTexture);
	}


}
