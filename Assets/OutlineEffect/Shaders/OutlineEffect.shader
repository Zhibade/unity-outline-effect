/* Copyright (C) 2024 - Jose Ivan Lopez Romo - All rights reserved
 *
 * This file is part of the UnityOutlineEffect project found in the
 * following repository: https://github.com/Zhibade/unity-outline-effect
 *
 * Released under MIT license. Please see LICENSE file for details.
 */

Shader "Hidden/OutlineEffect"
{
    Properties
    {
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineStrength ("Outline Strength", Range(0, 1)) = 1.0
        _OutlineWidth ("Outline Width", Int) = 2
        _OutlineCutoff ("Outline Cutoff", Range(0, 1)) = 0.001
        _OutlineNearAndFarFadeOut ("Outline Near and Far Fade Out Limits", Vector) = (0.00001, 0.00001, 10000, 10000)

        _NormalOutlineStrength ("Normal Outline Strength", Range(0, 1)) = 1.0
        _NormalOutlineWidth ("Normal Outline Width", Int) = 1
        _NormalOutlineCutoff ("Normal Outline Cutoff", Range(0, 1)) = 0.1

        _FillStrength ("Fill Strength", Range(0, 1)) = 1.0
        _FillColor ("Fill Color", Color) = (1, 0, 0, 1)
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}
        LOD 100
        ZWrite Off Cull Off
        Pass
        {
            Name "Outline"

            HLSLPROGRAM
            
            #pragma vertex Vert
            #pragma fragment Outline

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            #include "OutlineEffectLib.hlsl"

            // -------------------------------------
            // Properties
            half4 _OutlineColor;
            half _OutlineStrength;
            int _OutlineWidth;
            float _OutlineCutoff;
            float4 _OutlineNearAndFarFadeOut;

            half _NormalOutlineStrength;
            int _NormalOutlineWidth;
            float _NormalOutlineCutoff;

            half _FillStrength;
            half4 _FillColor;

            // -------------------------------------
            // Outline fragment function
            half4 Outline(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)

                // Camera buffer + fill color composite

                half4 render = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, input.texcoord);
                half4 bgRenderComposite = lerp(render, _FillColor, _FillStrength);

                // Get outlines and composite together

                half depthOutlineMask = GetDepthBasedOutline(_ScreenParams, input.texcoord, _OutlineWidth, _OutlineCutoff); // White = outline

                half normalOutlineMask = GetNormalBasedOutline(_ScreenParams, input.texcoord, _NormalOutlineWidth, _NormalOutlineCutoff); // While = outline
                normalOutlineMask = lerp(0, normalOutlineMask, _NormalOutlineStrength);

                half outline = saturate(depthOutlineMask + normalOutlineMask);

                // Get fade out mask and apply it to the final outline

                float4 nearAndFarFadeOut = float4(_OutlineNearAndFarFadeOut.x, _OutlineNearAndFarFadeOut.y, _OutlineNearAndFarFadeOut.z, _OutlineNearAndFarFadeOut.w);

                half fadeOutMask = GetFadeOutMask(input.texcoord, nearAndFarFadeOut);
                outline *= fadeOutMask;

                // Do final composite of fill + colored outline

                half4 composite = lerp(bgRenderComposite, _OutlineColor, outline * _OutlineStrength); // Composite with background
                return composite;
            }
            
            ENDHLSL
        }
    }
}
