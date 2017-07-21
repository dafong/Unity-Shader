using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class WhatIs_Time : MonoBehaviour {

	public Text label;

	// Update is called once per frame
	void Update () {
		label.text = Mathf.Sin (Time.time/4) + "";
	}
}
