using UnityEngine;
using System.Collections;
using Unity.Entities;

namespace ProjectOneMore.Battle
{
    public class BattlePlayerActionCard : MonoBehaviour
    {
        public BattleUnit owner;

        public string skillName;
        public SkillType skillType;
        public SkillEffectTarget skillEffectTarget;
        public SkillTargetType skillTargetType;

        private BattleUnit[] _targets = new BattleUnit[80];

        public void SetTarget(BattleUnit target)
        {
            _targets[0] = target;
        }

        public void SetTarget(BattleUnit[] targets)
        {
            _targets = targets;
        }

        public BattleUnit GetTarget()
        {
            return _targets[0];
        }

        public void Target()
        {
            BattleManager.main.EnterPlayerInput(this);
        }
    }
}
