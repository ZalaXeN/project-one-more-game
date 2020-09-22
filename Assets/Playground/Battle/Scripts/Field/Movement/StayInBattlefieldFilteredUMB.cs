using UnityEngine;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(menuName = "Field/Behavior/StayInBattlefield")]
    public class StayInBattlefieldFilteredUMB : BattleFilteredUnitMovementBehaviour
    {
        public override Vector3 CalculateMove(BattleFieldManager field, List<Transform> context, BattleUnit unit)
        {
            if (field.battleFieldArea.bounds.Contains(unit.transform.position))
                return Vector3.zero;

            Vector3 currentPos = unit.transform.position;
            Vector3 closestPoint = field.battleFieldArea.bounds.ClosestPoint(currentPos);
            Vector3 centerOffset = (closestPoint - currentPos);

            return centerOffset;
        }
    }
}