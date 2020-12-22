using UnityEngine;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    public class BattleActionCard : MonoBehaviour
    {
        public BattleUnit owner;
        public bool canUseWithoutOwner;

        public string skillName;
        public SkillType skillType;
        public SkillEffectTarget skillEffectTarget;
        public SkillTargetType skillTargetType;

        public string animationId;
        public BattleAction[] battleActions;

        // TEST Only
        // make Battle Action Targeting Data for replace this set
        private List<BattleUnit> _targets = new List<BattleUnit>();
        public BattleProjectile projectilePrefab;
        public Vector3 launchPositionOffset = new Vector3(0f, 5f, 0f);
        public Vector3 targetPosition = Vector3.zero;
        public float travelTime = 1f;

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

        public void ShowTargeting()
        {
            // Test Only
            if (skillTargetType == SkillTargetType.Projectile)
                BattleManager.main.battleProjectileManager.SpawnProjectileWithTargeting(
                    projectilePrefab,
                    owner.transform.position + launchPositionOffset, 
                    travelTime);
        }

        public void Execute()
        {
            foreach(BattleAction battleAction in battleActions)
            {
                battleAction.Execute(this);
            }
        }

        public void TakeAction()
        {
            if (!owner)
            {
                if (canUseWithoutOwner)
                {
                    Execute();
                }
                return;
            }

            owner.SetTakeActionState();
            owner.animator.ResetTrigger("hit");
            owner.animator.SetTrigger(animationId);
        }
    }
}
