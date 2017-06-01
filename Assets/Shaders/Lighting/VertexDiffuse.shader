
Shader "Custom/VertexDiffuse"
{
	Properties
	{
	    _Color("Color",Color) = (1,1,1,1)
	}
	SubShader
	{


		Pass
		{

			Tags { "LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			uniform float4 _LightColor0;

			uniform float4 _Color;


			struct vertexInput{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct vertexOutput{
				float4 pos : SV_POSITION;
				float4 col : COLOR;
			};

			vertexOutput vert(vertexInput input){
				vertexOutput output;

				float3 normal = normalize( mul( float4(input.normal,0.0) , unity_WorldToObject).xyz );


				float3 lightVec         =  _WorldSpaceLightPos0.xyz - mul(unity_ObjectToWorld,input.vertex).xyz;
				float one_over_distance = 1.0 / length(lightVec);
				float attenuation       = lerp(1.0,one_over_distance,_WorldSpaceLightPos0.w);
				float3 lightDir         = lightVec * one_over_distance;



				float3 col =attenuation * _Color.rgb * _LightColor0.rgb * max(0,dot(normal,lightDir));

				output.col = float4(col,1.0); 
				output.pos = UnityObjectToClipPos(input.vertex);

				return output;
			}	

			float4 frag(vertexOutput input) : COLOR{
				return input.col;
			}
			ENDCG
		}
//
		 Pass {	
         	Tags { "LightMode" = "ForwardAdd" } 
            // pass for additional light sources
        	 Blend One One // additive blending 
 
        	 CGPROGRAM
 
        	 #pragma vertex vert  
        	 #pragma fragment frag 
 
	         #include "UnityCG.cginc"
	 
	         uniform float4 _LightColor0; 
	            // color of light source (from "Lighting.cginc")
	 
	         uniform float4 _Color; // define shader property for shaders
	 
	         struct vertexInput {
	            float4 vertex : POSITION;
	            float3 normal : NORMAL;
	         };
	         struct vertexOutput {
	            float4 pos : SV_POSITION;
	            float4 col : COLOR;
	         };
	 
	         vertexOutput vert(vertexInput input){
				vertexOutput output;

				float3 normalDir = normalize( mul( float4(input.normal,0.0) , unity_WorldToObject).xyz );

				float3 lightVec         = _WorldSpaceLightPos0.xyz -  mul(input.vertex,unity_ObjectToWorld).xyz ;
				float one_over_distance = 1.0 / length(lightVec);
				float attenuation       = lerp(1.0,one_over_distance,_WorldSpaceLightPos0.w);
				float3 lightDir         = normalize(lightVec * one_over_distance);



				float3 col =attenuation * _Color.rgb * _LightColor0.rgb * max(0,dot(normalDir,lightDir));

				output.col = float4(col,1.0); 
				output.pos = UnityObjectToClipPos(input.vertex);

				return output;
			}	

 
	         float4 frag(vertexOutput input) : COLOR
	         {
	            return input.col;
	         }
 
         	ENDCG
      	}

	}
	 Fallback "Diffuse"
}
