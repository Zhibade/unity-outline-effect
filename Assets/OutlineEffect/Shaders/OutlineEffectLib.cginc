/* Copyright (C) 2020 - Jose Ivan Lopez Romo - All rights reserved
 *
 * This file is part of the UnityOutlineEffect project found in the
 * following repository: https://github.com/Zhibade/unity-outline-effect
 *
 * Released under MIT license. Please see LICENSE file for details.
 */

 #include "UnityCG.cginc"


/**
 * Calculates and returns a 0-1 weight value from two min/max limits and a value.
 *
 * @param Min - Low limit of the range
 * @param Max - High limit of the range
 * @param Value - Value to calulate the weight value for (inside the limits)
 *
 * @return 0-1 value representing where the given value falls in the range. 0 = Same or lower as min limit. 1 = Same or higher as max limit.
 */
inline fixed GetWeightValue(fixed Min, fixed Max, fixed Value)
{
    return saturate((Value - Min) / ((Max - Min) + 0.0000001)); // Adding small value to prevent division by zero
}

/**
 * Gets the normal value from the Depth + normals buffer for the corresponding UV
 *
 * @param DepthNormalBuffer - Camera's depth + view normal texture (output from the internal Unity shader)
 * @param Uv - UV value of the pixel to get the normals from
 *
 * @return Normals for the corresponding pixel
 */
fixed3 GetNormalsFromBuffer(sampler2D DepthNormalsBuffer, float2 Uv)
{
    fixed depthPlaceHolder; // Only used so that we can use Unity's own DecodeDepthNormal function.
    fixed3 normals;

    fixed4 data = tex2D(DepthNormalsBuffer, Uv);
    DecodeDepthNormal(data, depthPlaceHolder, normals);

    return normals;
}

/**
 * Performs the outline effect calculation based on the given depth.
 *
 * @param DepthBuffer - Camera's depth texture
 * @param ScreenSize - Camera's dimensions (in most cases this is just _ScreenParams built-in parameter)
 * @param Uv - Current pixel's UV
 * @param Width - Width of the outline (pixels)
 * @param Cutoff - Depth cutoff value for the outline. Smaller values show smaller details with an outline
 *
 * @return Outline mask as a single value (white = outline)
 */
fixed GetDepthBasedOutline(sampler2D DepthBuffer, float4 ScreenSize, float2 Uv, uint Width = 1, float Cutoff = 0.001)
{
    // Compare current pixel with neighboring pixels (up, down, left, right) to determine edges

    float2 pixelToUvRatio = float2(1 / ScreenSize.x, 1 / ScreenSize.y); 
    fixed currentDepth = tex2D(DepthBuffer, Uv).r;

    float2 uvOffset = float2(pixelToUvRatio.x * Width, pixelToUvRatio.y * Width);

    fixed leftPixelDepth = tex2D(DepthBuffer, float2(Uv.x - uvOffset.x, Uv.y)).r;
    fixed rightPixelDepth = tex2D(DepthBuffer, float2(Uv.x + uvOffset.x, Uv.y)).r;
    fixed upPixelDepth = tex2D(DepthBuffer, float2(Uv.x, Uv.y - uvOffset.y)).r;
    fixed downPixelDepth = tex2D(DepthBuffer, float2(Uv.x, Uv.y + uvOffset.y)).r;

    fixed outline = (currentDepth - leftPixelDepth) + (currentDepth - rightPixelDepth) + (currentDepth - upPixelDepth) + (currentDepth - downPixelDepth);
    fixed cutoffOutline = step(Cutoff, saturate(outline));

    return cutoffOutline;
}

/**
 * Gets the corresponding fade out mask for the given fade out distances
 *
 * @param DepthBuffer - Camera's depth buffer
 * @param Uv - UV of the current pixel
 * @param NearAndFarFadeOut - Near and far fade out start and end distances. (X & Y = Near fade out start and end, Z & W = Far fade out start and end)
 *
 * @return Fade out mask (black is completely fade out)
 */
fixed GetFadeOutMask(sampler2D DepthBuffer, float2 Uv, float4 NearAndFarFadeOut = float4(0.00001, 0.00001, 10000, 10000))
{
    // Apply near and far distance fade out

    fixed currentDepth = tex2D(DepthBuffer, Uv).r;

    fixed depthInMeters = LinearEyeDepth(currentDepth);
    fixed farDistanceWeight = GetWeightValue(NearAndFarFadeOut.z, NearAndFarFadeOut.w, depthInMeters);

    fixed nearDistanceCutoffMask = GetWeightValue(NearAndFarFadeOut.x, NearAndFarFadeOut.y, depthInMeters); // Getting black to white mask for all values beyond the near distance
    fixed farDistanceCutoffMask = (1 - farDistanceWeight); // Getting black mask for all values beyond the far distance

    return farDistanceCutoffMask * nearDistanceCutoffMask;
}

/**
 * Performs the outline effect calculation based on the given view normals.
 *
 * @param DepthNormalsBuffer - Camera's depth + view normal texture (output from the internal Unity shader)
 * @param ScreenSize - Camera's dimensions (in most cases this is just _ScreenParams built-in parameter)
 * @param Uv - Current pixel's UV
 * @param Width - Width of the outline (pixels)
 * @param Cutoff - Difference cutoff value for the outline. Smaller values show smaller details with an outline
 *
 * @return Outline mask as a single value (white = outline)
 */
fixed GetNormalBasedOutline(sampler2D DepthNormalsBuffer, float4 ScreenSize, float2 Uv, uint Width = 1, float Cutoff = 0.1)
{
    // Compare current pixel with neighboring pixels (up, down, left, right) to determine edges

    float2 pixelToUvRatio = float2(1 / ScreenSize.x, 1 / ScreenSize.y); 
    
    fixed3 currentNormal = GetNormalsFromBuffer(DepthNormalsBuffer, Uv);

    float2 uvOffset = float2(pixelToUvRatio.x * Width, pixelToUvRatio.y * Width);

    fixed3 leftPixelNormal = GetNormalsFromBuffer(DepthNormalsBuffer, float2(Uv.x - uvOffset.x, Uv.y));
    fixed3 rightPixelNormal = GetNormalsFromBuffer(DepthNormalsBuffer, float2(Uv.x + uvOffset.x, Uv.y));
    fixed3 upPixelNormal = GetNormalsFromBuffer(DepthNormalsBuffer, float2(Uv.x, Uv.y - uvOffset.y));
    fixed3 downPixelNormal = GetNormalsFromBuffer(DepthNormalsBuffer, float2(Uv.x, Uv.y + uvOffset.y));

    fixed3 normalComparison = (currentNormal - leftPixelNormal) + (currentNormal - rightPixelNormal) + (currentNormal - upPixelNormal) + (currentNormal - downPixelNormal);
    fixed cutoffOutline = step(Cutoff, saturate(length(normalComparison)));

    return cutoffOutline;
}