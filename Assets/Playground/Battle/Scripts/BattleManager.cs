using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class BattleManager
{
    static List<BattleUnit> battleUnits = new List<BattleUnit>();
    static BattleUnit targetUnit;
    static BattleSpawnPoint leftSpawnPoint;
    static BattleSpawnPoint rightSpawnPoint;
    static BattleBaseFlag leftBaseFlag;
    static BattleBaseFlag rightBaseFlag;

    public static float leftBasePosX { get { return leftBaseFlag.transform.position.x; } set { } }
    public static float rightBasePosX { get { return rightBaseFlag.transform.position.x; } set { } }

    public static void AssignSpawnPoint(BattleSpawnPoint spawnPoint)
    {
        if (spawnPoint.team == BattleTeam.Left)
            leftSpawnPoint = spawnPoint;
        else if (spawnPoint.team == BattleTeam.Right)
            rightSpawnPoint = spawnPoint;
    }

    public static void AssignBaseFlag(BattleBaseFlag baseFlag)
    {
        if (baseFlag.team == BattleTeam.Left)
            leftBaseFlag = baseFlag;
        else if (baseFlag.team == BattleTeam.Right)
            rightBaseFlag = baseFlag;
    }

    public static void AssignUnit(BattleUnit unit)
    {
        if (battleUnits.Contains(unit))
            return;

        battleUnits.Add(unit);
    }

    public static void SpawnUnit(BattleUnit unit, BattleTeam team)
    {
        if (team == BattleTeam.Left)
            leftSpawnPoint.SpawnUnit(unit);
        else
            rightSpawnPoint.SpawnUnit(unit);
    }

    public static BattleUnit FindNearbyEnemy(BattleUnit unit)
    {
        targetUnit = null;
        float distance = Mathf.Infinity;

        foreach (BattleUnit otherUnit in battleUnits)
        {
            float checkDistance;
            if (otherUnit.team == unit.team)
                continue;

            checkDistance = Vector3.Distance(unit.transform.position, otherUnit.transform.position);

            if (checkDistance < distance)
            {
                distance = checkDistance;
                targetUnit = otherUnit;
            }
        }

        return targetUnit;
    }
}
