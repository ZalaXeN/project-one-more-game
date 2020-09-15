using UnityEngine;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(menuName = "Field/Behavior/Cohesion")]
    public class CohesionFUMB : BattleFilteredUnitMovementBehaviour
    {
        public override Vector3 CalculateBattlePosition(BattleFieldManager field, List<Transform> context, BattleUnit unit)
        {
            //if no neighbors, return no adjustment
            if (context.Count == 0)
                return unit.targetPosition;

            //add all points together and average
            Vector3 cohesionMove = Vector3.zero;
            List<Transform> filteredContext = (contextFilter == null) ? context : contextFilter.Filter(unit, context);
            foreach (Transform item in filteredContext)
            {
                cohesionMove += item.position;
            }
            cohesionMove /= context.Count;

            return cohesionMove;
        }
    }
}