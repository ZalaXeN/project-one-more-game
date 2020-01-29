using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;


public enum BattleTeam
{
    Left,
    Right,
    None
}

public static class BattleManager
{
    public delegate void PerformFocusFight(Transform unit1, Transform unit2, Color nonFocusColor);
    public static event PerformFocusFight OnFocusFight;
    public delegate void PerformResetFocusFight();
    public static event PerformResetFocusFight OnResetFocusFight;

    //public delegate void BattleUnitDead(BattleUnit unit);
    //public static event BattleUnitDead BattleUnitDeadEvent;

    static List<BattleUnit> _battleUnits = new List<BattleUnit>();
    static BattleUnit _targetUnit;
    static BattleSpawnPoint _leftSpawnPoint;
    static BattleSpawnPoint _rightSpawnPoint;
    static BattleBaseFlag _leftBaseFlag;
    static BattleBaseFlag _rightBaseFlag;
    static BattleCameraManager _battleCameraManager;

    public static float leftBasePosX { get { return _leftBaseFlag.transform.position.x; } set { } }
    public static float rightBasePosX { get { return _rightBaseFlag.transform.position.x; } set { } }

    public static void AssignBattleCameraManager(BattleCameraManager battleCameraManager)
    {
        _battleCameraManager = battleCameraManager;
    }

    public static void FocusFight(BattleUnit unit1, BattleUnit unit2)
    {
        _battleCameraManager.ShowBattleFocus(BattleGlobalParam.CAMERA_PRIORITY_MINION_FIGHT, 
            unit1.cameraPivot, unit2.cameraPivot, BattleGlobalParam.CAMERA_BOUNCE_TIME);
    }

    public static void ShowFocusFightEffect(Transform unit1, Transform unit2, Color nonFocusColor)
    {
        OnFocusFight(unit1, unit2, nonFocusColor);
    }

    public static void ResetFocusSprite()
    {
        OnResetFocusFight();
    }

    public static void AssignSpawnPoint(BattleSpawnPoint spawnPoint)
    {
        if (spawnPoint.team == BattleTeam.Left)
            _leftSpawnPoint = spawnPoint;
        else if (spawnPoint.team == BattleTeam.Right)
            _rightSpawnPoint = spawnPoint;
    }

    public static void AssignBaseFlag(BattleBaseFlag baseFlag)
    {
        if (baseFlag.team == BattleTeam.Left)
            _leftBaseFlag = baseFlag;
        else if (baseFlag.team == BattleTeam.Right)
            _rightBaseFlag = baseFlag;
    }

    public static void AssignUnit(BattleUnit unit)
    {
        if (_battleUnits.Contains(unit))
            return;

        _battleUnits.Add(unit);
    }

    public static void SpawnUnit(BattleUnit unit, BattleTeam team)
    {
        if (team == BattleTeam.Left)
            _leftSpawnPoint.SpawnUnit(unit);
        else
            _rightSpawnPoint.SpawnUnit(unit);
    }

    public static BattleUnit FindNearbyEnemy(BattleUnit unit)
    {
        _targetUnit = null;
        float distance = Mathf.Infinity;

        foreach (BattleUnit otherUnit in _battleUnits)
        {
            float checkDistance;
            if (otherUnit.team == unit.team || !otherUnit.isActiveAndEnabled)
                continue;

            checkDistance = Vector3.Distance(unit.transform.position, otherUnit.transform.position);

            if (checkDistance < distance)
            {
                distance = checkDistance;
                _targetUnit = otherUnit;
            }
        }

        return _targetUnit;
    }
}
