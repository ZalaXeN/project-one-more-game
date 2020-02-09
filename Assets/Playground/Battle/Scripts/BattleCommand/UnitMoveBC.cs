using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UnitMoveBC : IBattleCommand
{
    Transform unitTransform;
    Vector3 startPosition;
    Vector3 endPosition;
    Transform targetTransform;

    public UnitMoveBC(Vector3 startPos, Vector3 endPos)
    {
        startPosition = startPos;
        endPosition = endPos;
    }

    public void Execute()
    {
        Debug.Log("Move from " + startPosition + " to " + endPosition);
    }

    public void Undo()
    {
        Debug.Log("Move from " + endPosition + " to " + startPosition);
    }

    public float GetExecuteTime()
    {
        return -1f;
    }
}
