using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpawnUnitBC : IBattleCommand
{
    BattleUnit _unitPrefab;
    BattleTeam _unitTeam;
    BattleSpawnPoint _spawnPoint;
    Vector3 _spawnPosition;

    GameObject spawnedUnitGO;
    BattleUnit spawnedUnit;

    float executeTime;

    public SpawnUnitBC(BattleUnit unitPrefab, BattleTeam team, BattleSpawnPoint spawnPoint, Vector3 spawnPosition)
    {
        _unitPrefab = unitPrefab;
        _unitTeam = team;
        _spawnPoint = spawnPoint;
        _spawnPosition = spawnPosition;
        executeTime = -1f;
    }
    
    public void Execute()
    {
        if (executeTime == -1f)
            executeTime = BattleManager.battleCommandTime;

        spawnedUnitGO = _spawnPoint.SpawnBattleUnit(_unitPrefab, _spawnPosition);
        spawnedUnit = spawnedUnitGO.GetComponent<BattleUnit>();
        spawnedUnit.team = _unitTeam;
        spawnedUnit.InitBattleUnit();
    }

    public void Undo()
    {
        _spawnPoint.DestroyBattleUnit(spawnedUnitGO);
    }

    public float GetExecuteTime()
    {
        return executeTime;
    }
}
