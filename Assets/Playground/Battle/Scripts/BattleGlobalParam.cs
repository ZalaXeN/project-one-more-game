using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class BattleGlobalParam
{
    public static readonly float BATTLE_LANE_START_X = -20f;
    public static readonly float BATTLE_LANE_END_X = 20f;

    public static readonly float BOUNCE_FORCE_MULTIPLIER = 10f;
    public static readonly float BOUNCE_TIME = 0.5f;

    public static readonly float TEST_ANIMATE_ATTACK_TIME = 0.5f;

    public static readonly Vector3 LEFT_TEAM_UNIT_TRANSFORM_SCALE = new Vector3(-1f, 1f, 1f);
    public static readonly Vector3 RIGHT_TEAM_UNIT_TRANSFORM_SCALE = Vector3.one;

    public static readonly int CAMERA_PRIORITY_NORMAL = 5;
    public static readonly int CAMERA_PRIORITY_INACTIVE = 1;

    public static readonly int CAMERA_PRIORITY_MINION_FIGHT = 11;
    public static readonly int CAMERA_PRIORITY_MINION_DEAD = 12;

    public static readonly int CAMERA_PRIORITY_KEEPER_FIGHT = 15;
    public static readonly int CAMERA_PRIORITY_KEEPER_SKILL = 16;
    public static readonly int CAMERA_PRIORITY_KEEPER_DEAD = 17;

    public static readonly int CAMERA_PRIORITY_STORY_FOCUS = 21;

    public static readonly float CAMERA_BOUNCE_FOCUS_TIME = 0.4f;
    public static readonly float CAMERA_BOUNCE_TIME = 2f;
}