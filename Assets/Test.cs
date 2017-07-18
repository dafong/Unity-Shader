using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour {

	// Use this for initialization
	void Start () {
		float r = Vector2.Dot ((new Vector2 (10, 6) - new Vector2 (4, 2)), new Vector2 (-3, 4));
		Debug.Log (r);
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
