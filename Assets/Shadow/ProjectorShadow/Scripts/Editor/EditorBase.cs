using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EditorBase : UnityEditor.Editor {
	protected static GUIContent[] textureSizeDisplayOption = new GUIContent[] {
		new GUIContent("16"), 
		new GUIContent("32"), 
		new GUIContent("64"), 
		new GUIContent("128"), 
		new GUIContent("256"), 
		new GUIContent("512")};

	protected static int[] textureSizeOption = new int[] {16, 32, 64, 128, 256, 512};
}
