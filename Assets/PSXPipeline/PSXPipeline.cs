using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;

public class PSXPipeline : RenderPipeline
{
	private readonly PSXPipelineAsset m_Asset;
	public PSXPipeline(PSXPipelineAsset asset)
	{
		m_Asset = asset;
	}

	private CullResults cullResults;

	private int colorRT = Shader.PropertyToID("ColorRT");

	private CommandBuffer clear_CommandBuffer = new CommandBuffer
	{
		name = "Clear"
	};
	private CommandBuffer blit_CommandBuffer = new CommandBuffer
	{
		name = "Blit"
	};

	public override void Render(ScriptableRenderContext context, Camera[] cameras)
	{
		base.Render(context, cameras);
		GraphicsSettings.lightsUseLinearIntensity = true;

		Shader.EnableKeyword("_AFFINE_TEXTURES");

		Vector4 frameBufferSize = new Vector4((float)m_Asset.w, (float)m_Asset.h, (float)m_Asset.w / 2.0f, (float)m_Asset.h / 2.0f);
		Shader.SetGlobalVector("_FrameBufferSize", frameBufferSize);
		
		foreach(Camera camera in cameras)
		{
			bool sceneViewCamera = camera.cameraType == CameraType.SceneView;
			bool gameViewCamera  = camera.cameraType == CameraType.Game;

			// Culling
			ScriptableCullingParameters cullingParams;
			if(!CullResults.GetCullingParameters(camera, out cullingParams))
				continue;

			if(sceneViewCamera && m_Asset.affineInSceneView == false)
				Shader.DisableKeyword("_AFFINE_TEXTURES");
			else
				Shader.EnableKeyword("_AFFINE_TEXTURES");

#if UNITY_EDITOR
			if(sceneViewCamera)
				ScriptableRenderContext.EmitWorldGeometryForSceneView(camera);
#endif

			CullResults.Cull(ref cullingParams, context, ref cullResults);

			context.SetupCameraProperties(camera);

			//Clear
			if(gameViewCamera == true)
			{
				RenderTextureDescriptor colorRT_desc = new RenderTextureDescriptor((int)m_Asset.w, (int)m_Asset.h, RenderTextureFormat.Default, 16);

				clear_CommandBuffer.GetTemporaryRT(colorRT, colorRT_desc);
				clear_CommandBuffer.SetRenderTarget(colorRT);
			}
			clear_CommandBuffer.ClearRenderTarget(true, true, Color.black);
			context.ExecuteCommandBuffer(clear_CommandBuffer);
			clear_CommandBuffer.Clear();

			// Opaque
			DrawRendererSettings d_settings = new DrawRendererSettings(camera, new ShaderPassName("PSXPass"));
			d_settings.sorting.flags = SortFlags.CommonOpaque;

			FilterRenderersSettings f_settings = new FilterRenderersSettings(true);
			f_settings.renderQueueRange = RenderQueueRange.opaque;

			context.DrawRenderers(cullResults.visibleRenderers, ref d_settings, f_settings);
			context.DrawSkybox(camera);

			if(gameViewCamera == true)
			{
				blit_CommandBuffer.Blit(colorRT, BuiltinRenderTextureType.CameraTarget);
				context.ExecuteCommandBuffer(blit_CommandBuffer);
				blit_CommandBuffer.Clear();
			}

			context.Submit();
		}
	}

	public override void Dispose()
	{
		base.Dispose();
	}

}
