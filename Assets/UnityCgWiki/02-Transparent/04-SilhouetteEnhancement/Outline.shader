// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/Outline"
{
	Properties
	{
		_Color("Color",Color) = (1,1,1,0.5)
		_Power("Power",float) = 0
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" }
		Pass {
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag 

			#include "UnityCG.cginc"

			uniform float4 _Color;
			uniform float _Power;
			struct vertexInput{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct vertexOutput{
				float4 pos : SV_POSITION;
				float3 normal : TEXCOORD;
				float3 viewDir : TEXCOORD1;
			};

			vertexOutput vert(vertexInput input){
				vertexOutput output;
				output.normal = normalize( mul( float4(input.normal,0.0), unity_WorldToObject ).xyz);
				output.pos = UnityObjectToClipPos(input.vertex);
				output.viewDir = normalize( _WorldSpaceCameraPos - mul(input.vertex,unity_ObjectToWorld ).xyz );
				return output;
			}

			float4 frag(vertexOutput input) : COLOR{
				float3 normalDir = normalize(input.normal);
				float3 viewDir   = normalize(input.viewDir);
				float newOpacity = min(1.0, _Color.a/pow(abs(dot(normalDir,viewDir)),_Power) );

				return float4(_Color.rgb,newOpacity);
			}
			ENDCG
		}
	}
}
