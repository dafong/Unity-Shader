Shader "Custom/Shadow/ProjectorShadow"
{
	Properties
	{
		_RenderTexture ("Texture", 2D) = "white" {}
		_MaskTexture("Mask Texture", 2D)  = "white" {}
	}
	SubShader
	{
		ZWrite Off
		Offset -1, -1

		Blend DSTCOLOR ZERO
		Tags { "RenderQueue"="Transparent" }
		LOD 100

		Pass
		{


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"


			sampler2D _RenderTexture; 
 			sampler2D _MaskTexture;
         
            float4x4 unity_Projector;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 uvProj : TEXCOORD1;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};


			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uvProj = mul(unity_Projector,v.vertex);
				o.uv = v.uv;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2Dproj(_RenderTexture,UNITY_PROJ_COORD(i.uvProj));
				fixed4 mask= tex2Dproj(_MaskTexture,UNITY_PROJ_COORD(i.uvProj));
				// apply fog

				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
