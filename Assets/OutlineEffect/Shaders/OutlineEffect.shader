﻿/* Copyright (C) 2020 - Jose Ivan Lopez Romo - All rights reserved
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
        _MainTex ("Texture", 2D) = "white" {}

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
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "OutlineEffectLib.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture; // Depth-buffer already provided by the engine
            sampler2D _CameraDepthNormalsTexture; // Depth + normals buffer generated by the "Depth Normals" render feature

            fixed4 _OutlineColor;
            fixed _OutlineStrength;
            int _OutlineWidth;
            float _OutlineCutoff;
            float4 _OutlineNearAndFarFadeOut;

            fixed _NormalOutlineStrength;
            int _NormalOutlineWidth;
            float _NormalOutlineCutoff;

            fixed _FillStrength;
            fixed4 _FillColor;

            fixed4 frag (v2f i) : SV_Target
            {
                // Camera buffer + fill color composite

                fixed4 render = tex2D(_MainTex, i.uv);
                fixed4 bgRenderComposite = lerp(render, _FillColor, _FillStrength);

                // Get outlines and composite together

                fixed depthOutlineMask = GetDepthBasedOutline(_CameraDepthTexture, _ScreenParams, i.uv,
                                                              _OutlineWidth, _OutlineCutoff); // White = outline

                fixed normalOutlineMask = GetNormalBasedOutline(_CameraDepthNormalsTexture, _ScreenParams, i.uv,
                                                                _NormalOutlineWidth, _NormalOutlineCutoff); // While = outline
                normalOutlineMask = lerp(0, normalOutlineMask, _NormalOutlineStrength);

                fixed outline = saturate(depthOutlineMask + normalOutlineMask);

                // Get fade out mask and apply it to the final outline

                float4 nearAndFarFadeOut = float4(_OutlineNearAndFarFadeOut.x, _OutlineNearAndFarFadeOut.y,
                                                  _OutlineNearAndFarFadeOut.z, _OutlineNearAndFarFadeOut.w);

                fixed fadeOutMask = GetFadeOutMask(_CameraDepthTexture, i.uv, nearAndFarFadeOut);
                outline *= fadeOutMask;

                // Do final composite of fill + colored outline

                fixed4 composite = lerp(bgRenderComposite, _OutlineColor, outline * _OutlineStrength); // Composite with background
                return composite;
            }
            ENDCG
        }
    }
}
