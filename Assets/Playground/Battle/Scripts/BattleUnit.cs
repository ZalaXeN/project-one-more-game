using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using ProjectOneMore;

namespace ProjectOneMore.Battle
{
    public enum BattleTeam
    {
        Player,
        Enemy
    }

    public class BattleUnit : MonoBehaviour
    {
        public BattleTeam team;

        public KeeperData baseData;

        public BattleUnitStat hp;
        public BattleUnitStat en;
        public BattleUnitStat pow;
        public BattleUnitStat cri;
        public BattleUnitStat spd;
        public BattleUnitStat def;

        public int column = 0;
        public int row = 0;
        public bool isMovingToTarget = false;

        private Vector3 targetPosition;
        private Vector3 targetPositionRange;

        // Mock Up
        private void InitStats()
        {
            hp.max = baseData.baseStats.HP;
            hp.current = hp.max;

            en.max = baseData.baseStats.EN;
            en.current = en.max;

            pow.max = baseData.baseStats.POW;
            pow.current = pow.max;

            cri.max = baseData.baseStats.CRI;
            cri.current = cri.max;

            spd.max = baseData.baseStats.SPD;
            spd.current = spd.max;

            def.max = baseData.baseStats.DEF;
            def.current = def.max;
        }

        private void Start()
        {
            InitStats();
            targetPosition = transform.position;
            targetPositionRange = new Vector3(Random.Range(-0.1f, 0.1f), 0f, Random.Range(-0.1f, 0.1f));
        }

        private void Update()
        {
            if (isMovingToTarget)
            {
                UpdateTargetPosition();
                MoveToTargetPosition();
            }
        }

        // Click
        public void OnMouseUpAsButton()
        {
            if (BattleManager.main.battleState != BattleState.PlayerInput)
                return;

            if (BattleManager.main.CanCurrentActionTarget(this))
            {
                Debug.LogFormat("Click on: {0}", baseData.keeperName);
                BattleManager.main.SetCurrentActionTarget(this);
                BattleManager.main.CurrentActionTakeAction();
            }
        }

        // Hover
        public void OnMouseEnter()
        {
            if (BattleManager.main.battleState != BattleState.PlayerInput)
                return;

            if (BattleManager.main.CanCurrentActionTarget(this))
                Debug.LogFormat("Highlight: {0}", baseData.keeperName);
        }

        public void OnMouseExit()
        {
            if (BattleManager.main.battleState != BattleState.PlayerInput)
                return;

            if (BattleManager.main.CanCurrentActionTarget(this))
                Debug.LogFormat("Dehighlight: {0}", baseData.keeperName);
        }

        // Dead
        public void Dead()
        {
            Destroy(gameObject);
        }

        // Reposition
        [ContextMenu("Test Position")]
        public void ResetPosition()
        {
            if (BattleManager.main == null)
                return;

            transform.position = BattleManager.main.GetBattlePosition(column, row);
        }

        private void UpdateTargetPosition()
        {
            if (BattleManager.main == null)
                return;

            targetPosition = BattleManager.main.GetBattlePosition(column, row) + targetPositionRange;
        }

        private void MoveToTargetPosition()
        {
            float step = spd.current * Time.deltaTime;
            transform.position = Vector3.MoveTowards(transform.position, targetPosition, step);

            if (Vector3.Distance(transform.position, targetPosition) < 0.001f)
            {
                targetPosition = transform.position;
            }
        }

#if UNITY_EDITOR
        private void OnDrawGizmos()
        {
            DrawHpLabel();
            DrawMovePath();
        }

        private void DrawHpLabel()
        {
            Handles.Label(transform.position + Vector3.up * 0.2f, string.Format("HP: {0} / {1}", hp.current, hp.max));
        }

        private void DrawMovePath()
        {
            Handles.color = Color.green;
            Handles.DrawLine(transform.position, targetPosition);
        }
#endif
    }
}
