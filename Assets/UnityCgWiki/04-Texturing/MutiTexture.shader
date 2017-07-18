Shader "Custom/MutiTexture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NightTex ("Texture2",2D) = "white" {}
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

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float isdaytime : TEXCOORD1;
			};

			uniform sampler2D _MainTex;
			uniform sampler2D _NightTex;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv     = v.uv;
				float3 lightDir  = normalize(_WorldSpaceLightPos0.xyz);
				float3 normalDir = normalize(mul(float4(v.normal,0),unity_WorldToObject).xyz);
				o.isdaytime = max(0,dot(lightDir,normalDir));
				return o;
			}
			
			float4 frag (v2f i) : COLOR
			{
				
				fixed4 col1 = tex2D(_MainTex, i.uv);
				float4 col2 = tex2D(_NightTex,i.uv);
				return lerp(col2,col1,i.isdaytime);

			}
			ENDCG
		}
	}
//	Fallback "Unlit/Transparent"
}
