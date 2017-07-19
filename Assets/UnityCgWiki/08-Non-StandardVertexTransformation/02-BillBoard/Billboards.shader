Shader "Custom/Billboards"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ScaleX  ("Scale X",float) = 1.0
		_ScaleY  ("Scale Y",float) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque"  "DisableBatching" = "True" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			uniform sampler2D _MainTex;
			uniform float     _ScaleX;
			uniform float     _ScaleY;


			v2f vert (appdata v)
			{
				v2f o;
			
				float4 mvPos = mul( UNITY_MATRIX_MV , float4(0,0,0,1) ) + float4( v.vertex.x,v.vertex.y,0,0) * float4(_ScaleX,_ScaleY,1,1); 
				o.vertex = mul(UNITY_MATRIX_P,mvPos);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
