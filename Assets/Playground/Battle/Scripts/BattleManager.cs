using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class BattleManager
{
    static List<BattleUnit> battleUnits = new List<BattleUnit>();
    static BattleUnit targetUnit;
    static BattleSpawnPoint leftSpawnPoint;
    static BattleSpawnPoint rightSpawnPoint;

    public static float leftBasePosX { get { return leftSpawnPoint.transform.position.x; } set { } }
    public static float rightBasePosX { get { return rightSpawnPoint.transform.position.x; } set { } }

    public static void AssignSpawnPoint(BattleSpawnPoint spawnPoint)
    {
        if (spawnPoint.team == BattleTeam.Left)
            leftSpawnPoint = spawnPoint;
        else if (spawnPoint.team == BattleTeam.Right)
            rightSpawnPoint = spawnPoint;
    }

    public static void AssignUnit(BattleUnit unit)
    {
        battleUnits.Add(unit);
    }

    public static BattleUnit FindNearbyEnemy(BattleUnit unit)
    {
        targetUnit = null;
        foreach (BattleUnit otherUnit in battleUnits)
        {
            float distance = 99999f;
            float checkDistance;
            if (otherUnit.team == unit.team)
                continue;

            checkDistance = Vector3.Distance(unit.transform.position, otherUnit.transform.position);
            if (checkDistance < distance)
            {
                distance = Vector3.Distance(unit.transform.position, otherUnit.transform.position);
                targetUnit = otherUnit;
            }
        }
        return targetUnit;
    }
}
