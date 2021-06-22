﻿using UnityEngine;
using UnityEditor;
using System.Collections;

namespace ProjectOneMore.Battle
{
    public enum BattleTeam
    {
        Player,
        Enemy
    }

    public enum BattleUnitState
    {
        Idle,
        Moving,
        Action,
        Hit,
        Dead,
        TakeAction
    }

    public enum BattleUnitSpriteLookDirection
    {
        Left,
        Right
    }

    public class BattleUnit : MonoBehaviour, IMessageReceiver
    {
        [Header("Settings")]
        public Animator animator;
        public Transform centerTransform;
        public Collider unitCollider;
        public Rigidbody rb;

        // For Movement AI
        public float neighborRadius = 5f;

        [Space]
        [Header("Data")]
        public BattleTeam team;

        public UnitData baseData;

        public BattleUnitStat hp;
        public BattleUnitStat en;
        public BattleUnitStat pow;
        public BattleUnitStat cri;
        public BattleUnitStat spd;
        public BattleUnitStat def;

        public int lifeCounter = 1;

        [Space]
        [Header("Movement Tester")]
        public bool isUseSpecificPosition = false;
        public BattleUnitSpriteLookDirection spriteLookDirection;

        private Vector3 _targetPosition;
        private Vector3 _move = Vector3.zero;
        [SerializeField]
        private bool _isGrounded;

        [Space]
        [Header("Card Settings")]
        [Tooltip("use on Auto Action too.")]
        public BattleActionCard normalActionCard;
        public BattleActionCard autoSkillActionCard;

        [Space]
        [Header("Unit State")]
        [SerializeField]
        private BattleUnitState _currentState;
        
        private BattleActionCard _currentBattleActionCard;
        private float _autoAttackCooldown = 0f;
        private float _autoSkillCooldown = 0f;

        private SpriteRenderer[] _spriteRenderers;

        private float _hitLockTimer;
        private float _hitLockBreakTimer;

        private float _poise = 0f;

        private System.Action _schedule;

        // Parameters
        public static readonly int m_HashMoving = Animator.StringToHash("moving");
        public static readonly int m_HashHit = Animator.StringToHash("hit");
        public static readonly int m_HashDie = Animator.StringToHash("die");
        public static readonly int m_HashDied = Animator.StringToHash("died");
        public static readonly int m_HashAttack = Animator.StringToHash("attack");
        public static readonly int m_HashSkill = Animator.StringToHash("skill");
        public static readonly int m_HashCasting = Animator.StringToHash("casting");
        public static readonly int m_HashIsGrounded = Animator.StringToHash("isGrounded");
        public static readonly int m_HashVelocityY = Animator.StringToHash("velocityY");
        public static readonly int m_HashMoveSpeed = Animator.StringToHash("moveSpeed");
        public static readonly int m_HashAttackSpeed = Animator.StringToHash("attackSpeed");
        public static readonly int m_HashCastSpeed = Animator.StringToHash("castSpeed");

        private static readonly float m_groundCheckDistance = 0.1f;

        #region Initialization
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

            if(autoSkillActionCard)
                _autoSkillCooldown = autoSkillActionCard.baseData.GetRandomSkillCooldown();

            BattleManager.main.ChangeBattleStateEvent += HandleChangeBattleStateEvent;
    }

        #endregion

        #region Controller

        public bool IsControlled()
        {
            return (BattleManager.main?.GetCurrentControlledUnit() == this);
        }

        #endregion

        #region Unity Script Lifecycle
        private void Start()
        {
            InitLinkedSTB();
            InitStats();
            _targetPosition = transform.position;

            InitBattleParameter();
            if(centerTransform == null)
                centerTransform = transform;
        }

        private void FixedUpdate()
        {
            CheckGrounded();
            UpdatePosition();
            UpdateAutoSkillAction();
            UpdateAutoAction();
            UpdateHitLockTime();
            DetermineAction();
        }

        void LateUpdate()
        {
            if (_schedule != null)
            {
                _schedule();
                _schedule = null;
            }
        }

        private void OnDisable()
        {
            BattleManager.main.ChangeBattleStateEvent -= HandleChangeBattleStateEvent;
        }
        #endregion

        #region On Update Script

