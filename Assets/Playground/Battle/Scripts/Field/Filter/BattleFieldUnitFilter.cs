using UnityEngine;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(menuName = "Field/Filter/BattleUnit")]
    public class BattleFieldUnitFilter : BattleFieldContextFilter
    {
        public override List<Transform> Filter(BattleUnit unit, List<Transform> original)
        {
            List<Transform> filtered = new List<Transform>();
            foreach (Transform item in original)
            {
                if (item.GetComponent<BattleUnit>())
                {
                    filtered.Add(item);
                }
            }
            return filtered;
        }
    }
}