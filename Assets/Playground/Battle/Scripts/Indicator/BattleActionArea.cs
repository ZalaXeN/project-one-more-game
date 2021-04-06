using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    public static class BattleActionArea
    {
        public static List<BattleActionTargetable> GetTargetListFromOverlapSphere(Vector3 position, float radius, Collider[] hitCache)
        {
            List<BattleActionTargetable> targetList = new List<BattleActionTargetable>();
            int contacts = Physics.OverlapSphereNonAlloc(position, radius, hitCache);

            for(int i = 0; i < contacts; ++i)
            {
                Collider collider = hitCache[i];

                BattleActionTargetable target = collider.GetComponentInChildren<BattleActionTargetable>();

                if(target != null)
                    targetList.Add(target);
            }

            return targetList;
        }

        public static List<BattleActionTargetable> GetTargetListFromOverlapBox(Vector3 position, Vector3 halfExtents, Collider[] hitCache)
        {
            List<BattleActionTargetable> targetList = new List<BattleActionTargetable>();
            int contacts = Physics.OverlapBoxNonAlloc(position, halfExtents, hitCache);

            for (int i = 0; i < contacts; ++i)
            {
                Collider collider = hitCache[i];

                BattleActionTargetable target = collider.GetComponentInChildren<BattleActionTargetable>();

                if (target != null)
                    targetList.Add(target);
            }

            return targetList;
        }
    }
}