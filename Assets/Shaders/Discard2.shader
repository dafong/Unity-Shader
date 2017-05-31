Shader "Custom/Discard2"
{
	

	SubShader
	{

		Pass
		{
			Cull Front
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float4x4 _matrix;

			struct vertexInput{
				float4 vertex : POSITION;
			};

			struct vertexOutput{
				float4 pos : SV_POSITION;
				float4 localPos : TEXTURE0;
			};

			vertexOutput vert(vertexInput input) {
				vertexOutput output;
				output.pos = mul(UNITY_MATRIX_MVP,input.vertex);
				output.localPos = mul(_matrix , mul(_Object2World,input.vertex)) ;

				return output;
			}

			float4 frag(vertexOutput input) : COLOR{
				if(distance(input.localPos,float4(0.0,0.0,0.0,1.0)) < 0.7 ){
					discard;
				}
				return float4(0.0,1.0,0.0,1.0);
			}

			ENDCG
		}

		Pass
		{
			Cull Back
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float4x4 _matrix;

			struct vertexInput{
				float4 vertex : POSITION;
			};

			struct vertexOutput{
				float4 pos : SV_POSITION;
				float4 localPos : TEXTURE0;
			};

			vertexOutput vert(vertexInput input) {
				vertexOutput output;
				output.pos = mul(UNITY_MATRIX_MVP,input.vertex);
				output.localPos = mul(_matrix , mul(_Object2World,input.vertex)) ;

				return output;
			}

			float4 frag(vertexOutput input) : COLOR{
				if(distance(input.localPos,float4(0.0,0.0,0.0,1.0)) < 0.7 ){
					discard;
				}
				return float4(0.0,1.0,1.0,1.0);
			}

			ENDCG
		}
	}
}
