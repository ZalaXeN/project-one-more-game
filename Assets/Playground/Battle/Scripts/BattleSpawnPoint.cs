using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BattleSpawnPoint : MonoBehaviour
{
    [SerializeField] BattleTeam battleTeam = BattleTeam.None;
    [SerializeField] BoxCollider2D spawnArea = null;
    [SerializeField] BattleLane[] spawnLanes = null;

    public BattleTeam team
    {
        get { return battleTeam; }
        set { battleTeam = value; }
    }

    private void Start()
    {
        BattleManager.AssignSpawnPoint(this);
    }

    public Vector3 GetRandomSpawnPoint()
    {
        Vector3 spawnPos = new Vector3();
        spawnPos.x = Random.Range(spawnArea.bounds.min.x, spawnArea.bounds.max.x);
        spawnPos.y = spawnLanes[Random.Range(0, spawnLanes.Length)].transform.position.y;
        return spawnPos;
    }

    public GameObject SpawnBattleUnit(BattleUnit unit, Vector3 position)
    {
        return Instantiate(unit.gameObject, position, Quaternion.identity);
    }

    public void DestroyBattleUnit(GameObject go)
    {
        Destroy(go);
    }
}
