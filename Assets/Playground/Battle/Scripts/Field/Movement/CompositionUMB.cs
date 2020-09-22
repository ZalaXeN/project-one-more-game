using UnityEngine;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(menuName = "Field/Behavior/CompositeBehaviour")]
    public class CompositionUMB : BattleUnitMovementBehaviour
    {
        public BattleUnitMovementBehaviour[] behaviours;

        public override Vector3 CalculateMove(BattleFieldManager field, List<Transform> context, BattleUnit unit)
        {
            //set up move
            Vector3 moveVector = Vector3.zero;
            int calcCounter = 0;

            //iterate through behaviors
            for (int i = 0; i < behaviours.Length; i++)
            {
                Vector3 partialMove = behaviours[i].CalculateMove(field, context, unit);
                if (partialMove == Vector3.zero)
                    continue;

                calcCounter++;
                moveVector += partialMove;
            }

            if (calcCounter > 0) { moveVector /= calcCounter; }

            return moveVector;
        }
    }
}