using UnityEngine;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(menuName = "Field/Behavior/StayInBattlefield")]
    public class StayInBattlefieldFilteredUMB : BattleFilteredUnitMovementBehaviour
    {
        public override Vector3 CalculateBattlePosition(BattleFieldManager field, List<Transform> context, BattleUnit unit)
        {
            if (field.battleFieldArea.bounds.Contains(unit.targetPosition))
                return unit.targetPosition;

            Vector3 randPos = field.GetRandomBattleFieldPosition();
            return randPos;
        }
    }
}