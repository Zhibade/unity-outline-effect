/* Copyright (C) 2020 - Jose Ivan Lopez Romo - All rights reserved
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

        _OutlineStrength ("Outline Strength", Range(0, 1)) = 1.0
        _OutlineWidth ("Outline Width", Int) = 2
        _OutlineCutoff ("Outline Cutoff", Range(0,1)) = 0.001
        _OutlineNearLimit ("Outline Near Distance Limit", Range(0, 1000000)) = 0.00001
        _OutlineFarLimit ("Outline Far Distance Limit", Range(0, 1000000)) = 10000

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

            fixed _OutlineStrength;
            int _OutlineWidth;
            float _OutlineCutoff;
            float _OutlineNearLimit;
            float _OutlineFarLimit;

            fixed _FillStrength;
            fixed4 _FillColor;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);

                fixed outlineMask = GetDepthBasedOutline(_CameraDepthTexture, _ScreenParams, i.uv,
                                                         _OutlineWidth, _OutlineCutoff, float2(_OutlineNearLimit, _OutlineFarLimit)); // White = outline

                outlineMask = 1 - outlineMask; // Invert mask so that the outline is black
                outlineMask = lerp(1, outlineMask, _OutlineStrength); // Apply outline strength

                fixed4 composite = lerp(color * outlineMask, _FillColor * outlineMask, _FillStrength); // Composite with camera render
                return composite;
            }
            ENDCG
        }
    }
}
