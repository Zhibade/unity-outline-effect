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

public class OutlineEffectRenderPass : ScriptableRenderPass
{
    static readonly string COLOR_PROPERTY_NAME = "_ScreenColor";
    static readonly string MAIN_TEXTURE_PROPERTY_NAME = "_MainTex";
    static readonly int TEMP_RENDER_TARGET_PROPERTY_ID = Shader.PropertyToID("_TempRenderTarget");

    static readonly string OUTLINE_EFFECT_TAG = "Outline Effect";
    static readonly string OUTLINE_EFFECT_SHADER = "Hidden/OutlineEffect";

    Material material;
    OutlineEffect outlineEffect;
    RenderTargetIdentifier renderTargetIdentifier;

    public OutlineEffectRenderPass(RenderPassEvent renderPassEvent)
    {
        Shader shader = Shader.Find(OUTLINE_EFFECT_SHADER);
        if (shader == null)
        {
            Debug.LogError("Outline effect shader not found: " + OUTLINE_EFFECT_SHADER);
            return;
        }

        material = CoreUtils.CreateEngineMaterial(shader);
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (material == null || !renderingData.cameraData.postProcessEnabled)
        {
            return;
        }

        VolumeStack stack = VolumeManager.instance.stack;
        outlineEffect = stack.GetComponent<OutlineEffect>();

        if (outlineEffect == null || !outlineEffect.IsActive())
        {
            return;
        }

        CommandBuffer buffer = CommandBufferPool.Get(OUTLINE_EFFECT_TAG);
        Render(buffer, ref renderingData);
    }

    public void Setup(in RenderTargetIdentifier targetIdentifier)
    {
        renderTargetIdentifier = targetIdentifier;
    }

    void Render(CommandBuffer buffer, ref RenderingData data)
    {
        ref CameraData cameraData = ref data.cameraData;
        RenderTargetIdentifier sourceRenderTarget = renderTargetIdentifier;

        int screenWidth = cameraData.camera.scaledPixelWidth;
        int screenHeight = cameraData.camera.scaledPixelHeight;

        material.SetColor(COLOR_PROPERTY_NAME, outlineEffect.screenColor.value);

        // Copy to temp render target and render to render target

        buffer.SetGlobalTexture(MAIN_TEXTURE_PROPERTY_NAME, sourceRenderTarget);
        buffer.GetTemporaryRT(TEMP_RENDER_TARGET_PROPERTY_ID, screenWidth, screenHeight, 0, FilterMode.Point, RenderTextureFormat.Default);
        buffer.Blit(sourceRenderTarget, TEMP_RENDER_TARGET_PROPERTY_ID);
        buffer.Blit(TEMP_RENDER_TARGET_PROPERTY_ID, sourceRenderTarget, material, 0);
    }
}
