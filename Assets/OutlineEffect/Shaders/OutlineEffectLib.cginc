/* Copyright (C) 2020 - Jose Ivan Lopez Romo - All rights reserved
 *
 * This file is part of the UnityOutlineEffect project found in the
 * following repository: https://github.com/Zhibade/unity-outline-effect
 *
 * Released under MIT license. Please see LICENSE file for details.
 */

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
inline fixed GetDepthBasedOutline(sampler2D DepthBuffer, float4 ScreenSize, float2 Uv, uint Width = 1, float Cutoff = 0.001)
{
    // Compare current pixel with neighboring pixels (up, down, left, right)

    float2 pixelToUvRatio = float2(1 / ScreenSize.x, 1 / ScreenSize.y); 
    fixed currentDepth = tex2D(DepthBuffer, Uv).r;

    float2 uvOffset = float2(pixelToUvRatio.x * Width, pixelToUvRatio.y * Width);

    fixed leftPixelDepth = tex2D(DepthBuffer, float2(Uv.x - uvOffset.x, Uv.y)).r;
    fixed rightPixelDepth = tex2D(DepthBuffer, float2(Uv.x + uvOffset.x, Uv.y)).r;
    fixed upPixelDepth = tex2D(DepthBuffer, float2(Uv.x, Uv.y - uvOffset.y)).r;
    fixed downPixelDepth = tex2D(DepthBuffer, float2(Uv.x, Uv.y + uvOffset.y)).r;

    fixed outline = (currentDepth - leftPixelDepth) + (currentDepth - rightPixelDepth) + (currentDepth - upPixelDepth) + (currentDepth - downPixelDepth);
    return step(Cutoff, saturate(outline));
}