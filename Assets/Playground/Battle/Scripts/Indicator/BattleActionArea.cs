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

                BattleUnit unit = collider.GetComponentInChildren<BattleUnit>();

                if(unit != null)
                    unitList.Add(unit);
            }

            return unitList;
        }

        public static List<BattleUnit> GetUnitListFromOverlapBox(Vector3 position, Vector3 halfExtents, Collider[] hitCache)
        {
            List<BattleUnit> unitList = new List<BattleUnit>();
            int contacts = Physics.OverlapBoxNonAlloc(position, halfExtents, hitCache);

            for (int i = 0; i < contacts; ++i)
            {
                Collider collider = hitCache[i];

                BattleUnit unit = collider.GetComponentInChildren<BattleUnit>();

                if (unit != null)
                    unitList.Add(unit);
            }

            return unitList;
        }
    }
}