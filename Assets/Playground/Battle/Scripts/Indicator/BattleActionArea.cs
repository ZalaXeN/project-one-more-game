using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    public static class BattleActionArea
    {
        public static List<BattleUnit> GetUnitListFromOverlapSphere(Vector3 position, float radius, Collider[] hitCache)
        {
            List<BattleUnit> unitList = new List<BattleUnit>();
            int contacts = Physics.OverlapSphereNonAlloc(position, radius, hitCache);

            for(int i = 0; i < contacts; ++i)
            {
                Collider collider = hitCache[i];
                if (collider == null)
                    continue;

                if(collider.TryGetComponent(out BattleUnit unit))
                {
                    unitList.Add(unit);
                }
            }

            return unitList;
        }
    }
}