// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/OutlineViewDir" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_OutlineColor("Outline Color",Color) = (0,0,0,0)
		_Outline("Outline", Range(0,1)) = 0 
		_OutlineTex("Outline Tex",2D) = "white" {}
	}

	SubShader {

		Tags { "RenderType"="Opaque" }
		LOD 200


		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;


		struct Input {
			float2 uv_MainTex;
		};

		half   _Glossiness;
		half   _Metallic;
		fixed4 _Color;



		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG

		Pass{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			float  _Outline;
		    float4 _OutlineColor;
		    sampler2D _OutlineTex;

			struct appdata{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD1;
			};

			v2f vert(appdata i){
				v2f o;
				o.pos    = UnityObjectToClipPos(i.vertex);
				o.normal = normalize(mul(unity_WorldToObject,float4(i.normal,0))).xyz;
				o.viewDir= normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld,i.vertex).xyz);
				return o;
			}

			float3 GetOutlineWithConstant(float3 normal,float3 viewDir){
				float edge = saturate(dot(normal,viewDir));
				edge = edge < _Outline ? edge/4 : 1;
				return float3(edge,edge,edge);
			}

			float3 GetOutlineWithTexture(float3 normal,float3 viewDir){
				fixed edge = dot(normal, viewDir);
                edge = edge * 0.5 + 0.5;
                return tex2D(_OutlineTex, fixed2(edge, edge)).rgb;
			}

			float4 frag(v2f i) : COLOR{
				float3 normal  = normalize(i.normal);
				float3 viewDir = normalize(i.viewDir);

				float3 color;
				color = GetOutlineWithConstant(normal,viewDir);
//				color = GetOutlineWithTexture(normal,viewDir);
				return float4(_OutlineColor.rgb * color,1);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
