using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class Blur : MonoBehaviour {

	public Material blurMat;

	[Range(0,10)]
	public float blurSize;

	private int s_offset;
	private float offsetH;
	private float offsetV;
	void Awake(){
		s_offset = Shader.PropertyToID ("_Offset");

	}

	void OnRenderImage(RenderTexture rt1,RenderTexture rt2){
		offsetH = blurSize / Screen.width;
		offsetV = blurSize / Screen.height;
		blurMat.SetVector (s_offset, new Vector4 (offsetH,offsetV,offsetH,offsetV));

		Graphics.Blit (rt1, rt2, blurMat);	
	}
}
