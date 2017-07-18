// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/OutlineViewDir" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_EmissionColor ("Emission Color" , Color) = (1,1,1,1)
		_OutlineColor("Outline Color" , Color) = (0,0,0,0)
		_Outline("Outline", Range(0,1)) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 normal;
			float3 viewDir;
		};

		half   _Glossiness;
		half   _Metallic;
		fixed4 _Color;
		float4 _OutlineColor;
		float  _Outline;
		fixed4 _EmissionColor;



		void vert(inout appdata_full v,out Input o){
			UNITY_INITIALIZE_OUTPUT(Input,o);
			o.normal = normalize(mul(float4(v.normal,0),unity_WorldToObject)).xyz;
			float4 posWorld = mul(unity_ObjectToWorld,v.vertex);
			o.viewDir = normalize(_WorldSpaceCameraPos - posWorld.xyz);
		}

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

	    fixed3 GetSilhouetteUseConstant(fixed3 normal, fixed3 vierDir) {
			fixed edge = saturate(dot (normal, vierDir));   
			edge = edge < _Outline ? edge/4 : 1;

			return fixed3(edge, edge, edge);
         }

//            fixed3 GetSilhouetteUseTexture(fixed3 normal, fixed3 vierDir) {
//                fixed edge = dot(normal, vierDir);
//                edge = edge * 0.5 + 0.5;
//                return tex2D(_SilhouetteTex, fixed2(edge, edge)).rgb;
//            }


		void surf (Input IN, inout SurfaceOutputStandard o) {
			float3 normal  = normalize(IN.normal);
			float3 viewDir = normalize(IN.viewDir);
			float3 color = GetSilhouetteUseConstant(normal,viewDir);
			float4 c = tex2D(_MainTex,IN.uv_MainTex);
//			float edge = saturate(dot(normal,viewDir));
//			float4 c = _OutlineColor;
//			if (edge > _Outline){
//				c= tex2D (_MainTex, IN.uv_MainTex) * _Color;
//			}
			o.Emission = c.rgb * color;
	

			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
