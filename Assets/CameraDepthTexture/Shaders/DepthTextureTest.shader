﻿Shader "Unlit/DepthTextureTest"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		LOD 100

		Pass
		{
           ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _CameraDepthTexture;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
                
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the depth texture, 深度存在R 通道里高精度值
                //https://docs.unity3d.com/Manual/SL-CameraDepthTexture.html
                //https://docs.unity3d.com/Manual/SL-CameraDepthTexture.html
				fixed col =Linear01Depth(tex2D(_CameraDepthTexture , i.uv).r);
                
		
                return fixed4(col ,0,0,1);
                
			}
			ENDCG
		}
	}
}
