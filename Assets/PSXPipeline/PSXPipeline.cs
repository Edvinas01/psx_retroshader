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

	//
	private CullResults cullResults;
	private ScriptableCullingParameters cullingParams;
	private DrawRendererSettings    drawSettings;
	private FilterRenderersSettings filterSettings;

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

		Vector4 frameBufferSize = new Vector4((float)m_Asset.w, (float)m_Asset.h, (float)m_Asset.w / 2.0f, (float)m_Asset.h / 2.0f);
		Shader.SetGlobalVector(PSXShaderLib.Uniforms.FrameBufferSize, frameBufferSize);
		
		foreach(Camera camera in cameras)
		{
			bool sceneViewCamera = camera.cameraType == CameraType.SceneView;
			bool gameViewCamera  = camera.cameraType == CameraType.Game;


			if(sceneViewCamera && m_Asset.affineInSceneView == false)
				Shader.DisableKeyword(PSXShaderLib.Keywords._AFFINE_TEXTURES);
			else
				Shader.EnableKeyword(PSXShaderLib.Keywords._AFFINE_TEXTURES);

			
			// Culling
			if(!CullResults.GetCullingParameters(camera, out cullingParams))
				continue;

#if UNITY_EDITOR
			if(sceneViewCamera)
				ScriptableRenderContext.EmitWorldGeometryForSceneView(camera);
#endif
			
			CullResults.Cull(ref cullingParams, context, ref cullResults);
			context.SetupCameraProperties(camera);

			
			//Clear
			if(gameViewCamera == true)
			{
				int w = (int)m_Asset.w;
				int h = (int)m_Asset.h;

				if(m_Asset.wideScreen == true)
				{
					int sw = Screen.width;
					int sh = Screen.height;
					float aspectRatio = (float)sw / (float)sh;

					//w = (int)(w / 12.0f * 16.0f);
				}
				RenderTextureDescriptor colorRT_desc = new RenderTextureDescriptor(w, h,RenderTextureFormat.ARGB32, 16);

				clear_CommandBuffer.GetTemporaryRT (PSXShaderLib.ColorRT, colorRT_desc);
				clear_CommandBuffer.SetRenderTarget(PSXShaderLib.ColorRT);
			}

			clear_CommandBuffer.ClearRenderTarget(true, true, Color.black);
			context.ExecuteCommandBuffer(clear_CommandBuffer);
			clear_CommandBuffer.Clear();


			//Opaque
			drawSettings = new DrawRendererSettings(camera, PSXShaderLib.Passes.PSXPass);
			drawSettings.sorting.flags = SortFlags.CommonOpaque;

			filterSettings = new FilterRenderersSettings(true);
			filterSettings.renderQueueRange = RenderQueueRange.opaque;

			context.DrawRenderers(cullResults.visibleRenderers, ref drawSettings, filterSettings);
			context.DrawSkybox(camera);

			
			//Transparent
			drawSettings.sorting.flags = SortFlags.CommonTransparent;
			filterSettings.renderQueueRange = RenderQueueRange.transparent;
			context.DrawRenderers(cullResults.visibleRenderers, ref drawSettings, filterSettings);

			if(gameViewCamera == true)
			{
				blit_CommandBuffer.Blit(PSXShaderLib.ColorRT, BuiltinRenderTextureType.CameraTarget);
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
