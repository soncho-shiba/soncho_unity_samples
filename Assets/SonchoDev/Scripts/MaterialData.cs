using UnityEngine;
namespace SonchoDev
{

    [CreateAssetMenu(fileName = "MaterialData", menuName = "Material Assets/Material Data", order = 1)]
    public class MaterialData : ScriptableObject
    {
        public Material[] materials;
    }
    
}