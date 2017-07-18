Shader "Custom/Reflection"
{
	Properties
	{
		_Cube("cubemap",Cube) = "" {}
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
				o.normal = normalize(mul(unity_WorldToObject,v.normal)).xyz;
				o.viewDir= normalize(mul(unity_ObjectToWorld,v.vertex).xyz - _WorldSpaceCameraPos );
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 reflectDir = reflect(i.viewDir,normalize(i.normal));

				return texCUBE(_Cube,reflectDir);
			}
			ENDCG
		}
	}
}
