using UnityEngine;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    public class BattleActionCard : MonoBehaviour
    {
        public BattleUnit owner;
        public bool canUseWithoutOwner;

        public SkillData baseData;

        protected static Collider[] s_hitCache;

        private List<BattleActionTargetable> _targets;
        [HideInInspector]
        public Vector3 targetPosition = Vector3.zero;

        public void SetTarget(BattleActionTargetable target)
        {
            if (_targets == null)
                _targets = new List<BattleActionTargetable>(); 

            _targets.Clear();

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

            if(baseData.targetAreaType == SkillData.AreaType.Circle)
                tempUnitList = BattleActionArea.GetTargetListFromOverlapSphere(targetPosition, baseData.radius, s_hitCache);
            else
                tempUnitList = BattleActionArea.GetTargetListFromOverlapBox(targetPosition, baseData.sizeDelta / 2, s_hitCache);

            _targets = tempUnitList;
        }

        public void SetTargetsWithActionAreaForAutoAttack(bool shouldAlive = true)
        {
            if (s_hitCache == null)
                s_hitCache = new Collider[32];

            List<BattleActionTargetable> tempTargetList;

            if (baseData.targetAreaType == SkillData.AreaType.Circle)
                tempTargetList = BattleActionArea.GetTargetListFromOverlapSphere(targetPosition, baseData.radius, s_hitCache);
            else
                tempTargetList = BattleActionArea.GetTargetListFromOverlapBox(targetPosition, baseData.sizeDelta / 2, s_hitCache);

            if (canUseWithoutOwner)
            {
                _targets = tempTargetList;
                return;
            }

            ClearTargets();

            foreach (BattleActionTargetable target in tempTargetList)
            {
                if (!target)
                    continue;

                BattleUnit unit = target.GetBattleUnit();
                if (!unit)
                    continue;

                if (!unit.IsAlive() && shouldAlive)
                    continue;

                if (baseData.skillEffectTarget == SkillEffectTarget.Ally)
                {
                    if (unit.team == owner.team)
                        _targets.Add(target);
                }
                else if (baseData.skillEffectTarget == SkillEffectTarget.Enemy)
                {
                    if (unit.team != owner.team)
                        _targets.Add(target);
                }
                else if (baseData.skillEffectTarget == SkillEffectTarget.All)
                {
                    _targets.Add(target);
                }
            }
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
            BattleUnit unit = SearchNearestTargetInRange(owner.transform.position + baseData.offset);
            BattleActionTargetable target = unit ? unit.GetComponent<BattleActionTargetable>() : null;

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
                    SetTargetsWithActionAreaForAutoAttack();
                    break;
            }
        }

        private BattleUnit SearchNearestTargetInRange(Vector3 position)
        {
            if (s_hitCache == null)
                s_hitCache = new Collider[32];

            List<BattleActionTargetable> tempUnitList;
            switch (baseData.targetAreaType)
            {
                case SkillData.AreaType.Circle:
                    tempUnitList = BattleActionArea.GetTargetListFromOverlapSphere(position, baseData.targetRange.x / 2, s_hitCache);
                    break;
                case SkillData.AreaType.Box:
                    tempUnitList = BattleActionArea.GetTargetListFromOverlapBox(position, baseData.targetRange / 2, s_hitCache);
                    break;
                default:
                    tempUnitList = BattleActionArea.GetTargetListFromOverlapBox(position, baseData.targetRange / 2, s_hitCache);
                    break;
            }

            BattleUnit nearestUnit;
            if (baseData.skillEffectTarget == SkillEffectTarget.Enemy)
                nearestUnit = GetNearestUnitFromList(tempUnitList, BattleManager.main.GetOppositeTeam(owner.team));
            else
                nearestUnit = GetNearestUnitFromList(tempUnitList, owner.team);

            return nearestUnit;
        }

        private BattleUnit GetNearestUnitFromList(List<BattleActionTargetable> targetList, BattleTeam team)
        {
            BattleUnit nearestUnit = null;
            foreach (BattleActionTargetable target in targetList)
            {
                BattleUnit unit = target.GetComponent<BattleUnit>();
                if (!unit)
                    continue;

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

        public bool IsUnitInTargetRange(BattleActionTargetable target)
        {
            Vector3 position = owner.transform.position + baseData.offset;

            if (s_hitCache == null)
                s_hitCache = new Collider[32];

            List<BattleActionTargetable> tempTargetList;
            switch (baseData.targetAreaType)
            {
                case SkillData.AreaType.Circle:
                    tempTargetList = BattleActionArea.GetTargetListFromOverlapSphere(position, baseData.targetRange.x / 2, s_hitCache);
                    break;
                case SkillData.AreaType.Box:
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

            BattleUnit unit = target.GetComponent<BattleUnit>();
            if (!unit)
                return false;

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
