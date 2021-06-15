using UnityEngine;
using System.Collections;
using System.Collections.Generic;

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

        public AbilityData[] abilityDatas;

        public float moveSpeed = 1f;

        // TODO
        // AI
        // Immobile / Hit & Run / Cover

        public AbilityData GetAbilityFromTrigger(AbilityData.TriggerType triggerType)
        {
            foreach(AbilityData ability in abilityDatas)
            {
                if(ability.triggerType == triggerType)
                {
                    return ability;
                }
            }
            return null;
        }

        public List<AbilityData> GetPassiveAbilities()
        {
            List<AbilityData> abilities = new List<AbilityData>();

            foreach (AbilityData ability in abilityDatas)
            {
                if (ability.triggerType == AbilityData.TriggerType.Passive)
                {
                    abilities.Add(ability);
                }
            }

            return abilities;
        }
    }
}
