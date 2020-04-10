using UnityEngine;
using System.Collections;

namespace ProjectOneMore
{
    [System.Serializable]
    public class KeeperSkillData
    {
        public string skillId;
        public string skillDescription;
        public bool isCore;

        public Element element;
        public SkillType skillType;
        public SkillTargetType skillTargetType;
        public SkillDataEnergyUsage<int> energy;

        // TODO
        // public SkillAction skillAction;
    }
}
