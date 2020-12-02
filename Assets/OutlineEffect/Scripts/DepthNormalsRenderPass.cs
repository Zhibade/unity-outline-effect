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

/** Render pass that outputs the depth + view normal texture using Unity's internal shader */
public class DepthNormalsRenderPass : ScriptableRenderPass
{
    static readonly string SHADER_NAME = "Hidden/Internal-DepthNormalsTexture"; // Internal Unity built-in shader
    static readonly string DEPTH_NORMAL_EFFECT_TAG = "Depth Normals Effect";

    string globalTextureName;
    Material material;

    RenderTargetHandle renderTargetHandle;
    RenderTextureDescriptor textureDescriptor;
    FilteringSettings filteringSettings;

    ShaderTagId depthOnlyShaderTag = new ShaderTagId("DepthOnly"); // "LightMode" = "DepthOnly" tag to so it only renders depth

    public DepthNormalsRenderPass(RenderPassEvent renderPassEvent)
    {
        this.renderPassEvent = renderPassEvent;
        material = CoreUtils.CreateEngineMaterial(SHADER_NAME);

        filteringSettings = new FilteringSettings(RenderQueueRange.opaque, -1); // Which objects are included in this render pass
    }

    /** This method gets called before executing the render pass. This is used to prepare the render target. */
    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        cmd.GetTemporaryRT(renderTargetHandle.id, textureDescriptor, FilterMode.Point);
        ConfigureTarget(renderTargetHandle.Identifier());
        ConfigureClear(ClearFlag.All, Color.black);
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (material == null || !renderingData.cameraData.postProcessEnabled)
        {
            return;
        }

        // Define rendering conditions (which objects, what data to include, which material, etc)

        SortingCriteria opaqueSortFlags = renderingData.cameraData.defaultOpaqueSortFlags;

        DrawingSettings drawingSettings = CreateDrawingSettings(depthOnlyShaderTag, ref renderingData, opaqueSortFlags);
        drawingSettings.perObjectData = PerObjectData.None;
        drawingSettings.overrideMaterial = material;

        context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filteringSettings);

        // Render and set result as a global texture so other shaders can use it

        CommandBuffer buffer = CommandBufferPool.Get(DEPTH_NORMAL_EFFECT_TAG);
        buffer.SetGlobalTexture(globalTextureName, renderTargetHandle.id);

        context.ExecuteCommandBuffer(buffer);
        CommandBufferPool.Release(buffer);
    }

    public override void FrameCleanup(CommandBuffer cmd)
    {
        if (renderTargetHandle != RenderTargetHandle.CameraTarget)
        {
            cmd.ReleaseTemporaryRT(renderTargetHandle.id);
            renderTargetHandle = RenderTargetHandle.CameraTarget;
        }
    }

    public void Setup(RenderTargetHandle renderTargetHandle, RenderTextureDescriptor textureDescriptor, string globalTextureName)
    {
        this.renderTargetHandle = renderTargetHandle;

        this.textureDescriptor = textureDescriptor;
        this.textureDescriptor.colorFormat = RenderTextureFormat.ARGB32;
        this.textureDescriptor.depthBufferBits = 32;

        this.globalTextureName = globalTextureName;
    }
}
