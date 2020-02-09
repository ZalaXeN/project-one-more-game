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
    public float battleTime;

    private void Start()
    {
        currentExecuteState = BattleExecuteState.Normal;
        BattleManager.AssignBattleSystem(this);
        BattleManager.battleCommandTime = 0f;
    }

    private void Update()
    {
        UpdateBattleCommand();
        battleTime = BattleManager.battleCommandTime;
    }

    void UpdateBattleCommand()
    {
        if (currentExecuteState == BattleExecuteState.Normal)
        {
            BattleManager.battleCommandTime += Time.deltaTime;
            Next();
        }
        else if (currentExecuteState == BattleExecuteState.Reverse)
        {
            BattleManager.battleCommandTime -= Time.deltaTime;
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
