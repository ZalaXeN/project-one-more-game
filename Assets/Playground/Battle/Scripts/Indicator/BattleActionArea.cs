using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    public static class BattleActionArea
    {
        public static List<BattleUnit> GetUnitListFromOverlapSphere(Vector3 position, float radius)
        {
            List<BattleUnit> unitList = new List<BattleUnit>();
            Collider[] colliders = Physics.OverlapSphere(position, radius);
            foreach(Collider collider in colliders)
            {
                if(collider.TryGetComponent(out BattleUnit unit))
                {
                    unitList.Add(unit);
                }
            }

            return unitList;
        }
    }
}