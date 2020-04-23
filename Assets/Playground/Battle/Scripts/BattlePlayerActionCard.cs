using UnityEngine;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    public class BattlePlayerActionCard : MonoBehaviour
    {
        public BattleUnit owner;

        public string skillName;
        public SkillType skillType;
        public SkillEffectTarget skillEffectTarget;
        public SkillTargetType skillTargetType;

        public BattleAction[] battleActions;

        private List<BattleUnit> _targets = new List<BattleUnit>();

        public void SetTarget(BattleUnit target)
        {
            _targets.Clear();
            _targets.Add(target);
        }

        public void SetTargets(List<BattleUnit> targets)
        {
            _targets = targets;
        }

        public BattleUnit GetTarget()
        {
            return _targets[0];
        }

        public List<BattleUnit> GetTargets()
        {
            return _targets;
        }

        public void Target()
        {
            BattleManager.main.EnterPlayerInput(this);
        }

        public void Execute()
        {
            foreach(BattleAction battleAction in battleActions)
            {
                battleAction.Execute(this);
            }

            BattleManager.main.ExitPlayerInput();
        }
    }
}
