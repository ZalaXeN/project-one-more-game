using UnityEngine;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(menuName = "Field/Behavior/MoveToTargetPosition")]
    public class MoveToTargetPositionUMB : BattleFilteredUnitMovementBehaviour
    {
        public override Vector3 CalculateMove(BattleFieldManager field, List<Transform> context, BattleUnit unit)
        {
            if (unit.GetTargetPosition() == Vector3.zero)
                return Vector3.zero;

            Vector3 currentPos = unit.transform.position;
            Vector3 targetPos = unit.GetTargetPosition();
            Vector3 centerOffset = (targetPos - currentPos);

            return centerOffset.normalized;
        }
    }
}