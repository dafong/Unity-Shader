using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(ProjectorShadowRender))]
public class ProjectorShadowRenderEditor : EditorBase {

	void OnEnable(){
		
	}

	private Camera camera;
	public override void OnInspectorGUI (){
		ProjectorShadowRender shadowRenderer = target as ProjectorShadowRender;
		EditorGUILayout.PropertyField (serializedObject.FindProperty ("eraseShadowMat"));
		EditorGUILayout.PropertyField (serializedObject.FindProperty ("downSampleMat"));
		EditorGUILayout.PropertyField (serializedObject.FindProperty ("blurMat"));


		EditorGUILayout.PropertyField (serializedObject.FindProperty ("shadowColor"));
		EditorGUILayout.IntPopup(serializedObject.FindProperty("textureWidth"), textureSizeDisplayOption, textureSizeOption);
		EditorGUILayout.IntPopup(serializedObject.FindProperty("textureHeight"), textureSizeDisplayOption, textureSizeOption);
		EditorGUILayout.PropertyField (serializedObject.FindProperty ("superSampling"));
		EditorGUILayout.PropertyField (serializedObject.FindProperty ("mutiSampling"));

		EditorGUILayout.PropertyField(serializedObject.FindProperty("blurFilter"));
		EditorGUILayout.PropertyField (serializedObject.FindProperty ("blurLevel"));
		EditorGUILayout.Slider(serializedObject.FindProperty("blurSize"), 1.0f, shadowRenderer.blurFilter == ProjectorShadowRender.BlurFilter.Uniform ? 6.0f : 4.0f);
		camera = shadowRenderer.GetComponent<Camera>();
		bool isShowCamera = (camera.hideFlags & HideFlags.HideInInspector) == 0;
		bool newValue = EditorGUILayout.Toggle("Show Camera in Inspector", isShowCamera);
		if (isShowCamera != newValue) {
			if (newValue) {
				camera.hideFlags &= ~HideFlags.HideInInspector;
			}else {
				camera.hideFlags |= HideFlags.HideInInspector;
			}
			EditorUtility.SetDirty( target );
		}
		serializedObject.ApplyModifiedProperties();
	}
}
