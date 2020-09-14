using UnityEngine;
using System.Collections;

namespace ProjectOneMore.Battle
{
    public abstract class BattleFilteredUnitMovementBehaviour : BattleUnitMovementBehaviour
    {
        public BattleFieldContextFilter contextFilter;
    }
}