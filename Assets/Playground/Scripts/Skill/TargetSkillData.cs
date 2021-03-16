using System.Collections;
using UnityEngine;

namespace ProjectOneMore
{
    [CreateAssetMenu(fileName = "SkillData", menuName = "Data/Skill/Target", order = 0)]
    public class TargetSkillData : SkillData
    {
        public float targetRange;
    }
}