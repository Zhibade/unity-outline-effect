## 日本語は下記です。

# Overview
![Sample Render 01](https://github.com/Zhibade/unity-outline-effect/raw/main/Docs/Render01.jpg)
![Sample Render 02](https://github.com/Zhibade/unity-outline-effect/raw/main/Docs/Render02.jpg)
![Settings](https://github.com/Zhibade/unity-outline-effect/raw/main/Docs/Settings.jpg)

Outline post process effect implementation on the Unity's universal pipeline.

It uses depth + normal buffers to generate the outline. Please see tooltip on each of the post-process effect settings for a more detailed description on what each setting does.


# How to use (on this project)
- Open the project
- Open the *Scenes/SampleScene.unity* scene
- Effect should be visible straight away
- Effect can be customized through the *Post-process Volume* game object


# How to use (different project with no custom [Render Pipeline Asset](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@10.2/manual/universalrp-asset.html))
- Import the *Package/OutlineEffect.unitypackage* included in this repository into the other project
- Assign the included *OutlineEffectRenderPipelineAsset* to the following settings:
  - *Project Settings* -> *Graphics* -> *Scriptable Render Pipeline Settings*
  - *Project Settings* -> *Quality* -> *Rendering*
- On any [volume](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@10.2/manual/Volumes.html) in the scene just add the *Outline Effect* override
- Check the *Enable* checkbox to turn on the effect
- Change any of the settings as desired

**NOTE:** Make sure that the following settings are enabled on the main [camera](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@10.2/manual/camera-component-reference.html):
  - *Post Processing*
  - *Depth Texture*


# How to use (different project with a custom [Render Pipeline Asset](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@10.2/manual/universalrp-asset.html))
- Import the *Package/OutlineEffect.unitypackage* included in this repository into the other project
- Select your custom render pipeline *_Renderer* asset and under *Renderer Features* add the following render features in the same order:
  - *Depth Normals Render Feature*
  - *Outline Effect Render Feature*
- Under the newly added *Outline Effect Render Feature*, go to *Settings* -> *Shader* and assign the *OutlineEffect* shader 
- On any [volume](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@10.2/manual/Volumes.html) in the scene just add the *Outline Effect* override
- Check the *Enable* checkbox to turn on the effect
- Change any of the settings as desired

**NOTE:** Make sure that the following settings are enabled on the main [camera](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@10.2/manual/camera-component-reference.html):
  - *Post Processing*
  - *Depth Texture*



# 概要
Unityのユニバーサルレンダリングパイプラインでの輪郭のポストプロセス特殊効果。

深度と法線のバッファーに基づくエフェクトです。各設定のツールチップに詳しいエフェクトの使い方の説明があります。


# 使い方（当プロジェクト）
- プロジェクトを開きます
- *Scenes/SampleScene.unity*シーンを開きます
- そのままで輪郭エフェクトが見えます
- *Post-process Volume*を用いてエフェクトの設定を変更できます


# 使い方（別のプロジェクト。カスタム「[Render Pipeline Asset](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@10.2/manual/universalrp-asset.html)」がない場合）
- このリポジトリの*Package/OutlineEffect.unitypackage*を別のプロジェクトにインポートします
- 下記の設定に含めた*OutlineEffectRenderPipelineAsset* を割り当てます
  - *Project Settings* -> *Graphics* -> *Scriptable Render Pipeline Settings*
  - *Project Settings* -> *Quality* -> *Rendering*
- シーンにある[volume](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@10.2/manual/Volumes.html)に*Outline Effect*のオーバーライドを追加します
- Volumeで*Enable*のトグルを有効にするとエフェクトは有効になります
- Volumeでエフェクトの設定を変更できます

**ご注意:** カメラに下記の設定をONにしてください：
  - *Post Processing*
  - *Depth Texture*


# 使い方（別のプロジェクト。カスタム「[Render Pipeline Asset](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@10.2/manual/universalrp-asset.html)」がある場合）
- このリポジトリの*Package/OutlineEffect.unitypackage*を別のプロジェクトにインポートします
- カスタム「Render Pipeline Asset」の*_Renderer*の接尾語あるアセットをクリックして、*Renderer Features*の下に下記の*Renderer Feature*を追加します（同じ順番）：
  - *Depth Normals Render Feature*
  - *Outline Effect Render Feature*
- 追加された*Outline Effect Render Feature*の下に、*Settings/Shader*に*OutlineEffect*のシェーダを割り当てます
- シーンにある[volume](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@10.2/manual/Volumes.html)に*Outline Effect*のオーバーライドを追加します
- Volumeで*Enable*のトグルを有効にするとエフェクトは有効になります
- Volumeでエフェクトの設定を変更できます

**ご注意:** カメラに下記の設定をONにしてください：
  - *Post Processing*
  - *Depth Texture*