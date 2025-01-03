﻿/* Copyright (C) 2024 - Jose Ivan Lopez Romo - All rights reserved
 *
 * This file is part of the UnityOutlineEffect project found in the
 * following repository: https://github.com/Zhibade/unity-outline-effect
 *
 * Released under MIT license. Please see LICENSE file for details.
 */

using UnityEngine;
using UnityEditor;
using UnityEditor.Rendering;

[CustomEditor(typeof(OutlineEffect))]
sealed class OutlineEffectEditor : VolumeComponentEditor
{
    SerializedDataParameter isEnabled;

    SerializedDataParameter outlineColor;
    SerializedDataParameter outlineStrength;
    SerializedDataParameter outlineWidth;
    SerializedDataParameter outlineCutoff;
    SerializedDataParameter outlineNearFadeOutLimits;
    SerializedDataParameter outlineFarFadeOutLimits;

    SerializedDataParameter normalOutlineStrength;
    SerializedDataParameter normalOutlineWidth;
    SerializedDataParameter normalOutlineCutoff;

    SerializedDataParameter fillStrength;
    SerializedDataParameter fillColor;

    public override void OnEnable()
    {
        PropertyFetcher<OutlineEffect> propertyFetcher = new PropertyFetcher<OutlineEffect>(serializedObject);

        isEnabled = Unpack(propertyFetcher.Find(x => x.isEnabled));

        outlineColor = Unpack(propertyFetcher.Find(x => x.outlineColor));
        outlineStrength = Unpack(propertyFetcher.Find(x => x.outlineStrength));
        outlineWidth = Unpack(propertyFetcher.Find(x => x.outlineWidth));
        outlineCutoff = Unpack(propertyFetcher.Find(x => x.outlineCutoffValue));
        outlineNearFadeOutLimits = Unpack(propertyFetcher.Find(x => x.outlineNearFadeOutLimits));
        outlineFarFadeOutLimits = Unpack(propertyFetcher.Find(x => x.outlineFarFadeOutLimits));

        normalOutlineStrength = Unpack(propertyFetcher.Find(x => x.normalOutlineStrength));
        normalOutlineWidth = Unpack(propertyFetcher.Find(x => x.normalOutlineWidth));
        normalOutlineCutoff = Unpack(propertyFetcher.Find(x => x.normalOutlineCutoffValue));

        fillStrength = Unpack(propertyFetcher.Find(x => x.fillStrength));
        fillColor = Unpack(propertyFetcher.Find(x => x.fillColor));
    }

    public override void OnInspectorGUI()
    {
        EditorGUILayout.LabelField("General", EditorStyles.miniLabel);

        PropertyField(isEnabled, EditorGUIUtility.TrTextContent("Enable"));
        PropertyField(outlineColor, EditorGUIUtility.TrTextContent("Color"));

        EditorGUILayout.LabelField("Outline (Depth Based)", EditorStyles.miniLabel);

        PropertyField(outlineStrength, EditorGUIUtility.TrTextContent("Strength"));
        PropertyField(outlineWidth, EditorGUIUtility.TrTextContent("Width"));
        PropertyField(outlineCutoff, EditorGUIUtility.TrTextContent("Cutoff"));

        EditorGUILayout.LabelField("Outline (Normal Based)", EditorStyles.miniLabel);

        PropertyField(normalOutlineStrength, EditorGUIUtility.TrTextContent("Strength"));
        PropertyField(normalOutlineWidth, EditorGUIUtility.TrTextContent("Width"));
        PropertyField(normalOutlineCutoff, EditorGUIUtility.TrTextContent("Cutoff"));

        EditorGUILayout.LabelField("Fade Out", EditorStyles.miniLabel);

        PropertyField(outlineNearFadeOutLimits, EditorGUIUtility.TrTextContent("Near Fade Out Limits"));
        PropertyField(outlineFarFadeOutLimits, EditorGUIUtility.TrTextContent("Far Fade Out Limits"));

        EditorGUILayout.LabelField("Fill", EditorStyles.miniLabel);

        PropertyField(fillStrength, EditorGUIUtility.TrTextContent("Strength"));
        PropertyField(fillColor, EditorGUIUtility.TrTextContent("Color"));

        // Force fade out limits to never go below 0

        Vector2 nearFadeOutLimits = outlineNearFadeOutLimits.value.vector2Value;
        outlineNearFadeOutLimits.value.vector2Value = new Vector2(Mathf.Max(0f, nearFadeOutLimits.x), Mathf.Max(0f, nearFadeOutLimits.y));

        Vector2 farFadeOutLimits = outlineFarFadeOutLimits.value.vector2Value;
        outlineFarFadeOutLimits.value.vector2Value = new Vector2(Mathf.Max(0f, farFadeOutLimits.x), Mathf.Max(0f, farFadeOutLimits.y));
    }
}