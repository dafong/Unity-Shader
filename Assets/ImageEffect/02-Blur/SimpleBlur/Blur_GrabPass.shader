Shader "Custom/Blur/Blur_GrabPass"{
	Properties{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurSize("Blur Size",Range(0,4)) = 0
	}
	SubShader{
		Tags { "RenderType"="Opaque"  "Queue" = "Transparent" }

		GrabPass { "_ScreenTex" }

		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f{
				float2 uv : TEXCOORD0;
				float4 uv1: TEXCOORD1;
				float4 uv2: TEXCOORD2;
				float4 uv3: TEXCOORD3;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _BlurSize;
			sampler2D _ScreenTex;
			float4 _ScreenTex_TexelSize;

			v2f vert (appdata v){
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				float4 uv =  ComputeGrabScreenPos(o.vertex);
				o.uv1 = uv.xyxy + _ScreenTex_TexelSize.xyxy * float4(1,1,-1,-1) * _BlurSize;
				o.uv2 = uv.xyxy + _ScreenTex_TexelSize.xyxy * float4(1,1,-1,-1) * 2 * _BlurSize;
				o.uv3 = uv.xyxy + _ScreenTex_TexelSize.xyxy * float4(1,1,-1,-1) * 3 * _BlurSize;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target{
				// sample the texture
				fixed4 col = fixed4(0,0,0,0);
				col += 0.4 * tex2D(_ScreenTex, i.uv);
				col += 0.2 * tex2D(_ScreenTex, i.uv1.xy);
				col += 0.2 * tex2D(_ScreenTex, i.uv1.zw);
				col += 0.15 * tex2D(_ScreenTex, i.uv2.xy);
				col += 0.15 * tex2D(_ScreenTex, i.uv2.zw);
				col += 0.05 * tex2D(_ScreenTex, i.uv3.xy);
				col += 0.05 * tex2D(_ScreenTex, i.uv3.zw);


				return col;
			}
			ENDCG
		}
	}
}
