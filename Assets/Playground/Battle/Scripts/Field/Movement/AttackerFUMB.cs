﻿using UnityEngine;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(menuName = "Field/Behavior/Attacker")]
    public class AttackerFUMB : BattleFilteredUnitMovementBehaviour
    {
        public override Vector3 CalculateMove(BattleFieldManager field, List<Transform> context, BattleUnit unit)
        {
            // Target in Attack Range
            if(field.GetNearestEnemyUnitInAttackRange(unit) != null)
                return Vector3.zero;

            // No Target find new target
            BattleUnit target = field.GetNearestAttackTarget(unit);
            if (target == null)
                return Vector3.zero;

            // Move to target
            Vector3 currentPos = unit.transform.position;
            Vector3 targetPos = target.transform.position;
            Vector3 offset = (targetPos - currentPos);

            return offset.normalized;
        }
    }
}