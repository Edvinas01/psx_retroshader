#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;
using UnityEngine.Experimental.Rendering;

public enum FrameBufferWidth
{
	_256 = 256,
	_320 = 320,
	_384 = 384,
	_512 = 512,
	_640 = 640
}

public enum FrameBufferHeight
{
	_240 = 240,
	_480 = 480
}

[ExecuteInEditMode]
public class PSXPipelineAsset : RenderPipelineAsset
{
	//15 bit 24 bit
	//Width: 256,320,384,512 or 640 pixels
	//Height: 240 or 480 pixels

	public FrameBufferWidth  w = FrameBufferWidth._256;
	public FrameBufferHeight h = FrameBufferHeight._240;

	public bool wideScreen = false;
	public bool affineInSceneView = false;

#if UNITY_EDITOR
	[MenuItem("Rendering/PSXPipeline")]
	static void PSXPipeline()
	{
		PSXPipelineAsset instance = CreateInstance<PSXPipelineAsset>();

		string path = EditorUtility.SaveFilePanelInProject("Save PSXPipeline Asset", "PSXPipelineAsset", "asset", "Please enter a file name to save the asset to");

		if(path.Length > 0)
			AssetDatabase.CreateAsset(instance, path);
	}
#endif

	protected override IRenderPipeline InternalCreatePipeline()
	{
		return new PSXPipeline(this);
	}
}
