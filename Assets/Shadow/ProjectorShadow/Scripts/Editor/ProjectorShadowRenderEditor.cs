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

		EditorGUILayout.IntPopup(serializedObject.FindProperty("textureWidth"), textureSizeDisplayOption, textureSizeOption);
		EditorGUILayout.IntPopup(serializedObject.FindProperty("textureHeight"), textureSizeDisplayOption, textureSizeOption);
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