        // Use on Battle Action Card to break Hit Lock
        public void SetTakeActionState(string animationId)
        {
            int animationIdHash = Animator.StringToHash(animationId);
            _currentState = BattleUnitState.TakeAction;
            _move = Vector3.zero;
            animator.ResetTrigger(m_HashHit);
            animator.SetTrigger(animationIdHash);
        }

        // Use on SMB
        public void ExecuteCurrentBattleAction()
        {
            if(_currentBattleActionCard != null)
            {
                ExecuteCurrentActionCard();
            }
            else if (IsControlled())
            {
                BattleManager.main.CurrentActionExecute();
            }
        }

        // Call After Execute Process
        public void ResetCurrentActionCard()
        {
            _currentBattleActionCard = null;
        }

        // Take Action Process
        public void SetCurrentActionCard(BattleActionCard card)
        {
            _currentBattleActionCard = card;
        }

        private void ExecuteCurrentActionCard()
        {
            if (_currentBattleActionCard == null)
                return;

            _currentBattleActionCard.Execute();
        }

        private void UpdateAutoAction()
        {
            if (BattleManager.main == null || normalActionCard == null || IsControlled())
                return;

            if (_autoAttackCooldown > 0f)
                _autoAttackCooldown -= Time.fixedDeltaTime;

            normalActionCard.FindTarget();
        }

        private bool IsAutoNormalActionReady()
        {
            if (normalActionCard == null)
                return false;

            return _autoAttackCooldown <= 0f && normalActionCard.HasTarget();
        }

        private void UpdateAutoSkillAction()
        {
            if (BattleManager.main == null || autoSkillActionCard == null || IsControlled())
                return;

            if (_autoSkillCooldown > 0f)
                _autoSkillCooldown -= Time.fixedDeltaTime;

            autoSkillActionCard.FindTarget();
        }

        private bool IsAutoSkillReady()
        {
            if (autoSkillActionCard == null)
                return false;

            return _autoSkillCooldown <= 0f && autoSkillActionCard.HasTarget();
        }

        private void UpdateHitLockTime()
        {
            if(_currentState == BattleUnitState.Hit)
                _hitLockTimer += Time.fixedDeltaTime;
            else
                _hitLockTimer = 0f;

            if (_hitLockTimer > GameConfig.BATTLE_MOVEMENT_HIT_LOCK_TIME_MAX)
            {
                _hitLockBreakTimer = GameConfig.BATTLE_MOVEMENT_HIT_LOCK_BREAK_TIME;
            }

            if (_hitLockBreakTimer > 0f)
            {
                _hitLockBreakTimer -= Time.fixedDeltaTime;
                _hitLockTimer = 0f;
            }
        }

        public void SetPoise(float value)
        {
            _poise = value;
        }

        private void DetermineAction()
        {
            if (!BattleManager.main.CanUpdateTimer() || !CanAutoAttack() || !InBattlefield())
                return;

            // Ensure Skill use after interrupt from animate hit
            if (_currentBattleActionCard != null && _currentBattleActionCard == autoSkillActionCard)
            {
                animator.SetTrigger(_currentBattleActionCard.baseData.animationId);
                return;
            }

            if (IsAutoSkillReady())
            {
                SetCurrentActionCard(autoSkillActionCard);
                _autoSkillCooldown = autoSkillActionCard.baseData.GetRandomSkillCooldown();
                animator.SetTrigger(_currentBattleActionCard.baseData.animationId);
            }
            else if (IsAutoNormalActionReady())
            {
                SetCurrentActionCard(normalActionCard);
                _autoAttackCooldown = BattleManager.main.GetAutoAttackCooldown(spd.current);
                animator.SetFloat(m_HashAttackSpeed, BattleManager.main.GetMotionSpeed(spd.current));
                animator.SetTrigger(_currentBattleActionCard.baseData.animationId);
            }
        }

        #endregion

        #region Battle

        public void SetState(BattleUnitState state)
        {
            _currentState = state;
        }

        public bool CanAutoAttack()
        {
            return _currentState == BattleUnitState.Idle || _currentState == BattleUnitState.Hit;
        }

        public bool CanMove()
        {
            return 
                (_currentState == BattleUnitState.Idle || _currentState == BattleUnitState.Moving) &&
                !isUseSpecificPosition;
        }

        public bool IsTakeAction()
        {
            return _currentState == BattleUnitState.TakeAction || _currentState == BattleUnitState.Action;
        }

