//UNITY_SHADER_NO_UPGRADE
#ifndef LOOKATROTATION_INCLUDED
#define LOOKATROTATION_INCLUDED

void LookAtRotation_float(float3 from, float3 to, out float4x4 Out)
{
    float3 zaxis = normalize(to - from);
    float3 xaxis = normalize(cross(float3(0,1,0), zaxis));
    float3 yaxis = cross(zaxis, xaxis);
    
    Out = float4x4
    (
        xaxis.x, xaxis.y, xaxis.z, 0,//dot(xaxis, -from),
        yaxis.x, yaxis.y, yaxis.z, 0,//dot(yaxis, -from),
        zaxis.x, zaxis.y, zaxis.z, 0,//dot(zaxis, -from),
        0, 0, 0, 1
    );
}

#endif //LOOKATROTATION_INCLUDED