Shader "Custom/Blur/GaussianBlur"{
	Properties{
		_MainTex ("Texture", 2D) = "white" {}
	}

	SubShader{

		ZWrite Off
		Cull Off
		ZTest Always

		CGINCLUDE
		#include "UnityCG.cginc"
		struct appdata{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f{
			float2 uv[5] : TEXCOORD0;
			UNITY_FOG_COORDS(1)
			float4 vertex : SV_POSITION;
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;

		float _BlurSize;
		float4 _MainTex_TexelSize;

		v2f vert_verticle (appdata v){
			v2f o;
			o.vertex  = UnityObjectToClipPos(v.vertex);
			float2 uv = TRANSFORM_TEX(v.uv, _MainTex);
			float y   = _MainTex_TexelSize.y;
			o.uv[0]   = uv;
			o.uv[1]   = uv + float2(0,y) * _BlurSize;
			o.uv[2]   = uv - float2(0,y) * _BlurSize; 
			o.uv[3]   = uv + float2(0,y * 2) * _BlurSize;
			o.uv[4]   = uv - float2(0,y * 2) * _BlurSize; 

			return o;
		}


		v2f vert_horizontal(appdata v){
			v2f o;
			o.vertex  = UnityObjectToClipPos(v.vertex);
			float2 uv = TRANSFORM_TEX(v.uv, _MainTex);
			float x   = _MainTex_TexelSize.x;
			o.uv[0]   = uv;
			o.uv[1]   = uv + float2(x, 0) * _BlurSize;
			o.uv[2]   = uv - float2(x, 0) * _BlurSize; 
			o.uv[3]   = uv + float2(x * 2, 0) * _BlurSize;
			o.uv[4]   = uv - float2(x * 2, 0) * _BlurSize; 
			return o;
		}

		fixed4 frag (v2f i) : SV_Target{
			float weight[3] = {0.4026,0.2442,0.0545};
			fixed4 sum = tex2D(_MainTex,i.uv[0]) * weight[0];
			for(int it = 1;it <3;it ++){
				sum += tex2D(_MainTex,i.uv[it*2-1]) * weight[it];
				sum += tex2D(_MainTex,i.uv[it*2]) * weight[it];
			}
			return sum;
		}
		ENDCG

		Pass{
			Name "HBlur"
			CGPROGRAM

			#pragma vertex vert_horizontal
			#pragma fragment frag

			ENDCG
		}

		Pass{
			Name "VBlur"
			CGPROGRAM

			#pragma vertex vert_verticle
			#pragma fragment frag

			ENDCG
		}
	}
}
