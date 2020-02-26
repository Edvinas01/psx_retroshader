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

				half4 colorFog : COLOR1;
				half3 normal : TEXCOORD1;
			#if _VERTEXCOLOR_ON
				half3 color   : TEXCOORD2;
			#endif
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			uniform half4 unity_FogStart;
			uniform half4 unity_FogEnd;

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

				float distance = length(mul(UNITY_MATRIX_MV, v.vertex));

				//Fog
				float4 fogColor = unity_FogColor;

				float fogDensity = (unity_FogEnd - distance) / (unity_FogEnd - unity_FogStart);
				o.normal.g = fogDensity;
				o.normal.b = 1;
				o.colorFog = fogColor;
				o.colorFog.a = clamp(fogDensity, 0, 1);

				// Cut out polygons
				if (distance > unity_FogStart.z + unity_FogColor.a * 255)
				{
					o.vertex = sqrt(-1.0);
				}
				return o;
			}

			// half4 c = tex2D(_MainTex, IN.uv_MainTex / IN.normal.r)*IN.color;

			half4 frag (v2f i) : SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv);
			#if _VERTEXCOLOR_ON
				col.rgb *= i.color;
			#endif
				col.rgb = floor(col.rgb * 32.0) / 32.0;

				// Fog
				half4 color = col * (i.colorFog.a);
				color.rgb += i.colorFog.rgb*(1 - i.colorFog.a);

				return color;
			}
			ENDCG
		}
	}
}
