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

        [Header("Controllable Unit Movement Behaviour")]
        public BattleUnitMovementBehaviour controllableMovementBehaviour;

        protected static Collider[] s_attackRangeCollider = new Collider[32];
        protected static Collider[] s_nearbyObjectCollider = new Collider[32];

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
                UpdateBattlePosition(unit);
            }
        }

        public void UpdateBattlePosition(BattleUnit unit)
        {
            List<Transform> context = GetNearbyObjects(unit);

            BattleUnitMovementBehaviour targetBehaviour;
            if (unit.IsControlled())
            {
                targetBehaviour = controllableMovementBehaviour;
            }
            else
            {
                targetBehaviour = basicMovementBehaviour;
            }

            Vector3 move = targetBehaviour.CalculateMove(this, context, unit);

            unit.Move(move);
        }

        public BattleUnit GetNearestAttackTarget(BattleUnit unit)
        {
            return BattleManager.main.GetNearestAttackTarget(unit);
        }

        private List<Transform> GetNearbyObjects(BattleUnit unit)
        {
            List<Transform> context = new List<Transform>();
            Collider[] contextColliders = Physics.OverlapSphere(unit.centerTransform.position, unit.neighborRadius);
            //Physics.OverlapSphereNonAlloc(unit.transform.position, unit.attackRadius, s_nearbyObjectCollider);
            foreach (Collider c in contextColliders)
            {
                if (c == null)
                    continue;

                if (c != unit.unitCollider)
                {
                    context.Add(c.transform);
                }
            }
            return context;
        }
    }
}