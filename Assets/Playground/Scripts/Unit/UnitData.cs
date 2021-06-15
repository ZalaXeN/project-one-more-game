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

    public enum UnitClass
    {
        DEFENDER,
        SUPPORTER,
        CASTER,
        HUNTER,
        RIDER,
        FIGHTER
    }

    [System.Serializable, CreateAssetMenu(fileName = "UnitData", menuName = "Data/Unit", order = 0)]
    public class UnitData : ScriptableObject
    {
        public string unitId;
        public string unitName;
        public UnitStats baseStats;
        public UnitClass unitClass;

        public AbilityData traitSkillData;
        public AbilityData normalSkillData;
        public AbilityData skillData;
        public AbilityData ultimateSkillData;

        public float moveSpeed = 1f;

        // TODO
        // AI
        // Immobile / Hit & Run / Cover


    }
}
