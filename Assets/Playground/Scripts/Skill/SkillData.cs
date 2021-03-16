using System.Collections;
using UnityEngine;
using ProjectOneMore.Battle;

namespace ProjectOneMore
{
    [CreateAssetMenu(fileName = "SkillData", menuName = "Data/Skill/Basic", order = 0)]
    public class SkillData : ScriptableObject
    {
        public string skillId;
        public string skillName;
        public SkillType skillType;
        public SkillEffectTarget skillEffectTarget;
        public SkillTargetType skillTargetType;

        public string animationId;
        public BattleAction[] battleActions;
    }
}