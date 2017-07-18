

Shader "Custom/Cookies"
{
	Properties
	{
		_Color ( "Diffuse Color",Color) = (1,1,1,1)
		_SepcColor("Spec Color",Color)  = (1,1,1,1)
		_Shininess("Shininess",float)   = 10
	}
	SubShader
	{
		 Pass {    
         Tags { "LightMode" = "ForwardBase" } // pass for ambient light 
            // and first directional light source without cookie
 
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         #include "UnityCG.cginc"
         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         // User-specified properties
         uniform float4 _Color; 
         uniform float4 _SpecColor; 
         uniform float _Shininess;
 
         struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 posWorld : TEXCOORD0;
            float3 normalDir : TEXCOORD1;
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
            float4x4 modelMatrix = unity_ObjectToWorld;
            float4x4 modelMatrixInverse = unity_WorldToObject;
 
            output.posWorld = mul(modelMatrix, input.vertex);
            output.normalDir = normalize(
               mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
            output.pos = UnityObjectToClipPos(input.vertex);
            return output;
         }
 
         float4 frag(vertexOutput input) : COLOR
         {
            float3 normalDirection = normalize(input.normalDir);
 
            float3 viewDirection = normalize(
               _WorldSpaceCameraPos - input.posWorld.xyz);
            float3 lightDirection = 
               normalize(_WorldSpaceLightPos0.xyz);
 
            float3 ambientLighting = 
               UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
 
            float3 diffuseReflection = 
               _LightColor0.rgb * _Color.rgb
               * max(0.0, dot(normalDirection, lightDirection));
 
            float3 specularReflection;
            if (dot(normalDirection, lightDirection) < 0.0) 
               // light source on the wrong side?
            {
               specularReflection = float3(0.0, 0.0, 0.0); 
                  // no specular reflection
            }
            else // light source on the right side
            {
               specularReflection = _LightColor0.rgb 
                  * _SpecColor.rgb * pow(max(0.0, dot(
                  reflect(-lightDirection, normalDirection), 
                  viewDirection)), _Shininess);
            }
 
            return float4(ambientLighting + diffuseReflection 
               + specularReflection, 1.0);
         }
 
         ENDCG
      }
		
		Pass
		{
			Tags { "LightMode" = "ForwardAdd" } 
			Blend One One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			uniform float4 _LightColor0;
			uniform float4x4 unity_WorldToLight; // transformation 
            
         	uniform sampler2D _LightTexture0; 

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;

			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float4 posLight : TEXCOORD1;
				float3 normal : TEXCOORD2;
			};

			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float  _Shininess;

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex   = UnityObjectToClipPos(v.vertex);
				o.posWorld = mul(unity_ObjectToWorld,v.vertex);
				o.normal   = normalize(mul( float4(v.normal,0),unity_WorldToObject).xyz);
				o.posLight = mul(unity_WorldToLight,o.posWorld);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 normalDir = normalize(i.normal);
				float3 viewDir   = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);
				float3 lightDir  = normalize(_WorldSpaceLightPos0.xyz - i.posWorld.xyz * _WorldSpaceLightPos0.w);
			
				float3 diffuseLighting = _LightColor0.rgb * _Color.rgb * max(0,dot(normalDir,lightDir));
				float3 specularLighting;
				if(dot(normalDir,lightDir) < 0){
					specularLighting = float3(0,0,0);
				}else{
					float cosin = max(0,dot(reflect(-lightDir,normalDir),viewDir));
					specularLighting = _LightColor0.rgb * _SpecColor.rgb * pow(cosin,_Shininess);
				}
				float cookieAttenuation = 1;
				cookieAttenuation = tex2D(_LightTexture0,i.posLight.xyz).a;

				return float4( (1-cookieAttenuation) *(  diffuseLighting + specularLighting ),1);
			}
			ENDCG
		}

	}
}
