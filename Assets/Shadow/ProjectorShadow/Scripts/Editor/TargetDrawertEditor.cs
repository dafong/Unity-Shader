using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(TargetDrawer))]
public class DrawWithTargetEditor : EditorBase {

	void OnEnable(){
		
	}

	public override void OnInspectorGUI(){
		TargetDrawer targetDrawer = target as TargetDrawer;
		EditorGUILayout.PropertyField(serializedObject.FindProperty("target"));
		SerializedProperty prop = serializedObject.FindProperty("renderChildren");
		EditorGUILayout.PropertyField(prop);
		bool isGUIEnabled = GUI.enabled;
		++EditorGUI.indentLevel;
		GUI.enabled = isGUIEnabled && prop.boolValue;
		EditorGUILayout.PropertyField(serializedObject.FindProperty("layerMask"));
		GUI.enabled = isGUIEnabled;
		--EditorGUI.indentLevel;

	
		EditorGUILayout.PropertyField(serializedObject.FindProperty("shadowMaterial"));
		EditorGUILayout.PropertyField(serializedObject.FindProperty("replacementShaders"), true);
		serializedObject.ApplyModifiedProperties();
	}
}
