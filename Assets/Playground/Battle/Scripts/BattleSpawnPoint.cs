using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BattleSpawnPoint : MonoBehaviour
{
    // TEST
    [SerializeField] bool canDie;

    [SerializeField] BattleTeam battleTeam;
    [SerializeField] BoxCollider2D spawnArea;
    [SerializeField] BattleLane[] spawnLanes;

    Vector3 spawnPos = new Vector3();

    public BattleTeam team
    {
        get { return battleTeam; }
        set { battleTeam = value; }
    }

    private void Start()
    {
        BattleManager.AssignSpawnPoint(this);
    }

    public void SpawnUnit(BattleUnit unit)
    {
        spawnPos.x = Random.Range(spawnArea.bounds.min.x, spawnArea.bounds.max.x);
        spawnPos.y = spawnLanes[Random.Range(0, spawnLanes.Length)].transform.position.y;

        GameObject spawnedUnit = Instantiate(unit.gameObject, spawnPos, Quaternion.identity);
        BattleUnit spawnedBattleUnit = spawnedUnit.GetComponent<BattleUnit>();
        spawnedBattleUnit.team = battleTeam;
        spawnedBattleUnit.canDie = canDie;
        spawnedBattleUnit.InitBattleUnit();
    }
}
