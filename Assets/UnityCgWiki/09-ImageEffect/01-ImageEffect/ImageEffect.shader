// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


//As mentioned, Unity comes with many ready-to-use image effects in Standard Assets > Effects > ImageEffects. 
//The C# scripts and the corresponding shader files are a great resource to learn more about the programming 
//of shader effects. Often, they are also a good starting point for your own image effects. However,
//some of the scripts and shaders are quite complex. For a smooth start, you should first look at the scripts
// "ColorCorrectionRamp" (with the shader "ColorCorrectionEffect"), "Grayscale" (with the shader "GrayscaleEffect")
// or "SepiaTone" (with the shader "SepiaToneEffect").

Shader "Custom/ImageEffect"
{
	Properties
   {
      _MainTex ("Source", 2D) = "white" {}
      _Color ("Tint", Color) = (1,1,1,1)
   }
   SubShader
   {
      Cull Off 
      ZWrite Off 
      ZTest Always

      Pass
      {
         CGPROGRAM
         #pragma vertex vertexShader
         #pragma fragment fragmentShader
			
         #include "UnityCG.cginc"

         struct vertexInput
         {
            float4 vertex : POSITION;
            float2 texcoord : TEXCOORD0;
         };

         struct vertexOutput
         {
            float2 texcoord : TEXCOORD0;
            float4 position : SV_POSITION;
         };

         vertexOutput vertexShader(vertexInput i)
         {
            vertexOutput o;
            o.position = UnityObjectToClipPos(i.vertex);
            o.texcoord = i.texcoord;
            return o;
         }
			
         sampler2D _MainTex;
         float4 _MainTex_ST;
         float4 _Color;

         float4 fragmentShader(vertexOutput i) : COLOR
         {
            float4 color = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(i.texcoord, _MainTex_ST));		
            return color * _Color;
         }
         ENDCG
      }
   }
   Fallback Off
}