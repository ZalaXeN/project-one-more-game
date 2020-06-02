using UnityEngine;

namespace ProjectOneMore
{
    [System.Serializable]
    public struct MinionPrefabData
    {
        public string prefabId;
        public GameObject prefab;
    }

    [CreateAssetMenu(fileName = "MinionPrefabController", menuName = "Minion/PrefabController", order = 1)]
    public class MinionPrefabController : ScriptableObject
    {
        [SerializeField]
        private MinionPrefabData[] minionPrefabDatas = { };

        public GameObject GetMinionPrefab(string prefabId)
        {
            foreach(MinionPrefabData data in minionPrefabDatas)
            {
                if(data.prefabId == prefabId)
                {
                    return data.prefab;
                }
            }

            return null;
        }
    }
}
