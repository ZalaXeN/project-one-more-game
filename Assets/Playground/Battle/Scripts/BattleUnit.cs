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

        public BattleActionCard autoAttackCard;

        private Vector3 targetPosition;
        private Vector3 targetPositionRange;

        private BattleActionCard _currentBattleActionCard;

        private float autoAttackCooldown = 0f;

        private SpriteRenderer[] _spriteRenderers;

        #region Initialiazation
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

        private void InitLinkedSTB()
        {
            if (animator == null)
                return;

            BehaviourLinkedSMB<BattleUnit>.Init(animator, this);
        }

        #endregion

        #region Unity Script Lifecycle
        private void Start()
        {
            InitLinkedSTB();
            InitStats();
            targetPosition = transform.position;
            targetPositionRange = new Vector3(Random.Range(-0.1f, 0.1f), 0f, Random.Range(-0.1f, 0.1f));

            if (BattleManager.main == null)
                return;

            autoAttackCooldown = BattleManager.main.GetAutoAttackCooldown(spd.current);
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

            UpdateAutoAttack();

            UpdateAnimation();
        }

        private void OnDisable()
        {
            BattleManager.main.UnitDeadEvent -= HandleUnitDeadEvent;
            BattleManager.main.ColumnUpdateEvent -= HandleColumnUpdateEvent;
        }
        #endregion

        #region Unity Script Event
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
        #endregion

        #region On Update Script

        public void ExecuteCurrentBattleAction()
        {
            // TODO 
            // Change target follow BAC
            BattleUnit target = BattleManager.main.GetFrontmostUnit(
                BattleManager.main.GetOppositeTeam(team), attackType);

            if (target == null || !target.IsAlive() || _currentBattleActionCard == null)
                return;

            _currentBattleActionCard.SetTarget(target);
            _currentBattleActionCard.Execute();
        }

        private void UpdateAutoAttack()
        {
            if (BattleManager.main == null)
                return;

            if (autoAttackCooldown > 0f)
                autoAttackCooldown -= Time.deltaTime;

            if (autoAttackCooldown > 0f || 
                isMovingToTarget || isUseSpecificPosition || !IsAlive() ||
                BattleManager.main.battleState != BattleState.Battle)
                return;

            BattleUnit target = BattleManager.main.GetFrontmostUnit(
                BattleManager.main.GetOppositeTeam(team), attackType);

            if (target != null)
            {
                _currentBattleActionCard = autoAttackCard;
                autoAttackCooldown = BattleManager.main.GetAutoAttackCooldown(spd.current);
                animator.SetTrigger("attack");
            }
            else
            {
                autoAttackCooldown = GameConfig.BATTLE_HIGHEST_AUTO_ATTACK_SPEED;
            }
        }

        #endregion

        public void TakeDamage(BattleDamage damage)
        {
            BattleManager.main.ShowDamageNumber(damage.damage, transform.position);

            hp.current -= damage.damage;

            animator.SetTrigger("hit");
            BattleManager.main.battleParticleManager.ShowParticle(damage.hitEffect, transform.position);

            if (!IsAlive())
            {
                Dead();
            }
        }

        public bool IsAlive()
        {
            return hp.current > 0;
        }

        // Dead
        public void Dead()
        {
            animator.SetTrigger("dead");
            BattleManager.main.TriggerUnitDead(this);
        }

        public void DestroyUnit()
        {
            if (hp.current > 0)
                return;

            Destroy(gameObject);
        }

        public void DebugShowAttackTypeOutline()
        {
            //// Debug
            //if (attackType == BattleUnitAttackType.Melee)
            //    SetOutlineColor(Color.red);
            //else
            //    SetOutlineColor(Color.green);
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

        private void SetSpriteMaterial(Material mat)
        {
            if (_spriteRenderers == null)
            {
                _spriteRenderers = GetComponentsInChildren<SpriteRenderer>();
            }

            foreach (SpriteRenderer sprite in _spriteRenderers)
            {
                if (sprite.GetComponent<SwingEffector>())
                    continue;

                sprite.material = mat;
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
            if (!isMovingToTarget || !IsAlive())
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
            if (animator == null || testMoving)
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

            BattleManager.main.SetOutlineFXColor();
            foreach (SpriteRenderer sprite in _spriteRenderers)
            {
                // Tint
                //sprite.color = Color.red;

                SetSpriteMaterial(BattleManager.main.outlineMaterial);
            }
        }

        private void DeHighlight()
        {
            if (_spriteRenderers == null)
            {
                _spriteRenderers = GetComponentsInChildren<SpriteRenderer>();
            }

            BattleManager.main.HideOutlineFXColor();
            foreach (SpriteRenderer sprite in _spriteRenderers)
            {
                // Tint
                //sprite.color = Color.white;

                SetSpriteMaterial(BattleManager.main.noAlphaMaterial);
            }
        }

        #region Test Animation

        private bool testMoving = false;

        public void ToggleAnimatorBool(string name)
        {
            bool current = animator.GetBool(name);
            animator.SetBool(name, !current);
        }

        public void ToggleTestMoving()
        {
            ToggleAnimatorBool("moving");
            testMoving = !testMoving;
            isMovingToTarget = testMoving;
        }

        public void ToggleIdle()
        {
            animator.SetBool("moving", false);
            testMoving = false;
            isMovingToTarget = testMoving;
        }

        #endregion

        #region Gizmos
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
        #endregion
    }
}
