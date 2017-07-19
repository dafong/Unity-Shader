Shader "Custom/OutlineZBias" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_EmissionColor ("Emission Color" , Color) = (1,1,1,1)
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Outline("Outline",Range(0,0.1)) = 0
		_OutlineColor("Outline Color", Color) = (0,0,0,0)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200


		Pass{
			Name "Basic"

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;

			struct appdata{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
			};


			v2f vert(appdata i) {
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.uv  = i.uv;
				return o;
			}

			float4 frag(v2f v) : COlOR{
				return tex2D(_MainTex,v.uv);
			}

			ENDCG
		}

		Pass{
			Name "ZBias"
			Cull Front
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
		
			struct appdata{
				float4 vertex : POSITION;
			};

			struct v2f{
				float4 pos : SV_POSITION;
			};

			uniform float  _Outline;
			uniform float4 _OutlineColor;
			v2f vert(appdata v){
				v2f o;
				float4 vpos = mul(UNITY_MATRIX_MV,v.vertex);
				vpos += _Outline;
				o.pos = mul(UNITY_MATRIX_P,vpos);
	
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
