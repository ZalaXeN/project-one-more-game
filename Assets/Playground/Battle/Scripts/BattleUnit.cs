using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BattleUnit : MonoBehaviour
{
    [SerializeField] BattleTeam battleTeam;
    [SerializeField] float moveSpeed = 3f;
    [SerializeField] PolygonCollider2D selfCollider;
    [SerializeField] ContactFilter2D enemyContactFilter;

    BattleUnit targetEnemy;
    Collider2D[] enemyColliders = new Collider2D[1];

    public BattleTeam team
    {
        get { return battleTeam; }
        set { battleTeam = value; }
    }

    private void Start()
    {
        BattleManager.AssignUnit(this);
    }

    private void Update()
    {
        FindTargetEnemy();

        if(targetEnemy == null)
            MoveToEnemyBase();
        else
        {
            MoveToEnemy();
        }
    }

    void FindTargetEnemy()
    {
        targetEnemy = BattleManager.FindNearbyEnemy(this);
    }

    void MoveToEnemy()
    {
        if (CheckOverlapTarget())
            return;

        if (battleTeam == BattleTeam.Left)
        {
            if (transform.position.x >= targetEnemy.transform.position.x)
                return;

            transform.Translate(Vector3.right * moveSpeed * Time.deltaTime);
        }
        else
        {
            if (transform.position.x < targetEnemy.transform.position.x)
                return;

            transform.Translate(Vector3.left * moveSpeed * Time.deltaTime);
        }
    }

    bool CheckOverlapTarget()
    {
        if (selfCollider.OverlapCollider(enemyContactFilter, enemyColliders) > 0)
        {
            return true;
        }
        return false;
    }

    void MoveToEnemyBase()
    {
        if(battleTeam == BattleTeam.Left)
        {
            if (transform.position.x >= BattleManager.rightBasePosX)
                return;

            transform.Translate(Vector3.right * moveSpeed * Time.deltaTime);
        }
        else
        {
            if (transform.position.x < BattleManager.leftBasePosX)
                return;

            transform.Translate(Vector3.left * moveSpeed * Time.deltaTime);
        }
    }
}

public enum BattleTeam
{
    Left,
    Right
}
