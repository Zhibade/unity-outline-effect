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
    [Tooltip("Strength of the outline around objects")]
    public FloatParameter outlineStrength = new FloatParameter(1.0f);

    [Tooltip("Width of the outline around objects")]
    public IntParameter outlineWidth = new IntParameter(2);

    [Tooltip("Depth cutoff value for the outline. Smaller values show smaller details with an outline")]
    public FloatParameter outlineCutoffValue = new FloatParameter(0.001f);

    [Tooltip("Start and end near fade out distance in meters.")]
    public Vector2Parameter outlineNearFadeOutLimits = new Vector2Parameter(new Vector2(0.0001f, 0.0001f));

    [Tooltip("Start and end far fade out distance in meters.")]
    public Vector2Parameter outlineFarFadeOutLimits = new Vector2Parameter(new Vector2(10000f, 10000f));

    [Tooltip("Fill color strength. A value of 1 completely hides the original render")]
    public FloatParameter fillStrength = new FloatParameter(1.0f);

    [Tooltip("Fill color")]
    public ColorParameter fillColor = new ColorParameter(new Color(0.90588f, 0.90588f, 0.83922f));

    public bool IsActive()
    {
        bool isOutlineOrFillColorShown = outlineStrength.value > 0.0f || fillStrength.value > 0.0f;
        bool isCutoffValueValid = outlineCutoffValue.value < 1.0f;
        bool areNearAndFarDistancesValid = outlineNearFadeOutLimits.value.y <= outlineFarFadeOutLimits.value.x;

        return isOutlineOrFillColorShown && isCutoffValueValid && areNearAndFarDistancesValid;
    }

    public bool IsTileCompatible()
    {
        return false;
    }
}
