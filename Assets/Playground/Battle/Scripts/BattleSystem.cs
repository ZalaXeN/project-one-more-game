using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BattleSystem : MonoBehaviour
{
    public enum BattleExecuteState
    {
        Normal,
        Reverse,
        Pause
    }

    public BattleExecuteState currentExecuteState;

    private void Start()
    {
        currentExecuteState = BattleExecuteState.Normal;

        //UnitMoveBC unitMoveBC = new UnitMoveBC(Vector3.zero, Vector3.one);
        //UnitMoveBC unitMoveBC2 = new UnitMoveBC(Vector3.up, Vector3.down);
        //UnitMoveBC unitMoveBC3 = new UnitMoveBC(Vector3.left, Vector3.right);

        //BattleManager._battleCommandManager.AddCommand(unitMoveBC);
        //BattleManager._battleCommandManager.AddCommand(unitMoveBC2);
        //BattleManager._battleCommandManager.AddCommand(unitMoveBC3);
    }

    private void Update()
    {
        if (currentExecuteState == BattleExecuteState.Normal)
        {
            Next();
        }
        else if (currentExecuteState == BattleExecuteState.Reverse)
        {
            Back();
        }
        else if (currentExecuteState == BattleExecuteState.Pause)
        {

        }
    }

    public void ResetBattle()
    {
        
    }

    public void Play()
    {
        Debug.Log("<color=green> Play </color>");
        currentExecuteState = BattleExecuteState.Normal;
    }

    public void Replay()
    {
        Debug.Log("<color=green> Replay </color>");
        currentExecuteState = BattleExecuteState.Pause;
        // Replay Function
        currentExecuteState = BattleExecuteState.Normal;
    }

    public void Reverse()
    {
        Debug.Log("<color=red> Reverse </color>");
        currentExecuteState = BattleExecuteState.Reverse;
    }

    public void Pause()
    {
        Debug.Log("<color=yellow> Pause </color>");
        currentExecuteState = BattleExecuteState.Pause;
    }

    void Next()
    {
        BattleManager._battleCommandManager.Next();
    }

    void Back()
    {
        BattleManager._battleCommandManager.Back();
    }
}
