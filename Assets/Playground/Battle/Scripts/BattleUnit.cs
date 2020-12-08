using UnityEngine;
using UnityEditor;
using System.Collections;

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

    public enum BattleUnitState
    {
        Idle,
        Moving,
        Action,
        Hit,
        Dead
    }

    public class BattleUnit : MonoBehaviour
    {
        [Header("Settings")]
        public Animator animator;
        public Transform centerTransform;
        public Collider unitCollider;
        public Collider interactCollider;

        public float neighborRadius = 5f;
        public float attackRadius = 2f;

        [Header("Data")]
        public BattleTeam team;

        public KeeperData baseData;

        public BattleUnitStat hp;
        public BattleUnitStat en;
        public BattleUnitStat pow;
        public BattleUnitStat cri;
        public BattleUnitStat spd;
        public BattleUnitStat def;

        public BattleUnitAttackType attackType;

        public float moveSpeedMultiplier = 1f;

        [Header("Movement Tester")]
        public bool isUseSpecificPosition = false;

        // TODO Test
        public Vector3 targetPosition;

        [Header("Auto Attack")]
        public BattleActionCard autoAttackCard;

        [Header("Unit State")]
        [SerializeField]
        private BattleUnitState _currentState;

        private BattleActionCard _currentBattleActionCard;
        private float _autoAttackCooldown = 0f;
        private BattleUnit _currentActionTarget;

        private SpriteRenderer[] _spriteRenderers;

        #region Initialization
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

        private void InitBattleParameter()
        {
            if (BattleManager.main == null)
                return;

            BattleManager.main.AddUnitIfNeed(this);

            _autoAttackCooldown = BattleManager.main.GetAutoAttackCooldown(spd.current);
            BattleManager.main.UnitDeadEvent += HandleUnitDeadEvent;
        }

        #endregion

        #region Unity Script Lifecycle
        private void Start()
        {
            InitLinkedSTB();
            InitStats();
            targetPosition = transform.position;

            InitBattleParameter();
            if(centerTransform == null)
                centerTransform = transform;
        }

        private void Update()
        {
            UpdatePosition();

            UpdateAutoAttack();

            UpdateAnimation();
        }

        private void OnDisable()
        {
            BattleManager.main.UnitDeadEvent -= HandleUnitDeadEvent;
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

        private void UpdateAnimation()
        {
            if (animator == null || testMoving)
                return;

            animator.SetBool("moving", _currentState == BattleUnitState.Moving);
        }

        public void ExecuteCurrentBattleAction()
        {
            // TODO 
            // Change target follow BAC
            _currentActionTarget = BattleManager.main.fieldManager.GetNearestEnemyUnitInAttackRange(this);

            if (_currentActionTarget == null || _currentBattleActionCard == null)
                return;

            _currentBattleActionCard.SetTarget(_currentActionTarget);
            _currentBattleActionCard.targetPosition = _currentActionTarget.transform.position;
            _currentBattleActionCard.Execute();
        }

        private void UpdateAutoAttack()
        {
            if (BattleManager.main == null || autoAttackCard == null)
                return;

            if (_autoAttackCooldown > 0f)
                _autoAttackCooldown -= Time.deltaTime;

            if (_autoAttackCooldown > 0f || 
                _currentState != BattleUnitState.Idle ||
                !BattleManager.main.CanUpdateTimer())
                return;

            _currentActionTarget = BattleManager.main.fieldManager.GetNearestEnemyUnitInAttackRange(this);

            if (_currentActionTarget != null)
            {
                _currentBattleActionCard = autoAttackCard;
                _autoAttackCooldown = BattleManager.main.GetAutoAttackCooldown(spd.current);
                animator.SetTrigger("attack");
            }
            else
            {
                _autoAttackCooldown = GameConfig.BATTLE_HIGHEST_AUTO_ATTACK_SPEED;
            }
        }

        #endregion

        #region Battle

        public void SetState(BattleUnitState state)
        {
            _currentState = state;
        }

        public void TakeDamage(BattleDamage damage)
        {
            if (damage.owner.team == team)
                return;

            BattleManager.main.ShowDamageNumber(damage.damage, transform.position);

            hp.current -= damage.damage;

            BattleManager.main.battleParticleManager.ShowParticle(damage.hitEffect, centerTransform.position);
            BattleManager.main.battleParticleManager.ShowParticle("blood", centerTransform.position);

            if (!IsAlive())
            {
                if(_currentState != BattleUnitState.Dead)
                    Dead();
            }
            else
            {
                animator.SetTrigger("hit");
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
        }

        public void DestroyUnit()
        {
            if (hp.current > 0)
                return;

            BattleManager.main.TriggerUnitDead(this);

            StartCoroutine(SinkAndDestroy());
        }

        private IEnumerator SinkAndDestroy()
        {
            //Coroutine sinkCoroutine = StartCoroutine(Sinking());
            yield return StartCoroutine(Dissolving());
            //StopCoroutine(sinkCoroutine);
            Destroy(gameObject);
        }

        private IEnumerator Sinking()
        {
            while (transform.position.y > -10f)
            {
                transform.position += Vector3.down * Time.deltaTime;
                yield return null;
            }
        }

        private IEnumerator Dissolving()
        {
            float progress = 0f;
            while (progress < 1f)
            {
                progress += 1 * Time.deltaTime;
                SetDissolveProgress(progress);
                yield return null;
            }
            progress = 1f;
        }

        #endregion

        #region Outline Highlight

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

        private void Highlight()
        {
            BattleManager.main.SetOutlineFXColor();
            SetSpriteMaterial(BattleManager.main.outlineMaterial);
        }

        private void DeHighlight()
        {
            BattleManager.main.HideOutlineFXColor();
            SetSpriteMaterial(BattleManager.main.noAlphaMaterial);
        }
        #endregion

        #region Sprite
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

        private void SetDissolveProgress(float progress)
        {
            if (_spriteRenderers == null)
            {
                _spriteRenderers = GetComponentsInChildren<SpriteRenderer>();
            }

            foreach (SpriteRenderer sprite in _spriteRenderers)
            {
                if (sprite.GetComponent<SwingEffector>())
                    continue;

                sprite.gameObject.layer = LayerMask.NameToLayer("Effect");
                sprite.material.SetFloat("Dissolve_Progress", progress);
            }
        }

        #endregion

        #region Positioning

        public void Move(Vector3 targetPosition)
        {
            this.targetPosition = targetPosition;
        }

        private void UpdatePosition()
        {
            if (!isUseSpecificPosition)
            {
                MoveToTargetPosition();
            }
        }

        private void MoveToTargetPosition()
        {
            if (_currentState != BattleUnitState.Idle &&
                _currentState != BattleUnitState.Moving)
                return;

            _currentState = BattleUnitState.Moving;

            float step = BattleManager.main.GetMovespeedStep(spd.current, moveSpeedMultiplier);
            transform.position = Vector3.MoveTowards(transform.position, targetPosition, step);

            if (Vector3.Distance(transform.position, targetPosition) < 0.001f)
            {
                targetPosition = transform.position;
                _currentState = BattleUnitState.Idle;
            }
        }

        #endregion

        #region Battle Event Handler
        private void HandleUnitDeadEvent(BattleUnit unit)
        {
            
        }

        #endregion

        #region Test Animation

        private bool testMoving = false;

        public void TriggerTestAnimation(string name)
        {
            animator.SetTrigger(name);
        }

        public void ToggleAnimatorBool(string name)
        {
            bool current = animator.GetBool(name);
            animator.SetBool(name, !current);
        }

        public void ToggleTestMoving()
        {
            ToggleAnimatorBool("moving");
            testMoving = !testMoving;
            _currentState = BattleUnitState.Moving;
        }

        public void ToggleIdle()
        {
            animator.SetBool("moving", false);
            testMoving = false;
            _currentState = BattleUnitState.Idle;
        }

        #endregion

        #region Gizmos
#if UNITY_EDITOR
        private void OnDrawGizmos()
        {
            DrawHpLabel();
            DrawMovePath();
        }

        private void OnDrawGizmosSelected()
        {
            DrawRangeSphere();
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

        private void DrawRangeSphere()
        {
            Transform trans = centerTransform == null ? transform : centerTransform;

            Gizmos.color = Color.blue;
            Gizmos.DrawWireSphere(trans.position, neighborRadius);

            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(trans.position, attackRadius);
        }
#endif
        #endregion
    }
}
