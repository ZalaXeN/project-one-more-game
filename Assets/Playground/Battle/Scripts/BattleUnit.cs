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

    public enum BattleUnitAttackType
    {
        Melee,
        Range
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

        public BattleUnitAttackType attackType;

        public int column = 0;
        public int columnIndex = 0;
        public float columnDepth = 0f;
        public float moveSpeedMultiplier = 1f;
        public bool isUseSpecificPosition = false;
        public bool isMovingToTarget = false;

        public Animator animator;

        private Vector3 targetPosition;
        private Vector3 targetPositionRange;

        private SpriteRenderer[] _spriteRenderers;

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

            BattleManager.main.UnitDeadEvent += HandleUnitDeadEvent;
            BattleManager.main.ColumnUpdateEvent += HandleColumnUpdateEvent;
        }

        private void Update()
        {
            if (!isUseSpecificPosition)
            {
                UpdateTargetPosition();
                MoveToTargetPosition();
            }

            UpdateAnimation();
        }

        private void OnDisable()
        {
            BattleManager.main.UnitDeadEvent -= HandleUnitDeadEvent;
            BattleManager.main.ColumnUpdateEvent -= HandleColumnUpdateEvent;
        }

        // Click
        public void OnMouseUpAsButton()
        {
            if (BattleManager.main.battleState != BattleState.PlayerInput)
                return;

            if (BattleManager.main.CanCurrentActionTarget(this))
            {
                DeHighlight();
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
                Highlight();
        }

        public void OnMouseExit()
        {
            if (BattleManager.main.battleState != BattleState.PlayerInput)
                return;

            if (BattleManager.main.CanCurrentActionTarget(this))
                DeHighlight();
        }

        // Dead
        public void Dead()
        {
            BattleManager.main.TriggerUnitDead(this);
            Destroy(gameObject);
        }

        public void DebugShowAttackTypeOutline()
        {
            // Debug
            if (attackType == BattleUnitAttackType.Melee)
                SetOutlineColor(Color.red);
            else
                SetOutlineColor(Color.green);
        }

        private void SetOutlineColor(Color targetColor)
        {
            if(_spriteRenderers == null)
            {
                _spriteRenderers = GetComponentsInChildren<SpriteRenderer>();
            }

            foreach(SpriteRenderer sprite in _spriteRenderers)
            {
                sprite.material.SetColor("Outline_Color", targetColor);
                sprite.material.SetInt("Outline", 1);
            }
        }

        private void UpdateTargetPosition()
        {
            if (BattleManager.main == null)
                return;

            targetPosition = BattleManager.main.columnManager.GetBattlePosition(team, column, columnDepth) + targetPositionRange;
            isMovingToTarget = !(transform.position == targetPosition);
        }

        private void MoveToTargetPosition()
        {
            if (!isMovingToTarget)
                return;

            float step = spd.current * moveSpeedMultiplier * Time.deltaTime;
            transform.position = Vector3.MoveTowards(transform.position, targetPosition, step);

            if (Vector3.Distance(transform.position, targetPosition) < 0.001f)
            {
                targetPosition = transform.position;
                isMovingToTarget = !(transform.position == targetPosition);
            }
        }

        private void UpdateAnimation()
        {
            if (animator == null)
                return;

            animator.SetBool("moving", isMovingToTarget);
        }

        private void HandleUnitDeadEvent(BattleUnit unit)
        {
            if(unit.team == team && unit.column == column)
            {
                if (unit.columnIndex < columnIndex)
                    columnIndex--;
            }
        }

        private void HandleColumnUpdateEvent(BattleColumn battleColumn)
        {
            if(battleColumn.team == team && battleColumn.columnNumber == column)
            {
                columnDepth = BattleManager.main.columnManager.GetNearestBattleColumnDepth(team, column, columnDepth, this);
                columnIndex = BattleManager.main.columnManager.GetColumnIndex(team, column, columnDepth);
            }
        }

        private void Highlight()
        {
            if (_spriteRenderers == null)
            {
                _spriteRenderers = GetComponentsInChildren<SpriteRenderer>();
            }

            foreach (SpriteRenderer sprite in _spriteRenderers)
            {
                sprite.color = Color.red;
            }
        }

        private void DeHighlight()
        {
            if (_spriteRenderers == null)
            {
                _spriteRenderers = GetComponentsInChildren<SpriteRenderer>();
            }

            foreach (SpriteRenderer sprite in _spriteRenderers)
            {
                sprite.color = Color.white;
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
