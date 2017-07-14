Shader "Custom/OutlineShell" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_EmissionColor ("Emission Color" , Color) = (1,1,1,1)
		_Outline("Outline",Range(0,1)) = 0
		_OutlineColor("Outline Color",Color) = (0,0,0,0)
	}
	SubShader {
		
		Tags { "RenderType"="Opaque" }
		LOD 200

		Pass{
			Name "ShellOutline"

            Cull Front
            CGPROGRAM

            #pragma vertex vert

            #pragma fragment frag 

           
            #include "UnityCG.cginc"

            struct appdata {
            	float4 vertex : POSITION;
            	float3 normal : NORMAL;
            };

            uniform float  _Outline;
            uniform float4 _OutlineColor;
             
            struct v2f{
            	float4 pos : SV_POSITION;
            };

            void ShellMethod0(appdata i,inout v2f o){
            	o.pos = UnityObjectToClipPos(i.vertex);
            	float3 normal = mul(UNITY_MATRIX_IT_MV,float4(i.normal,0)).xyz;
            	float2 offset = mul(UNITY_MATRIX_P,float4(normal,0)).xy;
            	o.pos.xy += offset * o.pos.z * _Outline;
            }

            void ShellMethod1(appdata i,inout v2f o){
            	float3 vpos   = UnityObjectToViewPos(i.vertex);
            	float3 normal = mul(UNITY_MATRIX_IT_MV,float4(i.normal,0)).xyz;
            	normal.z = -1;
            	vpos += normalize(normal) * _Outline;
            	o.pos = mul(UNITY_MATRIX_P,float4(vpos,0));
            }

			v2f vert(appdata v){
				v2f o;
//				ShellMethod0(v, o);
				ShellMethod1(v, o);
				return o;
			}

			float4 frag(v2f i) : COLOR{
				return _OutlineColor;
   		    }
            ENDCG
		}


		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard  

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		fixed4 _EmissionColor;

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
			o.Emission = tex2D (_MainTex, IN.uv_MainTex) * _EmissionColor;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
