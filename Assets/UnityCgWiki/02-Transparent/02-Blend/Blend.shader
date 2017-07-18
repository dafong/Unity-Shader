// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Blend"
{
	
	SubShader
	{

		Tags { "Queue" = "Transparent" }
		Pass
		{
			Cull Front
			ZWrite Off
			Blend SRCALPHA ONEMINUSSRCALPHA

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float4 vert(float4 vertexPos : POSITION) : SV_POSITION{
				return UnityObjectToClipPos(vertexPos);
			}

			float4 frag(void) : COLOR{
				return float4(1.0,0,0.0,0.3);
			}
			ENDCG
		}

		Pass
		{
			ZWrite Off
			Blend SRCALPHA ONEMINUSSRCALPHA
			Cull Back
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float4 vert(float4 vertexPos : POSITION) : SV_POSITION{
				return UnityObjectToClipPos(vertexPos);
			}

			float4 frag(void) : COLOR{
				return float4(0.0,1,0.0,0.3);
			}
			ENDCG
		}
	}
}
