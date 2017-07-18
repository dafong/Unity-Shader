Shader "Custom/GlossyTextures"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Diffuse Material Color",Color) = (1,1,1,1)
		_SpecColor("SpecColor",Color) = (1,1,1,1)
		_Shininess("Shininess",Float) = 10
	}

	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			uniform float4 _LightColor0;

			uniform sampler2D _MainTex;
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
			    float4 pos       : SV_POSITION;
			    float4 posWorld  : TEXCOORD0;
			    float3 normalDir : TEXCOORD1;
			    float4 uv        : TEXCOORD2;
			};
			
			v2f vert (appdata i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.posWorld = mul(i.vertex,unity_ObjectToWorld);
				o.normalDir= normalize(mul(float4(i.normal,0),unity_WorldToObject).xyz);
				o.uv = i.texcoord;
				return o;	
			}
			
			float4 frag (v2f i) : COLOR
			{
				float3 normalDir = normalize(i.normalDir);
				float3 viewDir   = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float4 textureColor = tex2D(_MainTex,i.uv);

				float3 lightVec   = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
				float step_over_distance = 1 / length(lightVec);
				float attenuation = lerp( 1,step_over_distance , _WorldSpaceLightPos0.w);
				float3 lightDir  = lightVec * step_over_distance;


				//diffuse color
				float3 diffuseColor = textureColor.rgb * attenuation * _LightColor0.rgb * _Color.rgb * max(0,dot(normalDir,lightDir));
				//ambient color
				float3 ambientColor = textureColor.rgb * UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
				//specular color

				float3 specularColor;
				if(dot(normalDir,lightDir) < 0){
					specularColor = float3(0,0,0);
				}else{
					float angle = max(0,dot(reflect(-lightDir,normalDir),viewDir));
					specularColor= attenuation * _LightColor0.rgb * _SpecColor.rgb * (textureColor.a) * pow(angle,_Shininess);
				}


				return float4(ambientColor + diffuseColor + specularColor , 1);
//				return textureColor;
			}
			ENDCG
		}
	}
}
