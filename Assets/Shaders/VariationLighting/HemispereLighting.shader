Shader "Custom/HemispereLighting"
{
	Properties
	{
		_Color("Diffuse Color" , Color) = (1,1,1,1)
		_UpHemisphereColor("Up Color",Color) = (1,1,1,1)
		_LowerHemisphereColor("Low Color",Color) = (1,1,1,1)
		_UpVector("Up Vector",Vector) = (0,1,0,0)

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
				float4 col : COLOR;
			};
			uniform float4 _Color;
			uniform float4 _UpHemisphereColor;
			uniform float4 _LowerHemisphereColor;
			uniform float4 _UpVector;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				float3 normal = normalize( mul(float4(v.normal,0),unity_ObjectToWorld).xyz );
				float3 upDir  = normalize(_UpVector);
				float w       = 0.5 * ( 1 + dot (upDir,normal));

				o.col         = (w * _UpHemisphereColor + (1.0 - w) * _LowerHemisphereColor ) * _Color;
// 				float t = (1.0 - w) * _LowerHimisphereColor;
//				o.col = float4( t , 0, 0, 1);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				
				return i.col;
			}
			ENDCG
		}
	}
}
