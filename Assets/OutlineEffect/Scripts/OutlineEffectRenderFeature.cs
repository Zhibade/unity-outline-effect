/* Copyright (C) 2024 - Jose Ivan Lopez Romo - All rights reserved
 *
 * This file is part of the UnityOutlineEffect project found in the
 * following repository: https://github.com/Zhibade/unity-outline-effect
 *
 * Released under MIT license. Please see LICENSE file for details.
 */

using UnityEngine;
using UnityEngine.Rendering.Universal;

public class OutlineEffectRenderFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class OutlineEffectSettings
    {
        public RenderPassEvent RenderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        public Shader Shader; // Referencing shader through here to avoid having to use Shader.Find + resources folders
    }

    public OutlineEffectSettings settings = new OutlineEffectSettings();
    OutlineEffectRenderPass outlineEffectRenderPass;
    Material material;

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (outlineEffectRenderPass == null || settings.Shader == null)
        {
            return;
        }

        if (renderingData.cameraData.cameraType == CameraType.Game)
        {
            outlineEffectRenderPass.Setup();
            renderer.EnqueuePass(outlineEffectRenderPass);
        }
    }

    public override void Create()
    {
        if (settings.Shader == null)
        {
            return;
        }

        material = new Material(settings.Shader);
        outlineEffectRenderPass = new OutlineEffectRenderPass(settings.RenderPassEvent, material);
    }

    protected override void Dispose(bool disposing)
    {
        if (Application.isPlaying)
        {
            Destroy(material);
        }
        else
        {
            DestroyImmediate(material);
        }
    }
}
