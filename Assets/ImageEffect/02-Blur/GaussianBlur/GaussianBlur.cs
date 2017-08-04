using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : MonoBehaviour {

	[Range(0,10)]
	public float blurSize;

	[Range(1,5)]
	public int downSample = 1;

	public Material blurMat;

	private int _blurSizeId;

	void Awake(){
		_blurSizeId = Shader.PropertyToID ("_BlurSize");
	}

	void OnRenderImage(RenderTexture rt1,RenderTexture rt2){
	
		int rtw = rt1.width / downSample;
		int rth = rt1.height / downSample;

		RenderTexture dst = RenderTexture.GetTemporary (rtw, rth, 0);
		dst.filterMode = FilterMode.Bilinear;
		blurMat.SetFloat (_blurSizeId, blurSize);
		Graphics.Blit (rt1, dst, blurMat,0);

		RenderTexture src = dst;


		Graphics.Blit (src, rt2, blurMat,1);


	}
}
