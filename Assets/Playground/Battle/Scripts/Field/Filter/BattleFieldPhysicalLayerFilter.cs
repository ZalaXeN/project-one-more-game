using UnityEngine;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(menuName = "Field/Filter/PhysicalLayer")]
    public class BattleFieldPhysicalLayerFilter : BattleFieldContextFilter
    {
        public LayerMask mask;

        public override List<Transform> Filter(BattleUnit unit, List<Transform> original)
        {
            List<Transform> filtered = new List<Transform>();
            foreach (Transform item in original)
            {
                if (mask == (mask | (1 << item.gameObject.layer)))
                {
                    filtered.Add(item);
                }
            }
            return filtered;
        }
    }
}