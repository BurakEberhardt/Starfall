Shader "Unlit/Grass"
{
    Properties
    {
        _TopColor("Grass Color Top", Color) = (1,1,1,1) 
        _BottomColor("Grass Color Bottom", Color) = (1,1,1,1)
        
        _GrassWidth("Blade Width", Float) = 0.05
        _GrassWidthRandom("Blade Width Random", Float) = 0.02
        _GrassHeight("Blade Height", Float) = 0.5
        _GrassHeightRandom("Blade Height Random", Float) = 0.3
        
        _WindStrength("Wind Strength", Float) = 0.1
        
        _TessellationUniform("Tessellation Uniform", Range(1, 100)) = 1
        
        [Toggle(DISTANCE_DETAIL)] _DistanceDetail ("Toggle Blade Detail based on Camera Distance", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline"}
        LOD 100

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }
            Cull Off
            
            HLSLPROGRAM
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma require geometry
            
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            
            #define GRASS_SEGMENTS 10
            #pragma shader_feature_local _ DISTANCE_DETAIL

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial) 
            float4 _BottomColor;
            float4 _TopColor;
            
            float _GrassHeight;
            float _GrassHeightRandom;	
            float _GrassWidth;
            float _GrassWidthRandom;
            
            float _WindStrength;

            float _TessellationUniform;
            CBUFFER_END
            
            #pragma vertex Vertex
            #pragma fragment Fragment
            
            #pragma require geometry
            #pragma geometry Geometry
            
            #pragma require tessellation
			#pragma hull hull
			#pragma domain domain
            
            #include "Grass.hlsl"            
            #include "Tesselation.hlsl"            
            
            float4 Fragment (g2f i) : SV_Target
            {
                return lerp(_BottomColor, _TopColor, i.texcoord.y);
            }
            
            ENDHLSL
        }
    }
}
