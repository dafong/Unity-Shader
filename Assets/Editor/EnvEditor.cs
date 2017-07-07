using UnityEditor;
using UnityEngine;
using System.Reflection;
using System;

namespace UnityEditor{
	[InitializeOnLoad]
	 class EnvEditor  : Editor {

		static EnvEditor(){ 
			SceneView.onSceneGUIDelegate -= OnSceneGUI;
			SceneView.onSceneGUIDelegate += OnSceneGUI;

			// EditorApplication.hierarchyWindowChanged可以让我们知道是否在编辑器加载了一个新的场景
			EditorApplication.hierarchyWindowChanged -= OnSceneChanged;
			EditorApplication.hierarchyWindowChanged += OnSceneChanged;
		}

		void OnDestroy(){
			SceneView.onSceneGUIDelegate -= OnSceneGUI;

			EditorApplication.hierarchyWindowChanged -= OnSceneChanged;
		}

		static void OnSceneChanged(){
			Tools.hidden = false;

		}

		static void OnSceneGUI( SceneView sceneView ){
			DrawToolsMenu( sceneView.position );
		}

		static void DrawToolsMenu( Rect position )
		{
			// 通过使用Handles.BeginGUI()，我们可以开启绘制Scene视图的GUI元素
			Handles.BeginGUI();

			//Here we draw a toolbar at the bottom edge of the SceneView
			// 这里我们在Scene视图的底部绘制了一个工具条
			GUILayout.BeginArea( new Rect( 0, position.height - 35, position.width, 20 ), EditorStyles.toolbar );
			{
				GUILayout.BeginHorizontal ();
				GUILayout.Label ("DEV", GUILayout.Width (100)); 
				GUILayout.Label ("CNSTORE", GUILayout.Width (100)); 
				GUILayout.EndHorizontal ();
			}
			GUILayout.EndArea();

			Handles.EndGUI();
		}
	}
}

