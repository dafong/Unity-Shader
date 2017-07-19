
Shader "Custom/OutlineShell" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Outline("Outline",Range(0,1)) = 0
		_OutlineColor("Outline Color",Color) = (0,0,0,0)
	}
	SubShader {

		Tags{"RenderQueue" = "Opaque"}

		Pass{
			Name "Basic"
			CGPROGRAM
			#pragma vertex vert

            #pragma fragment frag 

            sampler2D _MainTex;

            void vert(float4 vertex : POSITION , 
                      float4 uv : TEXCOORD0 ,
                      out float4 pos : SV_POSITION,
                      out float4 ouv : TEXCOORD0 ){
            	pos = UnityObjectToClipPos(vertex);
            	ouv = uv;
            }

            float4 frag(float4 ouv : TEXCOORD0) : Color{
            	return tex2D(_MainTex,ouv);
            }

			ENDCG
		}

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
            	o.pos = mul(UNITY_MATRIX_P,float4(vpos,1));
            }

			v2f vert(appdata v){
				v2f o;
//				ShellMethod0(v, o);
				ShellMethod1(v, o);
//				v.vertex  = v.vertex + float4(v.normal * _Outline,0);
//				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			float4 frag(v2f i) : COLOR{
				return _OutlineColor;
   		    }
            ENDCG
		}
	}
	FallBack "Diffuse"
}
