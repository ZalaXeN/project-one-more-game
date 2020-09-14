using UnityEngine;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    public abstract class BattleFieldContextFilter : ScriptableObject
    {
        public abstract List<Transform> Filter(BattleUnit unit, List<Transform> original);
    }
}