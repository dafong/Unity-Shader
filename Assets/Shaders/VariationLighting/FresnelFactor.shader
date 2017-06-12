Shader "Custom/FresnelFactor"
{
	Properties
	{
		_Color("Diffuse Color",Color) = (1,1,1,1)
		_SpecColor("Specular Color",Color) = (1,1,1,1)
		_Shininess("Shininess",Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "LightingMode" = "FowardBase"}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normalDir : TEXCOORD0;
				float4 worldPos : TEXCOORD1;
			};
			uniform float3 _LightColor0;

			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normalDir = normalize(mul(float4(v.normal,0), unity_WorldToObject)).xyz;
				o.worldPos  = mul(unity_ObjectToWorld,o.vertex);
				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				float3 normalDir  = normalize(i.normalDir);
				float3 lightVec   = _WorldSpaceLightPos0.xyz - i.worldPos.xyz * _WorldSpaceLightPos0.w;
				float step_over_distance = 1 / length(lightVec);
				float3 lightDir   = normalize(lightVec);
				float attenuation = lerp(1,step_over_distance,_WorldSpaceLightPos0.w);

				float3 diffuseReflect = attenuation * _Color.rgb *_LightColor0.rgb * max(0,dot(lightDir,normalDir));

				float3 viewDir    =  normalize(_WorldSpaceCameraPos - i.worldPos.xyz);

				float3 specularReflect = float3(0,0,0);
				if(dot(lightDir,normalDir) > 0){
					float3 cosine  = max(0,dot(reflect(-lightDir,normalDir),viewDir));
					float3 halfwayDir = normalize(lightDir + viewDir);
					float w = pow(1,)
					specularReflect= attenuation * _SpecColor.rgb * _LightColor0.rgb * pow(cosine,_Shininess);
				}

				float4 col;
				//diffuse

				//specular
				
				return col;
			}
			ENDCG
		}
	}
}
