Shader "Custom/RGBCube"
{
	SubShader
	{
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct vertexOutput{
				float4 pos : SV_POSITION;
				float4 col : TEXCOORD0;
			};

			vertexOutput vert(float4 vertexPos : POSITION){
				vertexOutput output;
				output.pos = mul(UNITY_MATRIX_MVP,vertexPos);
				output.col = vertexPos + float4(0.5,0.5,0.5,0);
				return output;
			}

			float4 frag(vertexOutput input) : COLOR{
//				float cf = (input.col.r + input.col.g + input.col.b)/3;
//				return float4(cf,cf,cf,1);
//				return float4(0.21*input.col.r , 0.72 * input.col.g , 0.07 * input.col.b,1);
//		        return input.col + float4(-1,0,0,1);
				return input.col;
			}

			ENDCG
		}
	}
}
