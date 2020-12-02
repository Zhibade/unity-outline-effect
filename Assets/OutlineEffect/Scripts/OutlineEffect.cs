/* Copyright (C) 2020 - Jose Ivan Lopez Romo - All rights reserved
 *
 * This file is part of the UnityOutlineEffect project found in the
 * following repository: https://github.com/Zhibade/unity-outline-effect
 *
 * Released under MIT license. Please see LICENSE file for details.
 */

using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class OutlineEffect : VolumeComponent, IPostProcessComponent
{
    [Tooltip("Enable or disable the entire outline effect")]
    public BoolParameter isEnabled = new BoolParameter(false);

    [Tooltip("Outline color")]
    public ColorParameter outlineColor = new ColorParameter(new Color(0f, 0f, 0f));

    [Tooltip("Strength of the depth-based outline around objects")]
    public ClampedFloatParameter outlineStrength = new ClampedFloatParameter(1f, 0f, 1f);

    [Tooltip("Width of the depth-based outline around objects")]
    public ClampedIntParameter outlineWidth = new ClampedIntParameter(2, 1, 20);

    [Tooltip("Depth cutoff value for the depth-based outline. Smaller values show smaller details with an outline")]
    public ClampedFloatParameter outlineCutoffValue = new ClampedFloatParameter(0.001f, 0.00001f, 0.9f);

    [Tooltip("Start and end near fade out distance in meters.")]
    public Vector2Parameter outlineNearFadeOutLimits = new Vector2Parameter(new Vector2(0.0001f, 0.0001f));

    [Tooltip("Start and end far fade out distance in meters.")]
    public Vector2Parameter outlineFarFadeOutLimits = new Vector2Parameter(new Vector2(10000f, 10000f));

    [Tooltip("Strength of the normal-based outline around objects")]
    public ClampedFloatParameter normalOutlineStrength = new ClampedFloatParameter(1f, 0f, 1f);

    [Tooltip("Width of the normal-based outline around objects")]
    public ClampedIntParameter normalOutlineWidth = new ClampedIntParameter(1, 1, 20);

    [Tooltip("Depth cutoff value for the normal-based outline. Smaller values show smaller details with an outline")]
    public ClampedFloatParameter normalOutlineCutoffValue = new ClampedFloatParameter(0.1f, 0.00001f, 0.9f);

    [Tooltip("Fill color strength. A value of 1 completely hides the original render")]
    public ClampedFloatParameter fillStrength = new ClampedFloatParameter(1f, 0f, 1f);

    [Tooltip("Fill color")]
    public ColorParameter fillColor = new ColorParameter(new Color(0.90588f, 0.90588f, 0.83922f));

    public bool IsActive()
    {
        if (!isEnabled.value)
        {
            return false;
        }

        bool isOutlineOrFillColorShown = outlineStrength.value > 0.0f || fillStrength.value > 0.0f || normalOutlineStrength.value > 0.0f;
        bool isCutoffValueValid = outlineCutoffValue.value < 1.0f && normalOutlineCutoffValue.value < 1.0f;
        bool areNearAndFarDistancesValid = outlineNearFadeOutLimits.value.y <= outlineFarFadeOutLimits.value.x;

        return isOutlineOrFillColorShown && isCutoffValueValid && areNearAndFarDistancesValid;
    }

    public bool IsTileCompatible()
    {
        return false;
    }
}
