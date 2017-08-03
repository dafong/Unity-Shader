//blur use the SeparableGlassBlur of Unity RenderingCommandBuffers example
Shader "Custom/Shadow/Blit/SimpleBlur"{
	Properties{
		_MainTex ("Texture", 2D) = "white" {}
	}

	SubShader{
		ZTest Always Cull Off ZWrite Off
		Fog { Mode Off }

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
			float4 _Offset;

			v2f vert (appdata v){
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.uv1= o.uv.xyxy + _Offset.xyxy * float4(1,1,-1,-1) ;
				o.uv2= o.uv.xyxy + _Offset.xyxy * float4(1,1,-1,-1) * 2 ;
				o.uv3= o.uv.xyxy + _Offset.xyxy * float4(1,1,-1,-1) * 3 ;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target{
				// sample the texture
				fixed4 col = fixed4(0,0,0,0);
				col += 0.40 * tex2D(_MainTex, i.uv);
				col += 0.15 * tex2D(_MainTex,i.uv1.xy);
				col += 0.15 * tex2D(_MainTex,i.uv1.zw);
				col += 0.10 * tex2D(_MainTex,i.uv2.xy);
				col += 0.10 * tex2D(_MainTex,i.uv2.zw);
				col += 0.05 * tex2D(_MainTex,i.uv3.xy);
				col += 0.05 * tex2D(_MainTex,i.uv3.zw);
				return col;
			}
			ENDCG
		}
	}
}
