using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshLightmapSetting : MonoBehaviour {

//	[HideInInspector]
	public int lightmapIndex;
//	[HideInInspector]
	public Vector4 lightmapScaleOffset;

	public void SaveSettings()
	{
		Renderer renderer = GetComponent<Renderer>();
		lightmapIndex = renderer.lightmapIndex;
		lightmapScaleOffset = renderer.lightmapScaleOffset;
	}
	public void LoadSettings()
	{
		Renderer renderer = GetComponent<Renderer>();
		renderer.lightmapIndex = lightmapIndex;
		renderer.lightmapScaleOffset = lightmapScaleOffset;
	}

	void Start () {
		LoadSettings();
//		if(Application.isPlaying)
//			Destroy(this);
	}
}
