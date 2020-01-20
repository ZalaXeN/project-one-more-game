using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class BattleGlobalParam
{
    public static readonly float BATTLE_LANE_START_X = -20f;
    public static readonly float BATTLE_LANE_END_X = 20f;

    public static readonly float BOUNCE_FORCE_MULTIPLIER = 5f;
    public static readonly float BOUNCE_TIME = 0.5f;

    public static readonly Vector3 LEFT_TEAM_UNIT_TRANSFORM_SCALE = new Vector3(-1f, 1f, 1f);
    public static readonly Vector3 RIGHT_TEAM_UNIT_TRANSFORM_SCALE = Vector3.one;
}