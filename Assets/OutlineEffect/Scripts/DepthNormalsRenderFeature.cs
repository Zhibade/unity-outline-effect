/* Copyright (C) 2020 - Jose Ivan Lopez Romo - All rights reserved
 *
 * This file is part of the UnityOutlineEffect project found in the
 * following repository: https://github.com/Zhibade/unity-outline-effect
 *
 * Released under MIT license. Please see LICENSE file for details.
 */

using UnityEngine;
using UnityEngine.Rendering.Universal;

/** Since the universal render pipeline does not render the Depth + Normals buffer,
 *  we have to add it as a separate custom render feature.
 */
public class DepthNormalsRenderFeature : ScriptableRendererFeature
{
    static readonly string GLOBAL_TEXTURE_PROPERTY = "_CameraDepthNormalsTexture";

    DepthNormalsRenderPass renderPass;
    RenderTargetHandle renderTargetHandle;

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderPass.Setup(renderTargetHandle, renderingData.cameraData.cameraTargetDescriptor, GLOBAL_TEXTURE_PROPERTY);
        renderer.EnqueuePass(renderPass);
    }

    public override void Create()
    {
        renderPass = new DepthNormalsRenderPass(RenderPassEvent.AfterRenderingPrePasses);
        renderTargetHandle.Init(GLOBAL_TEXTURE_PROPERTY);
    }
}
