﻿/* Copyright (C) 2020 - Jose Ivan Lopez Romo - All rights reserved
 *
 * This file is part of the UnityOutlineEffect project found in the
 * following repository: https://github.com/Zhibade/unity-outline-effect
 *
 * Released under MIT license. Please see LICENSE file for details.
 */

using UnityEngine.Rendering.Universal;

public class OutlineEffectRenderFeature : ScriptableRendererFeature
{
    OutlineEffectRenderPass outlineEffectRenderPass;

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        outlineEffectRenderPass.Setup(renderer.cameraColorTarget);
        renderer.EnqueuePass(outlineEffectRenderPass);
    }

    public override void Create()
    {
        outlineEffectRenderPass = new OutlineEffectRenderPass(RenderPassEvent.BeforeRenderingPostProcessing);
    }
}
