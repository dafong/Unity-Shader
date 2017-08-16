using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class LightingMap : MonoBehaviour {

	public Texture2D[] red;
	public Texture2D[] green;
	public GameObject bunkerPrefab;
	public Transform parent;
	// Use this for initialization
	void Start () {
		if (Application.isPlaying) {
			LightmapSettings.lightmaps = null;
			GameObject go = Instantiate<GameObject> (bunkerPrefab,Vector3.zero, Quaternion.identity);
			go.transform.SetParent (parent);
			go.transform.localPosition =  new Vector3(-5.3f,0.31f,4.33f);
		}
	}

	#if UNITY_EDITOR
	void OnEnable(){
		UnityEditor.Lightmapping.completed +=LightingMapComplete;
	}

	void OnDisable(){
		UnityEditor.Lightmapping.completed -=LightingMapComplete;
	}
	#endif

	void LightingMapComplete(){
		MeshLightmapSetting[] savers = GameObject.FindObjectsOfType<MeshLightmapSetting> ();
		foreach(MeshLightmapSetting s in savers){
			s.SaveSettings ();
		}
	}

	public void OnSwitchGreen(){
		LightmapData[] lds = new LightmapData[green.Length];
		for(int i = 0;i<lds.Length;i++){
			lds [i] = new LightmapData ();
			lds [i].lightmapColor = green [i];
			lds [i].lightmapDir   = green [i];
		}
		LightmapSettings.lightmaps = lds;

		DynamicGI.UpdateEnvironment ();
	}

	public void OnSwitchRed(){
		LightmapData[] lds = new LightmapData[red.Length];
		for(int i = 0;i<lds.Length;i++){
			lds [i] = new LightmapData ();
			lds [i].lightmapColor = red [i];
			lds [i].lightmapDir   = red [i];
		}
		LightmapSettings.lightmaps = lds;
		DynamicGI.UpdateEnvironment ();
	}



}

