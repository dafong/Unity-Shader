Shader "Custom/UVScroll"
{
	Properties
	{
		_BgTex ("Background Texture", 2D) = "white" {}
		_FgTex ("Foreground Texture", 2D) = "white" {}
		_BgSpeed ("Back Speed" , Float ) = 1
		_FgSpeed ("Fore Speed",Float )   = 1
		_MainTex("Main Texture" ,2D) = "white"{}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 buv : TEXCOORD0;
				float2 fuv : TEXCOORD1;
			};

			struct v2f
			{
				float2 buv : TEXCOORD0;
				float2 fuv : TEXCOORD1;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _BgTex;
			sampler2D _FgTex;
			float4 _BgTex_ST;
			float4 _FgTex_ST;
			float _BgSpeed;
			float _FgSpeed;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.buv = TRANSFORM_TEX(v.buv , _BgTex) + frac(float2( _Time.x * _BgSpeed,0));
				o.fuv = TRANSFORM_TEX(v.fuv , _FgTex) + frac(float2( _Time.x * _FgSpeed,0));
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				
				fixed4 bcol= tex2D(_BgTex,i.buv);
				fixed4 fcol= tex2D(_FgTex,i.fuv);

				// sample the texture
				fixed4 col = lerp(bcol,fcol,fcol.a);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
