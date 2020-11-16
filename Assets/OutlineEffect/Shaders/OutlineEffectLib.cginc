/* Copyright (C) 2020 - Jose Ivan Lopez Romo - All rights reserved
 *
 * This file is part of the UnityOutlineEffect project found in the
 * following repository: https://github.com/Zhibade/unity-outline-effect
 *
 * Released under MIT license. Please see LICENSE file for details.
 */

 #include "UnityCG.cginc"

/**
 * Performs the outline effect calculation based on the given depth.
 *
 * @param DepthBuffer - Camera's depth texture
 * @param ScreenSize - Camera's dimensions (in most cases this is just _ScreenParams built-in parameter)
 * @param Uv - Current pixel's UV
 * @param Width - Width of the outline (pixels)
 * @param Cutoff - Depth cutoff value for the outline. Smaller values show smaller details with an outline
 * @param NearAndFarDistance - Near and far distance limits for the outline
 *
 * @return Outline mask as a single value (white = outline)
 */
fixed GetDepthBasedOutline(sampler2D DepthBuffer, float4 ScreenSize, float2 Uv, uint Width = 1,
                           float Cutoff = 0.001, float2 NearAndFarDistance = float2(0.00001, 10000))
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

    // Apply near and far distance limits

    fixed depthInMeters = LinearEyeDepth(currentDepth);
    fixed nearDistanceCutoffMask = step(NearAndFarDistance.x, depthInMeters); // Getting white mask for all values beyond the near distance
    fixed farDistanceCutoffMask = (1 - step(NearAndFarDistance.y, depthInMeters)); // Getting black mask for all values beyond the far distance

    // Composite outline with distance mask

    return cutoffOutline * farDistanceCutoffMask * nearDistanceCutoffMask;
}