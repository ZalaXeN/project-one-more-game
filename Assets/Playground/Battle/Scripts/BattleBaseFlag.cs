using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BattleBaseFlag : MonoBehaviour
{
    [SerializeField] BattleTeam battleTeam;
    [SerializeField] float startY = 1f;
    [SerializeField] float endY = 1f;
    [SerializeField] Color drawLaneColor = new Color(1f, 0f, 0f);

    Vector3 startDrawLine = new Vector3();
    Vector3 endDrawLine = new Vector3();

    public BattleTeam team
    {
        get { return battleTeam; }
        set { battleTeam = value; }
    }

    private void Start()
    {
        BattleManager.AssignBaseFlag(this);
    }

    private void OnDrawGizmosSelected()
    {
        startDrawLine.x = transform.position.x;
        startDrawLine.y = transform.position.y + startY;

        endDrawLine.x = transform.position.x;
        endDrawLine.y = transform.position.y - endY;

        Gizmos.color = drawLaneColor;
        Gizmos.DrawLine(startDrawLine, endDrawLine);
    }
}
