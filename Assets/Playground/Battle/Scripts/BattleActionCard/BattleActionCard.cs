using UnityEngine;
using System.Collections.Generic;
using System.Collections;

namespace ProjectOneMore.Battle
{
    public class BattleActionCard : MonoBehaviour
    {
        public BattleUnit owner;
        public bool canUseWithoutOwner;

        public AbilityData baseData;

        protected static Collider[] s_hitCache;

        private List<BattleActionTargetable> _targets;
        [HideInInspector]
        public Vector3 targetPosition = Vector3.zero;

        public void SetTarget(BattleActionTargetable target)
        {
            ClearTargets();
            if (target != null)
                _targets.Add(target);
        }

        public void SetTargets(List<BattleActionTargetable> targets)
        {
            _targets = targets;
        }

        public void SetTargetsWithActionArea(bool shouldAlive = true)
        {
            if (s_hitCache == null)
                s_hitCache = new Collider[32];

            List<BattleActionTargetable> tempUnitList;

            if(baseData.targetAreaType == AbilityData.AreaType.Circle)
                tempUnitList = BattleActionArea.GetTargetListFromOverlapSphere(targetPosition, baseData.sizeDelta.x / 2, s_hitCache);
            else
                tempUnitList = BattleActionArea.GetTargetListFromOverlapBox(targetPosition, baseData.sizeDelta / 2, s_hitCache);

            _targets = tempUnitList;
        }

        public BattleActionTargetable GetTarget()
        {
            return _targets[0];
        }

        public List<BattleActionTargetable> GetTargets()
        {
            return _targets;
        }

        public bool HasTarget()
        {
            if (_targets != null && _targets.Count > 0)
                return true;

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
                    baseData.MaxRange,
                    baseData.MinTravelTime,
                    baseData.MaxTravelTime,
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
            BattleActionTargetable target = null;
            // Test For Hunter Class
            if (owner.baseData.unitClass == UnitClass.HUNTER)
            {
                target = SearchWeakestTargetInRange(owner.transform.position, 10f);
            }

            // Other Class
            if (target == null)
            {
                target = SearchNearestTargetInRange(owner.transform.position + baseData.offset);
            }

            if (target == null)
            {
                ClearTargets();
                return;
            }

            switch (baseData.skillTargetType)
            {
                case SkillTargetType.Target:
                    SetTarget(target);
                    break;
                case SkillTargetType.Projectile:
                    SetTarget(target);
                    targetPosition = target.transform.position;
                    break;
                case SkillTargetType.Area:
                    if (baseData.lockTargetPositionToOwner)
                    {
                        targetPosition = owner.transform.position + baseData.offset;
                    }
                    else
                    {
                        targetPosition = target.transform.position;
                    }
                    SetTarget(target);
                    //SetTargetsWithActionArea();
                    break;
            }
        }

        private BattleActionTargetable SearchNearestTargetInRange(Vector3 position)
        {
            if (s_hitCache == null)
                s_hitCache = new Collider[32];

            List<BattleActionTargetable> tempUnitList;
            switch (baseData.targetAreaType)
            {
                case AbilityData.AreaType.Circle:
                    tempUnitList = BattleActionArea.GetTargetListFromOverlapSphere(position, baseData.targetRange.x / 2, s_hitCache);
                    break;
                case AbilityData.AreaType.Box:
                    tempUnitList = BattleActionArea.GetTargetListFromOverlapBox(position, baseData.targetRange / 2, s_hitCache);
                    break;
                default:
                    tempUnitList = BattleActionArea.GetTargetListFromOverlapBox(position, baseData.targetRange / 2, s_hitCache);
                    break;
            }

            BattleActionTargetable nearestUnitTarget;
            if (baseData.skillEffectTarget == SkillEffectTarget.Enemy)
                nearestUnitTarget = GetNearestUnitTargetFromList(tempUnitList, BattleManager.main.GetOppositeTeam(owner.team));
            else
                nearestUnitTarget = GetNearestUnitTargetFromList(tempUnitList, owner.team);

            return nearestUnitTarget;
        }

        private BattleActionTargetable GetNearestUnitTargetFromList(List<BattleActionTargetable> targetList, BattleTeam team)
        {
            BattleActionTargetable nearestUnitTarget = null;
            foreach (BattleActionTargetable target in targetList)
            {
                BattleUnit unit = target.GetBattleUnit();
                if (!unit)
                    continue;

                if (!unit.IsAlive())
                    continue;

                if (unit && unit.team == team)
                {
                    if (nearestUnitTarget == null)
                        nearestUnitTarget = target;
                    else if (
                        Vector3.Distance(owner.transform.position, unit.transform.position) <
                        Vector3.Distance(owner.transform.position, nearestUnitTarget.transform.position))
                        nearestUnitTarget = target;
                }
            }
            return nearestUnitTarget;
        }

