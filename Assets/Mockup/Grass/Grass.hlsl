struct appdata
{
    float4 positionOS   : POSITION;
    float3 normal       : NORMAL;
    float4 tangent      : TANGENT;
    float2 texcoord		: TEXCOORD0;
};

struct Varyings
{
    float3 positionWS	: TEXCOORD1;
    float3 positionVS	: TEXCOORD2;
    float3 positionOS	: TEXCOORD3;
    float3 normal		: TEXCOORD4;
    float4 tangent		: TEXCOORD5;
    float2 texcoord		: TEXCOORD0;
};

struct g2f
{
    float4 positionCS   : SV_POSITION;
    float2 texcoord     : TEXCOORD0;
};


// Rotation with angle (in radians) and axis
float3x3 AngleAxis3x3(float angle, float3 axis)
{
    float c, s;
    sincos(angle, s, c);

    float t = 1 - c;
    float x = axis.x;
    float y = axis.y;
    float z = axis.z;

    return float3x3(
        t * x * x + c,      t * x * y - s * z,  t * x * z + s * y,
        t * x * y + s * z,  t * y * y + c,      t * y * z - s * x,
        t * x * z - s * y,  t * y * z + s * x,  t * z * z + c
    );
}

float rand(float3 seed) 
{
    return frac(sin(dot(seed.xyz, float3(12.9898, 78.233, 53.539))) * 43758.5453);
}

Varyings Vertex(appdata v)
{
    Varyings o;
    VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS.xyz);
    o.positionWS = vertexInput.positionWS;
    o.positionOS = v.positionOS.xyz;
    o.positionVS = vertexInput.positionVS;
    o.normal = TransformObjectToWorldNormal(v.normal);
    o.tangent = float4(TransformObjectToWorldNormal(v.tangent.xyz), v.tangent.w);
    return o;
}

g2f VertexOutput(float3 pos, float2 uv)
{
    g2f o;
    o.positionCS = TransformWorldToHClip(pos.xyz);
    o.texcoord = uv;
    return o;
}

float easeOutExpo(float x) 
{
    return x == 1 ? 1 : 1 - pow(2, -10 * x);
} 

[maxvertexcount(GRASS_SEGMENTS * 2 + 1 + 3)]
void Geometry(triangle Varyings input[3], inout TriangleStream<g2f> triStream)
{
    float3 cameraPos = _WorldSpaceCameraPos;
    float3 positionWS = (input[0].positionWS + input[1].positionWS + input[2].positionWS) / 3;
	
	#ifdef DISTANCE_DETAIL
		float3 vtcam = cameraPos - positionWS;
		float distSqr = dot(vtcam, vtcam);
		float dist = length(vtcam);
		float t = easeOutExpo(saturate(dist / 30));
		int grassSegments = lerp(GRASS_SEGMENTS, 1, t);
	#else
		int grassSegments = GRASS_SEGMENTS;
	#endif
	
	
    if (input[0].positionVS.z > 0 || grassSegments <= 0)
    {
        triStream.Append(VertexOutput(input[0].positionWS, float2(0,0)));
        triStream.Append(VertexOutput(input[1].positionWS, float2(0,1)));
        triStream.Append(VertexOutput(input[2].positionWS, float2(0,.5)));
        triStream.RestartStrip();
		return;
    }
	else
	{
        triStream.Append(VertexOutput(input[0].positionWS, input[0].texcoord));
        triStream.Append(VertexOutput(input[1].positionWS, input[1].texcoord));
        triStream.Append(VertexOutput(input[2].positionWS, input[2].texcoord));
        triStream.RestartStrip();
	}
		
    //Varyings p = input[0];
    //float3 positionWS = p.positionWS;
    //float3 normal = p.normal; 
    //float4 tangent = p.tangent;
    //float3 binormal = cross(normal, tangent) * tangent.w;
    float3 positionOS = (input[0].positionOS + input[1].positionOS + input[2].positionOS) / 3;
    float3 normal = (input[0].normal + input[1].normal + input[2].normal) / 3;
    float4 tangent = (input[0].tangent + input[1].tangent + input[2].tangent) / 3;
    float3 binormal = cross(normal, tangent) * ((input[0].tangent.w + input[1].tangent.w + input[2].tangent.w) / 3);
    
    float3x3 tangentToLocal  = float3x3(
        tangent.x, binormal.x, normal.x,
        tangent.y, binormal.y, normal.y,
        tangent.z, binormal.z, normal.z);

    float r = rand(positionOS.xyz);
    float3x3 randRotation = AngleAxis3x3(r * TWO_PI, float3(0,0,1));
    
    float3x3 windMatrix;
	if (_WindStrength != 0)
	{
		float2 wind = float2(sin(_Time.y + positionWS.x * 0.5), cos(_Time.y + positionWS.z * 0.5)) * _WindStrength * sin(_Time.y + r) * float2(0.5, 1);
		windMatrix = AngleAxis3x3((wind * PI).y, normalize(float3(wind.x, wind.x, wind.y)));
	} 
	else 
	{
		windMatrix = float3x3(1,0,0,0,1,0,0,0,1);
	}
	
    float3x3 transformMatrix = mul(tangentToLocal, randRotation);
	float3x3 transformMatrixWithWind = mul(mul(tangentToLocal, windMatrix), randRotation);
    
    float bend = rand(positionOS.xyz) - 0.5;
    float width = _GrassWidth + _GrassWidthRandom * (rand(positionOS.zyx) - 0.5);
    float height = _GrassHeight + _GrassHeightRandom * (rand(positionOS.yxz) - 0.5);
    
    triStream.Append(VertexOutput(positionWS + mul(transformMatrix, float3(-width, 0, 0)), float2(0, 0)));
    triStream.Append(VertexOutput(positionWS + mul(transformMatrix, float3(width, 0, 0)), float2(1, 0)));
    
    for(int i = 1; i < grassSegments; ++i)
    {
        float t = i / (float)grassSegments;
        
        float h = height * t;
        float w = width * (1-t);
        float b = bend * pow(t, 2);
    
        triStream.Append(VertexOutput(positionWS + mul(transformMatrixWithWind, float3(-w, b, h)), float2(0, t)));
        triStream.Append(VertexOutput(positionWS + mul(transformMatrixWithWind, float3(w, b, h)), float2(1, t)));
    }
    
    triStream.Append(VertexOutput(positionWS + mul(transformMatrixWithWind, float3(0, bend, height)), float2(.5, 1)));
    triStream.RestartStrip();
}