        public bool OnDeadState()
        {
            return _currentState == BattleUnitState.Dead;
        }

        public bool IsHitLockBreakTime()
        {
            return (_hitLockBreakTimer > 0f);
        }

        private bool ShouldTakeDamage(BattleDamage.DamageMessage damage)
        {
            if (damage.effectTarget == SkillEffectTarget.Enemy)
            {
                return damage.owner.team != team;
            }
            else if (damage.effectTarget == SkillEffectTarget.Ally)
            {
                return damage.owner.team == team;
            }
            else if (damage.effectTarget == SkillEffectTarget.All)
            {
                return true;
            }
            else if(damage.effectTarget == SkillEffectTarget.Self)
            {
                return damage.owner == this;
            }

            return false;
        }

        public void TakeDamage(BattleDamage.DamageMessage damage)
        {
            if (!ShouldTakeDamage(damage))
                return;

            if(_isGrounded)
                Knockback(damage.hitPosition, damage.knockbackPower);

            BattleManager.main.BroadcastBattleMessage(MessageType.BEFORE_DAMAGE, this, damage);

            int resultDamage = BattleManager.main.GetDamage(damage, this);
            BattleManager.main.ShowDamageNumber(resultDamage, transform.position, damage.isCritical);

            hp.current -= resultDamage;

            BattleManager.main.battleParticleManager.ShowParticle(damage.hitEffect, centerTransform.position);
            BattleManager.main.battleParticleManager.ShowParticle("blood", centerTransform.position);

            if (!IsAlive())
            {
                if (_currentState != BattleUnitState.Dead)
                    _schedule += Dead;
            }
            else if (!IsTakeAction() && !IsHitLockBreakTime() && _poise < damage.knockbackPower)
            {
                animator.SetTrigger(m_HashHit);
            }
        }

        private void Knockback(Vector3 hitPosition, float forcePower)
        {
            if (!rb)
                return;

            _move = Vector3.zero;

            if (forcePower > _poise)
                forcePower -= _poise;
            else
            {
                forcePower = 0.1f;
            }

            Vector3 pushForce = transform.position - hitPosition;
            pushForce.y = 10f;
            rb.AddForce((pushForce.normalized * forcePower * 100f) - Physics.gravity * 0.6f);
        }

        public bool IsAlive()
        {
            return hp.current > 0;
        }

        // Dead
        private void Dead()
        {
            animator.SetTrigger(m_HashDie);
            animator.SetBool(m_HashDied, true);
        }

        // Called by SMB
        public void DestroyUnit()
        {
            if (hp.current > 0)
                return;

            lifeCounter--;

            if (lifeCounter <= 0)
            {
                BattleManager.main.TriggerUnitDead(this);
                StartCoroutine(SinkAndDestroy());
            }
            else
            {
                // Roll Chance
                animator.SetBool(m_HashDied, false);
            }
        }

        // use on Rise Animation SMB
        public void Rise()
        {
            if (lifeCounter > 0)
            {
                hp.current = (int)(hp.max * 0.5f);
            }
        }

