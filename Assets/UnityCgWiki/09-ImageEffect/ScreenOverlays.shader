Shader "Custom/ScreenOverlays"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color",Color)  = (1,1,1,1)
		_X("X",Float)           = 0
		_Y("Y",Float)           = 0
		_Width("Width",Float)   = 128
		_Height("Height",Float) = 128
	}
	SubShader
	{
		Tags { "Queue" = "Overlay" }
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZTest Always

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			uniform float4 _Color;
			uniform float _X;
			uniform float _Y;
			uniform float _Width;
			uniform float _Height;

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

			
			v2f vert (appdata v)
			{
				v2f o;
				float2 rasterPosition = float2(
              		 _X + _Width * (v.vertex.x + 0.5),
               		 _Y   + _Height * (v.vertex.y + 0.5)
               		 );

				o.vertex = float4(
					2.0 * rasterPosition.x / _ScreenParams.x - 1,
//					2.0 * rasterPosition.y / _ScreenParams.y - 1,
					_ProjectionParams.x * (2.0 * rasterPosition.y / _ScreenParams.y - 1.0 ),
					_ProjectionParams.y,
					1.0
				);

				o.uv = float4(v.vertex.x + 0.5,v.vertex.y+0.5,0,0);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = _Color * tex2D(_MainTex, i.uv);

				return col;
			}
			ENDCG
		}
	}
}
