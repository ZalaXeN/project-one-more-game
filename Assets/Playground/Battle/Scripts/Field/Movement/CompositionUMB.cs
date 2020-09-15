using UnityEngine;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(menuName = "Field/Behavior/CompositeBehaviour")]
    public class CompositionUMB : BattleUnitMovementBehaviour
    {
        public BattleUnitMovementBehaviour[] behaviours;

        public override Vector3 CalculateBattlePosition(BattleFieldManager field, List<Transform> context, BattleUnit unit)
        {
            //set up move
            Vector3 moveTargetPos = unit.targetPosition;
            int calcCounter = 1;

            //iterate through behaviors
            for (int i = 0; i < behaviours.Length; i++)
            {
                Vector3 partialTargetPos = behaviours[i].CalculateBattlePosition(field, context, unit);
                if (partialTargetPos == unit.targetPosition)
                    continue;

                calcCounter++;
                moveTargetPos += partialTargetPos;
            }

            moveTargetPos /= calcCounter;

            //if (field.battleFieldArea.bounds.Contains(moveTargetPos))
            //    return moveTargetPos;

            //Vector3 closestPoint = field.battleFieldArea.bounds.ClosestPoint(moveTargetPos);
            //return closestPoint;

            return moveTargetPos;
        }
    }
}