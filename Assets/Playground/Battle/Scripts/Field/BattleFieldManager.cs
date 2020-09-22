using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    public class BattleFieldManager : MonoBehaviour
    {
        [Header("Spawn Area Settings")]
        public Collider enemySpawnArea;
        public Collider playerSpawnArea;

        [Header("Battlefield Area Settings")]
        public Collider battleFieldArea;

        [Header("Movement Basic Behaviour")]
        public BattleUnitMovementBehaviour basicMovementBehaviour;

        public Vector3 GetSpawnPosition(BattleTeam team)
        {
            Bounds bound = team == BattleTeam.Player ? playerSpawnArea.bounds : enemySpawnArea.bounds;
            Vector3 result = new Vector3(
                Random.Range(bound.min.x, bound.max.x),
                Random.Range(bound.min.y, bound.max.y),
                Random.Range(bound.min.z, bound.max.z));
            return result;
        }

        public Vector3 GetRandomBattleFieldPosition()
        {
            Bounds bound = battleFieldArea.bounds;
            Vector3 result = new Vector3(
                Random.Range(bound.min.x, bound.max.x),
                Random.Range(bound.min.y, bound.max.y),
                Random.Range(bound.min.z, bound.max.z));
            return result;
        }

        public void UpdateBattlePosition(List<BattleUnit> unitList)
        {
            foreach (BattleUnit unit in unitList)
            {
                List<Transform> context = GetNearbyObjects(unit);

                Vector3 target = unit.transform.position + basicMovementBehaviour.CalculateMove(this, context, unit);

                unit.Move(target);
            }
        }

        public BattleUnit GetAttackTarget(BattleUnit unit)
        {
            Collider[] contextColliders = Physics.OverlapSphere(unit.centerTransform.position, unit.attackRadius);
            foreach (Collider c in contextColliders)
            {
                if (c != unit.unitCollider)
                {
                    BattleUnit u = c.GetComponent<BattleUnit>();
                    if (u && u.team != unit.team)
                    {
                        return u;
                    }
                }
            }
            return null;
        }

        private List<Transform> GetNearbyObjects(BattleUnit unit)
        {
            List<Transform> context = new List<Transform>();
            Collider[] contextColliders = Physics.OverlapSphere(unit.centerTransform.position, unit.neighborRadius);
            foreach (Collider c in contextColliders)
            {
                if (c != unit.unitCollider)
                {
                    context.Add(c.transform);
                }
            }
            return context;
        }
    }
}