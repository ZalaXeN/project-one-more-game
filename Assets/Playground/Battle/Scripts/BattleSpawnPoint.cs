using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BattleSpawnPoint : MonoBehaviour
{
    [SerializeField] BattleTeam battleTeam;
    [SerializeField] BoxCollider2D spawnArea;
    [SerializeField] BattleLane[] spawnLanes;

    public BattleTeam team
    {
        get { return battleTeam; }
        set { battleTeam = value; }
    }

    private void Start()
    {
        BattleManager.AssignSpawnPoint(this);
    }
}
