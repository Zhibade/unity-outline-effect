/* Copyright (C) 2024 - Jose Ivan Lopez Romo - All rights reserved
 *
 * This file is part of the UnityOutlineEffect project found in the
 * following repository: https://github.com/Zhibade/unity-outline-effect
 *
 * Released under MIT license. Please see LICENSE file for details.
 */

#ifndef OUTLINE_EFFECT_LIB_INCLUDED
#define OUTLINE_EFFECT_LIB_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"

/**
 * Calculates and returns a 0-1 weight value from two min/max limits and a value.
 *
 * @param Min - Low limit of the range
 * @param Max - High limit of the range
 * @param Value - Value to calulate the weight value for (inside the limits)
 *
 * @return 0-1 value representing where the given value falls in the range. 0 = Same or lower as min limit. 1 = Same or higher as max limit.
 */
inline half GetWeightValue(half Min, half Max, half Value)
{
    return saturate((Value - Min) / ((Max - Min) + 0.0000001)); // Adding small value to prevent division by zero
}

/**
 * Samples scene depth texture (taking into account if it is reversed depth or not)
 *
 * @param Uv - Current pixel's UV
 *
 * @return Pixel depth value
 */
inline half SampleDepth(float2 Uv)
{
    half sceneDepth = SampleSceneDepth(Uv);
#if !UNITY_REVERSED_Z
        sceneDepth = 1.0 - sceneDepth;
#endif

    return sceneDepth;
}

/**
 * Performs the outline effect calculation based on the given depth.
 *
 * @param ScreenSize - Camera's dimensions (in most cases this is just _ScreenParams built-in parameter)
 * @param Uv - Current pixel's UV
 * @param Width - Width of the outline (pixels)
 * @param Cutoff - Depth cutoff value for the outline. Smaller values show smaller details with an outline
 *
 * @return Outline mask as a single value (white = outline)
 */
half GetDepthBasedOutline(float4 ScreenSize, float2 Uv, uint Width = 1, float Cutoff = 0.001)
{
    // Compare current pixel with neighboring pixels (up, down, left, right) to determine edges

    float2 pixelToUvRatio = float2(1 / ScreenSize.x, 1 / ScreenSize.y); 
    half currentDepth = SampleDepth(Uv);

    float2 uvOffset = float2(pixelToUvRatio.x * Width, pixelToUvRatio.y * Width);

    half leftPixelDepth = SampleDepth(float2(Uv.x - uvOffset.x, Uv.y));
    half rightPixelDepth = SampleDepth(float2(Uv.x + uvOffset.x, Uv.y));
    half upPixelDepth = SampleDepth(float2(Uv.x, Uv.y - uvOffset.y));
    half downPixelDepth = SampleDepth(float2(Uv.x, Uv.y + uvOffset.y));

    half outline = (currentDepth - leftPixelDepth) + (currentDepth - rightPixelDepth) + (currentDepth - upPixelDepth) + (currentDepth - downPixelDepth);
    half cutoffOutline = step(Cutoff, saturate(outline));

    return cutoffOutline;
}

/**
 * Gets the corresponding fade out mask for the given fade out distances
 *
 * @param Uv - UV of the current pixel
 * @param NearAndFarFadeOut - Near and far fade out start and end distances. (X & Y = Near fade out start and end, Z & W = Far fade out start and end)
 *
 * @return Fade out mask (black is completely fade out)
 */
half GetFadeOutMask(float2 Uv, float4 NearAndFarFadeOut = float4(0.00001, 0.00001, 10000, 10000))
{
    // Apply near and far distance fade out

    half currentDepth = SampleDepth(Uv);

    half depthInMeters = LinearEyeDepth(currentDepth, _ZBufferParams);
    half farDistanceWeight = GetWeightValue(NearAndFarFadeOut.z, NearAndFarFadeOut.w, depthInMeters);

    half nearDistanceCutoffMask = GetWeightValue(NearAndFarFadeOut.x, NearAndFarFadeOut.y, depthInMeters); // Getting black to white mask for all values beyond the near distance
    half farDistanceCutoffMask = (1 - farDistanceWeight); // Getting black mask for all values beyond the far distance

    return farDistanceCutoffMask * nearDistanceCutoffMask;
}

/**
 * Performs the outline effect calculation based on the given view normals.
 *
 * @param ScreenSize - Camera's dimensions (in most cases this is just _ScreenParams built-in parameter)
 * @param Uv - Current pixel's UV
 * @param Width - Width of the outline (pixels)
 * @param Cutoff - Difference cutoff value for the outline. Smaller values show smaller details with an outline
 *
 * @return Outline mask as a single value (white = outline)
 */
half GetNormalBasedOutline(float4 ScreenSize, float2 Uv, uint Width = 1, float Cutoff = 0.1)
{
    // Compare current pixel with neighboring pixels (up, down, left, right) to determine edges

    float2 pixelToUvRatio = float2(1 / ScreenSize.x, 1 / ScreenSize.y); 
    half3 currentNormal = SampleSceneNormals(Uv);

    float2 uvOffset = float2(pixelToUvRatio.x * Width, pixelToUvRatio.y * Width);

    half3 leftPixelNormal = SampleSceneNormals(float2(Uv.x - uvOffset.x, Uv.y));
    half3 rightPixelNormal = SampleSceneNormals(float2(Uv.x + uvOffset.x, Uv.y));
    half3 upPixelNormal = SampleSceneNormals(float2(Uv.x, Uv.y - uvOffset.y));
    half3 downPixelNormal = SampleSceneNormals(float2(Uv.x, Uv.y + uvOffset.y));

    half3 normalComparison = (currentNormal - leftPixelNormal) + (currentNormal - rightPixelNormal) + (currentNormal - upPixelNormal) + (currentNormal - downPixelNormal);
    half cutoffOutline = step(1 - Cutoff, saturate(length(normalComparison)));

    return cutoffOutline;
}

#endif // OUTLINE_EFFECT_LIB_INCLUDED