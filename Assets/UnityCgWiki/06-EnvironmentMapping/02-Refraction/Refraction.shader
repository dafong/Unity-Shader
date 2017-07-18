Shader "Custom/Refraction"
{
	Properties
	{
		_Cube("CubeMap",Cube) = "" {}
	}
	SubShader
	{
		
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
				float3 normal : TEXCOORD0;
				float3 viewDir: TEXCOORD1;
			};

			uniform samplerCUBE _Cube;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = normalize(mul(unity_WorldToObject,v.normal).xyz);
				o.viewDir= normalize(mul(unity_ObjectToWorld,v.vertex).xyz - _WorldSpaceCameraPos.xyz);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float refractiveIndex = 1.5;
				float3 refractedDir = refract(normalize(i.viewDir),normalize(i.normal),1.0/refractiveIndex);
				return texCUBE(_Cube,refractedDir);
			}
			ENDCG
		}
	}
}