        private IEnumerator SinkAndDestroy()
        {
            //Coroutine sinkCoroutine = StartCoroutine(Sinking());
            yield return new WaitUntil(() => _isGrounded);
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

        public void Move(Vector3 move)
        {
            if (IsTakeAction() || OnDeadState())
                return;

            if (!CanMove() && !IsHitLockBreakTime())
                return;

            if (!_isGrounded)
                return;

            _move += move;
        }

        public bool InBattlefield()
        {
            return BattleManager.main.CheckUnitInBattleField(this);
        }

        private void UpdatePosition()
        {
            // Prevent move on falling or any animation
            if (!CanMove())
                _move = Vector3.zero;

            if (_move == Vector3.zero)
            {
                animator.SetBool(m_HashMoving, false);
            }

            if (IsTakeAction() || OnDeadState())
                return;

            if (_move != Vector3.zero)
                MoveWithMoveDirection();
        }

        private void MoveWithMoveDirection()
        {
            if (!CanMove() && !IsHitLockBreakTime())
                return;

            _targetPosition = transform.position + _move;
            float step = BattleManager.main.GetMovespeedStep(spd.current, baseData.moveSpeed);

            animator.SetFloat(m_HashMoveSpeed, BattleManager.main.GetMotionSpeed(spd.current));
            animator.SetBool(m_HashMoving, true);
            UpdateFlipScale(_targetPosition);

            if (rb)
            {
                rb.MovePosition(transform.position + _move.normalized * step);
            }
            else
            {
                transform.position += _move * step;
            }

            _move = Vector3.zero;
        }

        public bool IsFliped()
        {
            if (transform.localScale.x < 0)
                return true;

            return false;
        }

        public bool ShouldFlip(Vector3 lookPos)
        {
            if (lookPos.x < transform.position.x)
            {
                if (transform.localScale.x < 0 && spriteLookDirection == BattleUnitSpriteLookDirection.Left)
                    return true;
                else if (transform.localScale.x > 0 && spriteLookDirection == BattleUnitSpriteLookDirection.Right)
                    return true;
            }
            else if (lookPos.x > transform.position.x)
            {
                if (transform.localScale.x > 0 && spriteLookDirection == BattleUnitSpriteLookDirection.Left)
                    return true;
                else if (transform.localScale.x < 0 && spriteLookDirection == BattleUnitSpriteLookDirection.Right)
                    return true;
            }

            return false;
        }

        public void UpdateFlipScale(Vector3 lookPos)
        {
            if (ShouldFlip(lookPos))
            {
                FlipScaleX();
            }
        }

        private void FlipScaleX()
        {
            Vector3 targetFlipScale = transform.localScale;
            targetFlipScale.x *= -1;
            transform.localScale = targetFlipScale;
        }

        private void CheckGrounded()
        {
            _isGrounded = Physics.Raycast(transform.position, Vector3.down, m_groundCheckDistance, BattleManager.main.groundLayerMask);
            //Debug.DrawRay(transform.position, Vector3.down * m_groundCheckDistance, _isGrounded ? Color.green : Color.red);

            animator.SetBool(m_HashIsGrounded, _isGrounded);

            if(rb)
                animator.SetFloat(m_HashVelocityY, rb.velocity.y);
        }

        #endregion

        #region Battle Event Handler

        private void HandleChangeBattleStateEvent(BattleState state)
        {

        }

        public void OnReceiveMessage(MessageType type, object sender, object msg)
        {
            switch (type)
            {
                case MessageType.BEFORE_DAMAGE:
                    ActivateDefenderTrait((BattleUnit)sender, (BattleDamage.DamageMessage)msg);
                    break;
                default:
                    break;
            }
        }

        private void ActivateDefenderTrait(BattleUnit damagedUnit, BattleDamage.DamageMessage damageMsg)
        {
            // Check Condition
            if (baseData.unitClass != UnitClass.DEFENDER)
                return;

            if (damagedUnit.baseData.unitClass == UnitClass.DEFENDER)
                return;

            if (damagedUnit.team != team)
                return;

            if (Vector3.Distance(transform.position, damagedUnit.transform.position) > 4f)
                return;

            // Take Shared Damage
            BattleDamage.DamageMessage sharedDamage;
            sharedDamage.owner = damageMsg.owner;
            sharedDamage.atk = damageMsg.owner.pow.current;
            sharedDamage.levelAtk = 10; // Mock up - card.owner.lv;
            sharedDamage.skillMultiplier = damageMsg.skillMultiplier;
            sharedDamage.cri = damageMsg.owner.cri.current;
            sharedDamage.isCritical = BattleManager.main.RollCritical(damageMsg.owner.cri.current);
            sharedDamage.finalMultiplier = 0.2f;
            sharedDamage.damageType = BattleDamageType.Physical;
            sharedDamage.hitEffect = damageMsg.hitEffect;
            sharedDamage.effectTarget = damageMsg.effectTarget;
            sharedDamage.hitPosition = damageMsg.owner.transform.position;
            sharedDamage.knockbackPower = damageMsg.knockbackPower;
            TakeDamage(sharedDamage);

            // Damage Modify
            damageMsg.finalMultiplier *= 0.8f;
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
            Handles.color = Color.blue;
            Handles.DrawLine(transform.position, _targetPosition);
        }

        private void DrawRangeSphere()
        {
            Handles.color = new Color(0f, 0, 0.70f, 0.2f);
            Handles.DrawSolidDisc(transform.position, Vector3.up, neighborRadius);
        }
#endif
        #endregion
    }
}
