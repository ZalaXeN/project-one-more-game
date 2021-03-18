﻿using UnityEngine;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    public class BattleActionCard : MonoBehaviour
    {
        public BattleUnit owner;
        public bool canUseWithoutOwner;

        public SkillData baseData;

        // TODO
        // Target
        private List<BattleUnit> _targets;
        public Vector3 targetPosition = Vector3.zero;

        public void SetTarget(BattleUnit target)
        {
            if (_targets == null)
                _targets = new List<BattleUnit>(); 

            _targets.Clear();

            if (target != null)
                _targets.Add(target);
        }

        public void SetTargets(List<BattleUnit> targets)
        {
            _targets = targets;
        }

        public void SetTargetsWithActionArea(bool shouldAlive = true)
        {
            AreaSkillData data = baseData as AreaSkillData;
            Vector3 castPosition = targetPosition + data.offset;
            List<BattleUnit> tempUnitList = BattleActionArea.GetUnitListFromOverlapSphere(castPosition, data.sizeDelta.x);
            if (canUseWithoutOwner)
            {
                _targets = tempUnitList;
                return;
            }

            ClearTargets();

            foreach (BattleUnit unit in tempUnitList)
            {
                if (!unit.IsAlive() && shouldAlive)
                    continue;

                if(baseData.skillEffectTarget == SkillEffectTarget.Ally || baseData.skillEffectTarget == SkillEffectTarget.Allies)
                {
                    if (unit.team == owner.team)
                        _targets.Add(unit);
                }
                else if (baseData.skillEffectTarget == SkillEffectTarget.Enemy || baseData.skillEffectTarget == SkillEffectTarget.Enemies)
                {
                    if (unit.team != owner.team)
                        _targets.Add(unit);
                }
                else if (baseData.skillEffectTarget == SkillEffectTarget.All)
                {
                    _targets.Add(unit);
                }
            }
        }

        public BattleUnit GetTarget()
        {
            return _targets[0];
        }

        public List<BattleUnit> GetTargets()
        {
            return _targets;
        }

        public bool HasTarget()
        {
            switch (baseData.skillTargetType)
            {
                case SkillTargetType.Target:
                    if (_targets != null && _targets.Count > 0)
                        return true;
                    return false;
                case SkillTargetType.Projectile:
                    return true;
                case SkillTargetType.Area:
                    if (_targets != null && _targets.Count > 0)
                        return true;
                    return false;
            }

            return false;
        }

        public void Target()
        {
            BattleManager.main.EnterPlayerInput(this);
        }

        public void ShowTargeting()
        {
            switch (baseData.skillTargetType)
            {
                case SkillTargetType.Target:
                    break;
                case SkillTargetType.Projectile:
                    ShowProjectileTargeting();
                    break;
                case SkillTargetType.Area:
                    ShowAreaTargeting();
                    break;
                default:
                    break;
            }
        }

        private void ShowProjectileTargeting() 
        {
            ProjectileSkillData data = (baseData as ProjectileSkillData);

            BattleManager.main.battleProjectileManager.SpawnProjectileWithTargeting(
                    data.projectilePrefab,
                    owner.transform.position + data.launchPositionOffset,
                    data.travelTime);
        }

        private void ShowAreaTargeting()
        {
            AreaSkillData data = (baseData as AreaSkillData);

            BattleManager.main.battleActionIndicatorManager.ShowAreaIndicator("", owner.transform.position, data.sizeDelta);
        }

        public void FindTarget()
        {
            BattleUnit target = BattleManager.main.fieldManager.GetNearestEnemyUnitInAttackRange(owner);

            switch (baseData.skillTargetType)
            {
                case SkillTargetType.Target:
                    SetTarget(target);
                    break;
                case SkillTargetType.Projectile:
                    targetPosition = target.transform.position;
                    break;
                case SkillTargetType.Area:
                    targetPosition = owner.transform.position;
                    SetTargetsWithActionArea();
                    break;
            }
        }

        public void Execute()
        {
            foreach(BattleAction battleAction in baseData.battleActions)
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

            // Animate
            if (string.IsNullOrEmpty(baseData.animationId))
            {
                Execute();
            }
            else
            {
                owner.SetTakeActionState(baseData.animationId);
            }
        }

        private void ClearTargets()
        {
            if (_targets == null)
                _targets = new List<BattleUnit>();
            _targets.Clear();
        }
    }
}