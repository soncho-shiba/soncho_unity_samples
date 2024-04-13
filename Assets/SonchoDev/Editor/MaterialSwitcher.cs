using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using Codice.CM.Common.Purge;


namespace SonchoDev.Editor
{

    public class MaterialSwitcherWindow : EditorWindow
    {   
        private MaterialData materialData;
        private Dictionary<Renderer, Material> originalMaterials = new Dictionary<Renderer, Material>();

        [MenuItem("SonchoDev/Material Switcher")]
        public static void ShowWindow()
        {
            GetWindow<MaterialSwitcherWindow>("Material Switcher");
        }

        void OnGUI()
        {
            GUILayout.Label("Select Material from Asset", EditorStyles.boldLabel);
            
            materialData = EditorGUILayout.ObjectField("Material Data", materialData, typeof(MaterialData), false) as MaterialData;

            if (materialData != null)
            {
                foreach (var material in materialData.materials)
                {
                    if (GUILayout.Button(material.name))
                    {
                        SwitchAllMaterials(material);
                    }
                }

                if (GUILayout.Button("revert to original materials"))
                {
                    RevertMaterials();
                }
            }
            
        }

        private void SwitchAllMaterials(Material newMaterial)
        {
            foreach (var renderer in FindObjectsOfType<Renderer>())
            {
                Undo.RecordObject(renderer, "Material Switch");
                renderer.sharedMaterial = newMaterial;
                
                if (!originalMaterials.ContainsKey(renderer))
                {
                    originalMaterials.Add(renderer, renderer.sharedMaterial);
                }
            }

            Debug.Log("All materials have been switched to " + newMaterial.name);
        }

        private void RevertMaterials()
        {
            foreach (var item in originalMaterials)
            {
                var renderer = item.Key;
                var originalMaterial = item.Value;
                Undo.RecordObject(renderer, "Material Revert");
                renderer.sharedMaterial = originalMaterial;
            }
            Debug.Log("Materials  reverted to their original state");
        }
    }
}

