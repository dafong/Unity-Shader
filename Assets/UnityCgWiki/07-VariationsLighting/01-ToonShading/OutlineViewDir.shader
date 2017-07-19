// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/OutlineViewDir" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex("Main Texture",2D) = "white" {}
		_SilhouetteTex("Outline Texture",2D) = "black" {}
		_OutlineColor("Outline Color" , Color) = (0,0,0,0)
		_Outline("Outline", Range(0,1)) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			sampler2D _SilhouetteTex;
			float _Outline;
			float4 _OutlineColor;

			struct appdata{
				float4 vertex : POSITION;
				float4 uv     : TEXCOORD0;
				float3 normal : TEXCOORD1;
			};


			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};


			v2f vert(appdata i){
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.uv = i.uv;
				o.normal = normalize(mul(float4(i.normal,0),unity_WorldToObject).xyz);
				o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld,i.vertex)).xyz;
				return o;
			}

			 fixed3 GetSilhouetteUseConstant(fixed3 normal, fixed3 viewDir) {
			 	normal = normalize(normal);
			 	viewDir= normalize(viewDir);
				fixed edge = saturate(dot (normal, viewDir));   
				edge = edge < _Outline ? edge/4 : 1;

				return fixed3(edge, edge, edge);
	         }

            fixed3 GetSilhouetteUseTexture(fixed3 normal, fixed3 viewDir) {
            	normal = normalize(normal);
            	viewDir= normalize(viewDir);
                fixed edge = dot(normal, viewDir);
                edge = edge * 0.5 + 0.5;
                return tex2D(_SilhouetteTex, fixed2(edge, edge)).rgb;
            }

			float4 frag(v2f v) : COLOR{
				float4 color = tex2D(_MainTex,v.uv);
				color.rgb = color.rgb * GetSilhouetteUseConstant(v.normal,v.viewDir);
				return color;
			}


			ENDCG

		}

	}
	FallBack "Diffuse"
}
