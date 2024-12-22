/* Copyright (C) 2024 - Jose Ivan Lopez Romo - All rights reserved
 *
 * This file is part of the UnityOutlineEffect project found in the
 * following repository: https://github.com/Zhibade/unity-outline-effect
 *
 * Released under MIT license. Please see LICENSE file for details.
 */

using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class OutlineEffectRenderPass : ScriptableRenderPass
{
    static readonly string COLOR_PROPERTY_NAME = "_FillColor";
    static readonly string COLOR_STRENGTH_PROPERTY_NAME = "_FillStrength";

    static readonly string OUTLINE_COLOR_PROPERTY_NAME = "_OutlineColor";
    static readonly string OUTLINE_STRENGTH_PROPERTY_NAME = "_OutlineStrength";
    static readonly string OUTLINE_WIDTH_PROPERTY_NAME = "_OutlineWidth";
    static readonly string OUTLINE_CUTOFF_PROPERTY_NAME = "_OutlineCutoff";
    static readonly string OUTLINE_FADEOUT_DISTANCES_PROPERTY_NAME = "_OutlineNearAndFarFadeOut";

    static readonly string NORMAL_OUTLINE_STRENGTH_PROPERTY_NAME = "_NormalOutlineStrength";
    static readonly string NORMAL_OUTLINE_WIDTH_PROPERTY_NAME = "_NormalOutlineWidth";
    static readonly string NORMAL_OUTLINE_CUTOFF_PROPERTY_NAME = "_NormalOutlineCutoff";

    static readonly string TARGET_TEXTURE_PROPERTY_NAME = "_OutlineTexture";

    Material material;

    public OutlineEffectRenderPass(RenderPassEvent renderPassEvent, Material material)
    {
        this.renderPassEvent = renderPassEvent;

        if (material == null)
        {
            Debug.LogError("Outline effect material not found");
            return;
        }

        this.material = material;
    }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        VolumeStack stack = VolumeManager.instance.stack;
        OutlineEffect outlineEffect = stack.GetComponent<OutlineEffect>();

        if (!outlineEffect.IsActive())
        {
            return;
        }

        UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();

        if (resourceData.isActiveTargetBackBuffer)
        {
            return;
        }

        TextureHandle srcCamColor = resourceData.activeColorTexture;

        TextureDesc colorTextureDesc = srcCamColor.GetDescriptor(renderGraph);
        colorTextureDesc.depthBufferBits = 0;
        colorTextureDesc.name = TARGET_TEXTURE_PROPERTY_NAME;
        
        TextureHandle target = renderGraph.CreateTexture(colorTextureDesc);

        UpdateSettings(outlineEffect);

        // Prevent material preview error
        if (!srcCamColor.IsValid() || !target.IsValid())
        {
            return;
        }

        // Blit
        RenderGraphUtils.BlitMaterialParameters blitParams = new(srcCamColor, target, material, 0);
        renderGraph.AddBlitPass(blitParams, "OutlineRenderPass");

        resourceData.cameraColor = target;
    }

    /// <summary>
    /// Enables depth & world normal passes so their textures can be used in the outline pass
    /// </summary>
    public void Setup()
    {
        ConfigureInput(ScriptableRenderPassInput.Depth);
        ConfigureInput(ScriptableRenderPassInput.Normal);
    }

    void UpdateSettings(OutlineEffect outlineEffect)
    {
        if (outlineEffect == null || !outlineEffect.IsActive() || material == null)
        {
            return;
        }

        Vector4 fadeOutDistances = new Vector4(outlineEffect.outlineNearFadeOutLimits.value.x, outlineEffect.outlineNearFadeOutLimits.value.y,
                                               outlineEffect.outlineFarFadeOutLimits.value.x, outlineEffect.outlineFarFadeOutLimits.value.y);

        material.SetColor(OUTLINE_COLOR_PROPERTY_NAME, outlineEffect.outlineColor.value);
        material.SetFloat(OUTLINE_STRENGTH_PROPERTY_NAME, outlineEffect.outlineStrength.value);
        material.SetInt(OUTLINE_WIDTH_PROPERTY_NAME, outlineEffect.outlineWidth.value);
        material.SetFloat(OUTLINE_CUTOFF_PROPERTY_NAME, outlineEffect.outlineCutoffValue.value);
        material.SetVector(OUTLINE_FADEOUT_DISTANCES_PROPERTY_NAME, fadeOutDistances);

        material.SetFloat(NORMAL_OUTLINE_STRENGTH_PROPERTY_NAME, outlineEffect.normalOutlineStrength.value);
        material.SetInt(NORMAL_OUTLINE_WIDTH_PROPERTY_NAME, outlineEffect.normalOutlineWidth.value);
        material.SetFloat(NORMAL_OUTLINE_CUTOFF_PROPERTY_NAME, outlineEffect.normalOutlineCutoffValue.value);

        material.SetColor(COLOR_PROPERTY_NAME, outlineEffect.fillColor.value);
        material.SetFloat(COLOR_STRENGTH_PROPERTY_NAME, outlineEffect.fillStrength.value);
    }
}
