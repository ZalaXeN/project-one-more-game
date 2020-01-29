using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BattleUnit : MonoBehaviour
{
    // TEST
    [SerializeField] string testStatus = string.Empty;
    public bool canDie = false;
    public bool isBouncing = false;
    public BattleUnit killerUnit = null;

    [SerializeField] BattleTeam battleTeam = BattleTeam.None;
    [SerializeField] float moveSpeed = 3f;
    [SerializeField] float bounce = 1f;
    [SerializeField] Transform characterTransform = null;
    [SerializeField] Collider2D selfCollider = null;
    [SerializeField] ContactFilter2D enemyContactFilter = new ContactFilter2D();
    [SerializeField] SpriteRenderer characterSprite = null;

    public Transform cameraPivot;

    BattleUnit _targetEnemy;
    Collider2D[] _enemyColliders = new Collider2D[1];
    float _bounceTimer = 0f;
    float _animateTimer = 0f;

    public BattleTeam team
    {
        get { return battleTeam; }
        set { battleTeam = value; }
    }

    public Collider2D battleCollider
    {
        get { return selfCollider; }
        set {  }
    }

    public void InitBattleUnit()
    {
        BattleManager.AssignUnit(this);
        AdjustCharacterTransform();

        BattleManager.OnFocusFight += AdjustSpriteOnFocusFight;
        BattleManager.OnResetFocusFight += ResetSpriteOnFocusFight;
    }

    private void AdjustCharacterTransform()
    {
        characterTransform.localScale = team == BattleTeam.Left ?
            BattleGlobalParam.LEFT_TEAM_UNIT_TRANSFORM_SCALE
            : BattleGlobalParam.RIGHT_TEAM_UNIT_TRANSFORM_SCALE;
    }

    void AdjustSpriteOnFocusFight(Transform cameraPivotUnit1, Transform cameraPivotUnit2, Color nonFocusColor)
    {
        if (cameraPivot == cameraPivotUnit1 || cameraPivot == cameraPivotUnit2)
            characterSprite.color = Color.white;
        else
            characterSprite.color = nonFocusColor;
    }

    void ResetSpriteOnFocusFight()
    {
        characterSprite.color = Color.white;
    }

    private void OnEnable()
    {
        BattleManager.OnFocusFight += AdjustSpriteOnFocusFight;
        BattleManager.OnResetFocusFight += ResetSpriteOnFocusFight;
    }

    private void OnDisable()
    {
        BattleManager.OnFocusFight -= AdjustSpriteOnFocusFight;
        BattleManager.OnResetFocusFight -= ResetSpriteOnFocusFight;
    }

    private void Update()
    {
        if(_animateTimer > 0f)
        {
            _animateTimer -= Time.deltaTime;
            return;
        }

        if (_bounceTimer > 0f)
        {
            Bounce();
            return;
        }

        isBouncing = false;
        if (CheckOverlapTarget())
        {
            StartFight();
            return;
        }

        if (IsReachEnemyBase())
            return;

        FindTargetEnemy();

        if(_targetEnemy == null)
            MoveToEnemyBase();
        else
        {
            MoveToEnemy();
        }
    }

    void AnimateAttack()
    {
        _animateTimer = BattleGlobalParam.TEST_ANIMATE_ATTACK_TIME;
    }

    void FindTargetEnemy()
    {
        _targetEnemy = BattleManager.FindNearbyEnemy(this);
    }

    void MoveToEnemy()
    {
        testStatus = "Move to enemy";

        if (battleTeam == BattleTeam.Left)
        {
            if (transform.position.x >= _targetEnemy.transform.position.x)
                return;

            transform.Translate(Vector3.right * moveSpeed * Time.deltaTime);
        }
        else
        {
            if (transform.position.x < _targetEnemy.transform.position.x)
                return;

            transform.Translate(Vector3.left * moveSpeed * Time.deltaTime);
        }
    }

    bool CheckOverlapTarget()
    {
        if (selfCollider.OverlapCollider(enemyContactFilter, _enemyColliders) > 0)
        {
            _targetEnemy = _enemyColliders[0].GetComponent<BattleUnit>();

            if (_targetEnemy.canDie && _targetEnemy.killerUnit != null && _targetEnemy.killerUnit != this)
                return false;

            //if(_enemyColliders[0] == _targetEnemy.battleCollider)
                return true;
        }
        return false;
    }

    void StartFight()
    {
        _bounceTimer = BattleGlobalParam.BOUNCE_TIME;
        AnimateAttack();
        Bounce();
        BattleManager.FocusFight(this, _targetEnemy);
        isBouncing = true;

        if (canDie)
            killerUnit = _targetEnemy;
    }

    void Bounce()
    {
        testStatus = "Bounce";

        _bounceTimer -= Time.deltaTime;
        float bounceForce = bounce * _bounceTimer * BattleGlobalParam.BOUNCE_FORCE_MULTIPLIER * Time.deltaTime;

        if (battleTeam == BattleTeam.Left)
        {
            transform.Translate(Vector3.left * bounceForce);
        }
        else
        {
            transform.Translate(Vector3.right * bounceForce);
        }

        if (_bounceTimer < 0f)
            Dead();
    }

    void MoveToEnemyBase()
    {
        testStatus = "Move to enemy base";

        if (battleTeam == BattleTeam.Left)
        {
            transform.Translate(Vector3.right * moveSpeed * Time.deltaTime);
        }
        else
        {
            transform.Translate(Vector3.left * moveSpeed * Time.deltaTime);
        }
    }

    bool IsReachEnemyBase()
    {
        if (battleTeam == BattleTeam.Left)
        {
            if (transform.position.x >= BattleManager.rightBasePosX)
                return true;
        }
        else
        {
            if (transform.position.x < BattleManager.leftBasePosX)
                return true;
        }
        return false;
    }

    void ResetParam()
    {
        _animateTimer = 0f;
        _bounceTimer = 0f;
        _targetEnemy = null;
    }

    void Dead()
    {
        if (!canDie)
            return;

        ResetParam();
        gameObject.SetActive(false);
    }
}