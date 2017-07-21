using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class EdgeDetect : MonoBehaviour {

	public Material material;


	public float EdgeOnly = 1;

	public Color EdgeColor = Color.black;

	public Color BackgroundColor = Color.white;

	void OnStart(){
		if (!SystemInfo.supportsImageEffects || null == material || 
			null == material.shader || !material.shader.isSupported){
			enabled = false;
			return;
		}	
	}

	void OnRenderImage(RenderTexture rt1,RenderTexture rt2){
		material.SetFloat ("_EdgeOnly", EdgeOnly);
		material.SetColor ("_EdgeColor", EdgeColor);
		material.SetColor ("_BackgroundColor", BackgroundColor);
		Graphics.Blit (rt1, rt2, material);
	}
}
