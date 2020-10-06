﻿using UnityEngine;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    public abstract class BattleUnitMovementBehaviour : ScriptableObject
    {
        public abstract Vector3 CalculateMove(BattleFieldManager field, List<Transform> context, BattleUnit unit);
    }
}