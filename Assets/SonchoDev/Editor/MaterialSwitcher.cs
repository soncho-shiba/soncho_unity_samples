using UnityEngine;
using UnityEditor;
using System.Collections.Generic;


namespace SonchoDev.Editor
{

    public class MaterialSwitcherWindow : EditorWindow
    {   
        private MaterialData materialData;

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
            }
        }

        private void SwitchAllMaterials(Material newMaterial)
        {
            foreach (var renderer in FindObjectsOfType<Renderer>())
            {
                Undo.RecordObject(renderer, "Material Switch");
                renderer.sharedMaterial = newMaterial;
            }

            Debug.Log("All materials have been switched to " + newMaterial.name);
        }
    }
}

