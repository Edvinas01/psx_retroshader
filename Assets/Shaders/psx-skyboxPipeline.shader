Shader "PSXPipeline/Skybox"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		[Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull", Float) = 2.0
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
		Pass
		{
			Tags{ "LightMode" = "PSXPass" }
			Cull[_Cull]

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#pragma multi_compile _AFFINE_TEXTURES _
			
			#include "UnityCG.cginc"
			#include "Assets/Shaders/psx-CG.cginc"

			struct appdata
			{
				float4 vertex   : POSITION;
				float3 normal   : NORMAL;
				float4 texcoord : TEXCOORD0;
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
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);

				float4 vertex = UnityObjectToClipPos(v.vertex);
				o.vertex = SnapToPixel(vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv);
				col.rgb = floor(col.rgb * 32.0) / 32.0;
				return col;
			}
			ENDCG
		}
	}
}