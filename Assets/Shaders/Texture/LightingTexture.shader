#warning Upgrade NOTE: unity_Scale shader variable was removed; replaced '_WorldSpaceCameraPos.w' with '1.0'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/LightingTexture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color",Color) = (1,1,1,1)
		_SpecColor("Specular Color",Color) = (1,1,1,1)
		_Shininess("Shininess",float)  = 10
	}
	SubShader
	{
		
		Pass
		{
			Tags { "LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex   vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			 uniform float4 _LightColor0;
			uniform sampler2D _MainTex;
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;

			struct appdata{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
				float3 diffuseCol : TEXCOORD1;
				float3 specularCol : TEXCOORD2;
			};

			v2f vert(appdata input){
				v2f output;

				output.pos = UnityObjectToClipPos(input.vertex);


				float3 normalDir = normalize( mul(float4(input.normal,0) , unity_WorldToObject).xyz );
				float3 viewDir   = normalize( _WorldSpaceCameraPos - mul(input.vertex,unity_ObjectToWorld).xyz );

				//diffuse color
				float3 lightVec = _WorldSpaceLightPos0.xyz - mul(input.vertex, unity_ObjectToWorld).xyz;
				float  step_over_distance = 1 / length(lightVec);
				float attenuation = lerp(1,step_over_distance,1.0);
				float3 lightDir = lightVec * step_over_distance;

				float3 diffuseCol = _LightColor0.rgb * _Color.rgb * attenuation * max(0,dot(normalDir,lightDir));

				//ambient lighting
				float3 ambientCol = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;

				//specular lighting
				float3 specularCol ;
				if(dot(normalDir,lightDir) < 0){
					specularCol = float3(0,0,0);	
				}else{
					float angle = max(0,dot(reflect(-lightDir,normalDir) , viewDir));
					specularCol = attenuation * _LightColor0.rgb * _SpecColor.rgb * pow(angle,_Shininess);
				}
				output.diffuseCol = diffuseCol + ambientCol;
				output.specularCol=specularCol;
				output.tex = input.texcoord;
				return output;

			}

			float4 frag(v2f input) : COLOR{
				return float4(input.specularCol + input.diffuseCol  * tex2D(_MainTex,input.tex.xy),1);
			}

			ENDCG
		}

	}
}
