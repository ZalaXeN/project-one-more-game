﻿using UnityEngine;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(menuName = "Field/Behavior/Avoidance")]
    public class AvoidanceFUMB : BattleFilteredUnitMovementBehaviour
    {
        public override Vector3 CalculateBattlePosition(BattleFieldManager field, List<Transform> context, BattleUnit unit)
        {
            //if no neighbors, return no adjustment
            if (context.Count == 0)
                return unit.targetPosition;

            //add all points together and average
            Vector3 avoidanceMove = Vector3.zero;
            Vector3 avoidanceOffset;
            int nAvoid = 0;
            List<Transform> filteredContext = (contextFilter == null) ? context : contextFilter.Filter(unit, context);
            foreach (Transform item in filteredContext)
            {
                if (Vector3.Magnitude(item.position - unit.transform.position) < unit.neighborRadius)
                {
                    nAvoid++;
                    avoidanceOffset = (unit.transform.position - item.position);
                    avoidanceMove += avoidanceOffset;
                }
            }

            if (nAvoid > 0)
                avoidanceMove /= nAvoid;

            return unit.targetPosition + avoidanceMove;
        }
    }
}