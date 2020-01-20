using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BattleUnit : MonoBehaviour
{
    [SerializeField] string testStatus;
    [SerializeField] BattleTeam battleTeam;
    [SerializeField] float moveSpeed = 3f;
    [SerializeField] float bounce = 1f;
    [SerializeField] Transform characterTransform;
    [SerializeField] Collider2D selfCollider;
    [SerializeField] ContactFilter2D enemyContactFilter;

    BattleUnit _targetEnemy;
    Collider2D[] _enemyColliders = new Collider2D[1];
    float _bounceTimer = 0f;

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
    }

    private void AdjustCharacterTransform()
    {
        characterTransform.localScale = team == BattleTeam.Left ?
            BattleGlobalParam.LEFT_TEAM_UNIT_TRANSFORM_SCALE
            : BattleGlobalParam.RIGHT_TEAM_UNIT_TRANSFORM_SCALE;
    }

    private void Update()
    {
        if (_bounceTimer > 0f)
        {
            Bounce();
            return;
        }

        if (CheckOverlapTarget())
        {
            StartBounce();
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
            //if(_enemyColliders[0] == _targetEnemy.battleCollider)
                return true;
        }
        return false;
    }

    void StartBounce()
    {
        _bounceTimer = BattleGlobalParam.BOUNCE_TIME;
        Bounce();
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
}

public enum BattleTeam
{
    Left,
    Right
}
