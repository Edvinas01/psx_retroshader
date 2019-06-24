using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;

public class PSXShaderLib
{
	public static int ColorRT = Shader.PropertyToID("ColorRT");

	public class Passes
	{
		public static ShaderPassName PSXPass = new ShaderPassName("PSXPass");
	}

	public class Keywords
	{
		public static string _AFFINE_TEXTURES = "_AFFINE_TEXTURES";
	}

	public class Uniforms
	{
		public static int FrameBufferSize = Shader.PropertyToID("_FrameBufferSize");
	}


}
