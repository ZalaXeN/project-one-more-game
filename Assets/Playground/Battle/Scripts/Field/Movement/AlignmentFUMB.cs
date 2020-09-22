using UnityEngine;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(menuName = "Field/Behavior/Alignment")]
    public class AlignmentFUMB : BattleFilteredUnitMovementBehaviour
    {
        public override Vector3 CalculateMove(BattleFieldManager field, List<Transform> context, BattleUnit unit)
        {
            //if no neighbors, maintain current alignment
            if (context.Count == 0)
                return Vector3.zero;

            //add all points together and average
            Vector3 alignmentMove = Vector3.zero;
            List<Transform> filteredContext = (contextFilter == null) ? context : contextFilter.Filter(unit, context);
            foreach (Transform item in filteredContext)
            {
                alignmentMove += item.transform.position;

                // TODO Replace
                // alignmentMove += unit.moveDirection;
            }
            alignmentMove /= context.Count;

            return alignmentMove;
        }
    }
}