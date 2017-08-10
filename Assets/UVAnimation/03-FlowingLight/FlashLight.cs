using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Image))]
public class FlashLight : MonoBehaviour {
	
	private Image image;
	private int s_Aspect;

	void Awake(){
		image    = GetComponent<Image> ();	
		s_Aspect = Shader.PropertyToID ("_Aspect");
		image.material.SetFloat (s_Aspect,   image.preferredHeight / image.preferredWidth);
	}

}
