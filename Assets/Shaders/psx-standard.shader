Shader "PSXPipeline/Standard"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Geometry" }

		Pass
		{
			Tags{ "LightMode" = "PSXPass" }
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile _AFFINE_TEXTURES _

#include "UnityCG.cginc"
#include "Assets/Shaders/psx-CG.cginc"

struct v2f
{
	float4 vertex : SV_POSITION;
#if _AFFINE_TEXTURES
	noperspective half2 uv : TEXCOORD0;
#else
	half2 uv : TEXCOORD0;
#endif
};

sampler2D _MainTex;
float4 _MainTex_ST;
float4 _MainTex_TexelSize;

v2f vert (appdata_base v)
{
	v2f o;
	float4 vertex = UnityObjectToClipPos(v.vertex);
	o.vertex = SnapToPixel(vertex);
	o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
return o;
}

half4 frag (v2f i) : SV_Target
{
	half4 col = tex2D(_MainTex, i.uv);
return col;
}
ENDCG
		}
	}
}
