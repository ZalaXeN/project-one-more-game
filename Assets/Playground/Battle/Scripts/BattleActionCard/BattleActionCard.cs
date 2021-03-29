﻿using UnityEngine;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    public class BattleActionCard : MonoBehaviour
    {
        public BattleUnit owner;
        public bool canUseWithoutOwner;

        public SkillData baseData;

        protected static Collider[] s_hitCache;

        private List<BattleUnit> _targets;
        [HideInInspector]
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
            if (s_hitCache == null)
                s_hitCache = new Collider[32];


            List<BattleUnit> tempUnitList;

            if(baseData.targetAreaType == SkillData.AreaType.Circle)
                tempUnitList = BattleActionArea.GetUnitListFromOverlapSphere(targetPosition, baseData.radius, s_hitCache);
            else
                tempUnitList = BattleActionArea.GetUnitListFromOverlapBox(targetPosition, baseData.sizeDelta / 2, s_hitCache);

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
                    ShowUnitTargeting();
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

        private void ShowUnitTargeting()
        {
            BattleActionIndicator.IndicatorMessage rangeMsg;
            rangeMsg.position = owner.transform.position;
            rangeMsg.offset = baseData.offset;
            rangeMsg.sizeDelta = baseData.targetRange;
            rangeMsg.showTime = 0;
            rangeMsg.isFollowMouse = false;
            rangeMsg.isFollowOwner = true;
            rangeMsg.ownerTransform = owner.transform;
            rangeMsg.hasCastRange = false;
            rangeMsg.castRange = baseData.targetRange;
            rangeMsg.castAreaType = baseData.targetAreaType;

            BattleManager.main.battleActionIndicatorManager.ShowAreaIndicator("", rangeMsg);
        }

        private void ShowProjectileTargeting() 
        {
            BattleActionIndicator.IndicatorMessage castMsg;
            castMsg.position = owner.transform.position;
            castMsg.offset = baseData.offset;
            castMsg.sizeDelta = baseData.sizeDelta;
            castMsg.showTime = 0;
            castMsg.isFollowMouse = true;
            castMsg.isFollowOwner = false;
            castMsg.ownerTransform = owner.transform;
            castMsg.hasCastRange = true;
            castMsg.castRange = baseData.targetRange;
            castMsg.castAreaType = baseData.targetAreaType;

            BattleActionIndicator.IndicatorMessage rangeMsg;
            rangeMsg.position = owner.transform.position;
            rangeMsg.offset = baseData.offset;
            rangeMsg.sizeDelta = baseData.targetRange;
            rangeMsg.showTime = 0;
            rangeMsg.isFollowMouse = false;
            rangeMsg.isFollowOwner = true;
            rangeMsg.ownerTransform = owner.transform;
            rangeMsg.hasCastRange = false;
            rangeMsg.castRange = baseData.targetRange;
            rangeMsg.castAreaType = baseData.targetAreaType;

            BattleManager.main.battleActionIndicatorManager.ShowAreaIndicator("", castMsg);
            BattleManager.main.battleActionIndicatorManager.ShowAreaIndicator("", rangeMsg);

            BattleManager.main.battleProjectileManager.SpawnProjectileWithTargeting(
                    baseData.projectilePrefab,
                    owner.transform.position + baseData.launchPositionOffset,
                    baseData.travelTime,
                    owner.transform.position + baseData.offset,
                    baseData.targetRange);
        }

        private void ShowAreaTargeting()
        {
            BattleActionIndicator.IndicatorMessage castMsg;
            castMsg.position = owner.transform.position;
            castMsg.offset = baseData.offset;
            castMsg.sizeDelta = baseData.sizeDelta;
            castMsg.showTime = 0;
            castMsg.isFollowMouse = true;
            castMsg.isFollowOwner = false;
            castMsg.ownerTransform = owner.transform;
            castMsg.hasCastRange = true;
            castMsg.castRange = baseData.targetRange;
            castMsg.castAreaType = baseData.targetAreaType;

            BattleActionIndicator.IndicatorMessage rangeMsg;
            rangeMsg.position = owner.transform.position;
            rangeMsg.offset = baseData.offset;
            rangeMsg.sizeDelta = baseData.targetRange;
            rangeMsg.showTime = 0;
            rangeMsg.isFollowMouse = false;
            rangeMsg.isFollowOwner = true;
            rangeMsg.ownerTransform = owner.transform;
            rangeMsg.hasCastRange = false;
            rangeMsg.castRange = baseData.targetRange;
            rangeMsg.castAreaType = baseData.targetAreaType;

            BattleManager.main.battleActionIndicatorManager.ShowAreaIndicator("", castMsg);
            BattleManager.main.battleActionIndicatorManager.ShowAreaIndicator("", rangeMsg);
        }

        // Auto Find for Normal Action
        public void FindTarget()
        {
            //BattleUnit target = BattleManager.main.fieldManager.GetNearestEnemyUnitInAttackRange(owner);
            BattleUnit target = SearchNearestTargetInRange(owner.transform.position + baseData.offset);

            switch (baseData.skillTargetType)
            {
                case SkillTargetType.Target:
                    if (target == null)
                    {
                        ClearTargets();
                        return;
                    }
                    SetTarget(target);
                    break;
                case SkillTargetType.Projectile:
                    if (target == null)
                    {
                        ClearTargets();
                        return;
                    }
                    targetPosition = target.transform.position;
                    break;
                case SkillTargetType.Area:
                    if (target == null)
                    {
                        targetPosition = owner.transform.position + baseData.offset;
                    }
                    else
                    {
                        targetPosition = target.transform.position;
                    }
                    SetTargetsWithActionArea();
                    break;
            }
        }

        private BattleUnit SearchNearestTargetInRange(Vector3 position)
        {
            if (s_hitCache == null)
                s_hitCache = new Collider[32];

            List<BattleUnit> tempUnitList;
            switch (baseData.targetAreaType)
            {
                case SkillData.AreaType.Circle:
                    tempUnitList = BattleActionArea.GetUnitListFromOverlapSphere(position, baseData.targetRange.x / 2, s_hitCache);
                    break;
                case SkillData.AreaType.Box:
                    tempUnitList = BattleActionArea.GetUnitListFromOverlapBox(position, baseData.targetRange / 2, s_hitCache);
                    break;
                default:
                    tempUnitList = BattleActionArea.GetUnitListFromOverlapBox(position, baseData.targetRange / 2, s_hitCache);
                    break;
            }

            BattleUnit nearestUnit;
            if (baseData.skillEffectTarget == SkillEffectTarget.Enemies || baseData.skillEffectTarget == SkillEffectTarget.Enemy)
                nearestUnit = GetNearestUnitFromList(tempUnitList, BattleManager.main.GetOppositeTeam(owner.team));
            else
                nearestUnit = GetNearestUnitFromList(tempUnitList, owner.team);

            return nearestUnit;
        }

        private BattleUnit GetNearestUnitFromList(List<BattleUnit> unitList, BattleTeam team)
        {
            BattleUnit nearestUnit = null;
            foreach (BattleUnit unit in unitList)
            {
                if (!unit.IsAlive())
                    continue;

                if (unit && unit.team == team)
                {
                    if (nearestUnit == null)
                        nearestUnit = unit;
                    else if (
                        Vector3.Distance(owner.transform.position, unit.transform.position) <
                        Vector3.Distance(owner.transform.position, nearestUnit.transform.position))
                        nearestUnit = unit;
                }
            }
            return nearestUnit;
        }

        public bool IsUnitInTargetRange(BattleUnit unit)
        {
            Vector3 position = owner.transform.position + baseData.offset;

            if (s_hitCache == null)
                s_hitCache = new Collider[32];

            List<BattleUnit> tempUnitList;
            switch (baseData.targetAreaType)
            {
                case SkillData.AreaType.Circle:
                    tempUnitList = BattleActionArea.GetUnitListFromOverlapSphere(position, baseData.targetRange.x / 2, s_hitCache);
                    break;
                case SkillData.AreaType.Box:
                    tempUnitList = BattleActionArea.GetUnitListFromOverlapBox(position, baseData.targetRange / 2, s_hitCache);
                    break;
                default:
                    tempUnitList = BattleActionArea.GetUnitListFromOverlapBox(position, baseData.targetRange / 2, s_hitCache);
                    break;
            }

            return tempUnitList.Contains(unit);
        }

        public void Execute()
        {
            foreach (BattleAction battleAction in baseData.battleActions)
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

        #region Gizmos
#if UNITY_EDITOR
        private void OnDrawGizmosSelected()
        {
            DrawGizmoSkillRange();
        }

        private void DrawGizmoSkillRange()
        {
            Transform trans = owner == null ? transform : owner.transform;

            if (baseData.targetAreaType == SkillData.AreaType.Circle)
            {
                UnityEditor.Handles.color = new Color(0f, 0.7f, 0f, 0.2f);
                UnityEditor.Handles.DrawSolidDisc(trans.position + baseData.offset, Vector3.up, baseData.targetRange.x / 2);

                UnityEditor.Handles.color = new Color(0.7f, 0.0f, 0f, 0.2f);
                UnityEditor.Handles.DrawSolidDisc(trans.position + baseData.offset, Vector3.up, baseData.radius);
            }
            else
            {
                UnityEditor.Handles.color = new Color(0f, 0.7f, 0f, 0.2f);
                UnityEditor.Handles.DrawWireCube(trans.position + baseData.offset, baseData.targetRange);

                UnityEditor.Handles.color = new Color(0.7f, 0.0f, 0f, 0.2f);
                UnityEditor.Handles.DrawWireCube(trans.position + baseData.offset, baseData.sizeDelta);
            }
        }
#endif
        #endregion
    }
}