        private BattleActionTargetable SearchWeakestTargetInRange(Vector3 position, float range)
        {
            if (s_hitCache == null)
                s_hitCache = new Collider[32];

            List<BattleActionTargetable> tempUnitList;
            switch (baseData.targetAreaType)
            {
                case AbilityData.AreaType.Circle:
                    tempUnitList = BattleActionArea.GetTargetListFromOverlapSphere(position, range, s_hitCache);
                    break;
                default:
                    tempUnitList = BattleActionArea.GetTargetListFromOverlapSphere(position, range, s_hitCache);
                    break;
            }

            BattleActionTargetable nearestUnitTarget;
            if (baseData.skillEffectTarget == SkillEffectTarget.Enemy)
                nearestUnitTarget = GetWeakestUnitTargetFromList(tempUnitList, BattleManager.main.GetOppositeTeam(owner.team));
            else
                nearestUnitTarget = GetWeakestUnitTargetFromList(tempUnitList, owner.team);

            return nearestUnitTarget;
        }

        private BattleActionTargetable GetWeakestUnitTargetFromList(List<BattleActionTargetable> targetList, BattleTeam team)
        {
            BattleActionTargetable weakestUnitTarget = null;
            foreach (BattleActionTargetable target in targetList)
            {
                BattleUnit unit = target.GetBattleUnit();
                if (!unit)
                    continue;

                if (!unit.IsAlive())
                    continue;

                if (unit && unit.team == team)
                {
                    if (weakestUnitTarget == null)
                        weakestUnitTarget = target;
                    else if (unit.hp.current < weakestUnitTarget.GetBattleUnit().hp.current)
                        weakestUnitTarget = target;
                }
            }
            return weakestUnitTarget;
        }

        public bool IsUnitInTargetRange(BattleActionTargetable target)
        {
            Vector3 position = owner.transform.position + baseData.offset;

            if (s_hitCache == null)
                s_hitCache = new Collider[32];

            List<BattleActionTargetable> tempTargetList;
            switch (baseData.targetAreaType)
            {
                case AbilityData.AreaType.Circle:
                    tempTargetList = BattleActionArea.GetTargetListFromOverlapSphere(position, baseData.targetRange.x / 2, s_hitCache);
                    break;
                case AbilityData.AreaType.Box:
                    tempTargetList = BattleActionArea.GetTargetListFromOverlapBox(position, baseData.targetRange / 2, s_hitCache);
                    break;
                default:
                    tempTargetList = BattleActionArea.GetTargetListFromOverlapBox(position, baseData.targetRange / 2, s_hitCache);
                    break;
            }

            return tempTargetList.Contains(target);
        }

        public void Execute()
        {
            // Make sure AoE Target for Auto Attack
            // not just target from find target
            switch (baseData.skillTargetType)
            {
                case SkillTargetType.Target:
                    break;
                case SkillTargetType.Projectile:
                    break;
                case SkillTargetType.Area:
                    SetTargetsWithActionArea();
                    break;
            }

            StartCoroutine(ExecuteActionProcess());
        }

        private IEnumerator ExecuteActionProcess()
        {
            foreach (BattleAction battleAction in baseData.battleActions)
            {
                battleAction.Execute(this);
            }

            yield return null;
            ClearTargets();

            if (owner)
            {
                owner.ResetCurrentActionCard();
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
                BattleManager.main.UncontrolledUnit();
            }
            else
            {
                owner.SetCurrentActionCard(this);
                owner.SetTakeActionState(baseData.animationId);
            }
        }

        private void ClearTargets()
        {
            if (_targets == null)
                _targets = new List<BattleActionTargetable>();
            _targets.Clear();
        }

        private bool CanTargetAlly()
        {
            if (baseData.skillEffectTarget == SkillEffectTarget.Ally ||
                baseData.skillEffectTarget == SkillEffectTarget.All)
                return true;

            return false;
        }

        private bool CanTargetEnemy()
        {
            if (baseData.skillEffectTarget == SkillEffectTarget.Enemy ||
                baseData.skillEffectTarget == SkillEffectTarget.All)
                return true;

            return false;
        }

        public bool CheckTargetingTeam(BattleActionTargetable target)
        {
            bool result = false;

            BattleUnit unit = target.GetBattleUnit();
            if (!unit)
                return true;

            if (CanTargetAlly())
                result = unit.team == owner.team;

            if (CanTargetEnemy())
                result = unit.team != owner.team;

            return result;
        }

        public bool CheckUnitInTargetRange(BattleActionTargetable target)
        {
            return IsUnitInTargetRange(target);
        }

        public bool CheckTargetDamagable(BattleActionTargetable target)
        {
            return target.GetBattleDamagable();
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

            if (baseData.targetAreaType == AbilityData.AreaType.Circle)
            {
                UnityEditor.Handles.color = new Color(0f, 0.7f, 0f, 0.2f);
                UnityEditor.Handles.DrawSolidDisc(trans.position + baseData.offset, Vector3.up, baseData.targetRange.x / 2);

                UnityEditor.Handles.color = new Color(0.7f, 0.0f, 0f, 0.2f);
                UnityEditor.Handles.DrawSolidDisc(trans.position + baseData.offset, Vector3.up, baseData.sizeDelta.x / 2);
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
