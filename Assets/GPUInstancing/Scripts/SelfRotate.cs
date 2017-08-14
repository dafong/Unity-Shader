using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SelfRotate : MonoBehaviour {

	// Use this for initialization
	void Update () {
		transform.Rotate(new Vector3(0,1,0),Time.deltaTime * 30);
	}
	

}
