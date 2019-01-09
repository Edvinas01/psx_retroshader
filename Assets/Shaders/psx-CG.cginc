float4 _FrameBufferSize;

float4 SnapToPixel(float4 vertex)
{
	vertex.xyz = vertex.xyz / vertex.w;
	vertex.x = floor(_FrameBufferSize.z * vertex.x) / _FrameBufferSize.z;
	vertex.y = floor(_FrameBufferSize.w * vertex.y) / _FrameBufferSize.w;
	vertex.xyz *= vertex.w;
return vertex;
}
