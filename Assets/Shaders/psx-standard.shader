Shader "PSXPipeline/Standard"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[Toggle] _VertexColor("Vertex Color", Float) = 1.0

		[Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull", Float) = 2.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Geometry" }

		Pass
		{
			Tags{ "LightMode" = "PSXPass" }
			Cull [_Cull]

CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#pragma multi_compile_instancing

#pragma multi_compile _ _VERTEXCOLOR_ON

#pragma multi_compile _AFFINE_TEXTURES _

#include "UnityCG.cginc"
#include "Assets/Shaders/psx-CG.cginc"

struct appdata
{
	float4 vertex   : POSITION;
	float3 normal   : NORMAL;
	float4 texcoord : TEXCOORD0;
#if _VERTEXCOLOR_ON
	float4 color    : COLOR;
#endif
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
	float4 vertex : SV_POSITION;

#if _AFFINE_TEXTURES
	noperspective half2 uv : TEXCOORD0;
#else
	half2 uv      : TEXCOORD0;
#endif

#if _VERTEXCOLOR_ON
	half3 color   : TEXCOORD1;
#endif
};

sampler2D _MainTex;
float4 _MainTex_ST;
float4 _MainTex_TexelSize;

v2f vert (appdata v)
{
	v2f o;
	UNITY_SETUP_INSTANCE_ID(v);

	float4 vertex = UnityObjectToClipPos(v.vertex);
	o.vertex = SnapToPixel(vertex);
	o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
#if _VERTEXCOLOR_ON
	o.color = v.color.rgb;
#endif
return o;
}

half4 frag (v2f i) : SV_Target
{
	half4 col = tex2D(_MainTex, i.uv);
	
	//fog???

return col;
}
ENDCG
		}
	}
}
