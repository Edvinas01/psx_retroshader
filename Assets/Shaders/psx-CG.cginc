float4 _FrameBufferSize;

float4 SnapToPixel(float4 vertex)
{
	vertex.xyz = vertex.xyz / vertex.w;
	vertex.x = floor(_FrameBufferSize.z * vertex.x) / _FrameBufferSize.z;
	vertex.y = floor(_FrameBufferSize.w * vertex.y) / _FrameBufferSize.w;
	vertex.xyz *= vertex.w;
return vertex;
}

half4 FilteredTexture(sampler2D tex, float2 uv, float4 texelSize)
{
	uv = uv * texelSize.zw;

	half2 seam = floor(uv + 0.5h);
	half2 fw = abs(ddx(uv)) + abs(ddy(uv));
	uv = seam + clamp((uv - seam) / fw, -0.5h, 0.5h);

return tex2D(tex, uv * texelSize.xy);
}

