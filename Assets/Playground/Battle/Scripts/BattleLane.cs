using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BattleLane : MonoBehaviour
{
    [SerializeField] Color drawLaneColor = new Color(0f, 1f, 0f);

    Vector3 startDrawLane = new Vector3();
    Vector3 endDrawLane = new Vector3();

    private void OnDrawGizmosSelected()
    {
        startDrawLane.x = BattleGlobalParam.BATTLE_LANE_START_X;
        startDrawLane.y = transform.position.y;

        endDrawLane.x = BattleGlobalParam.BATTLE_LANE_END_X;
        endDrawLane.y = transform.position.y;

        Gizmos.color = drawLaneColor;
        Gizmos.DrawLine(startDrawLane, endDrawLane);
    }
}
