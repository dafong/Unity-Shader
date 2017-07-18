using UnityEngine;
using System.Collections;
[ExecuteInEditMode]
public class Discard : MonoBehaviour {

	MeshRenderer renderer;
	MeshRenderer trenderer;
	public Transform target;
	// Use this for initialization
	void Start () { 
		renderer = GetComponent<MeshRenderer> ();
		trenderer = target.GetComponent<MeshRenderer> ();
	}
	
	// Update is called once per frame
	void Update () {
		renderer.sharedMaterial.SetMatrix ("_matrix", trenderer.worldToLocalMatrix);
	}
}
