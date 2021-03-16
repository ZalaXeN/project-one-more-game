using UnityEngine;
using System.Collections;

namespace ProjectOneMore
{
    [System.Serializable]
    public struct UnitStats
    {
        public int POW;
        public int CRI;
        public int SPD;
        public int HP;
        public int DEF;
        public int EN;
    }

    [System.Serializable, CreateAssetMenu(fileName = "UnitData", menuName = "Data/Unit", order = 0)]
    public class UnitData : ScriptableObject
    {
        public string unitId;
        public string unitName;
        public UnitStats baseStats;

        public SkillData normalSkillData;
        public SkillData skillData;
        public SkillData ultimateSkillData;

        public float moveSpeed = 1f;

        // TODO
        // AI
        // Immobile / Hit & Run / Cover
    }
}
