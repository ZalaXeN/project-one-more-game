using UnityEngine;
using System.Collections;
using ProjectOneMore.Battle;

public class PlaygroundMessager : MonoBehaviour
{
    #region Test Animation

    private BattleUnit[] _battleUnitList;

    private void LoadAllBattleUnit()
    {
        if(_battleUnitList == null)
        {
            _battleUnitList = GameObject.FindObjectsOfType<BattleUnit>();
        }
    }

    public void BoardcastTriggerTestAnimation(string name)
    {
        LoadAllBattleUnit();

        foreach (BattleUnit unit in _battleUnitList)
        {
            unit.gameObject.SendMessage("TriggerTestAnimation", name);
        }
    }

    public void BoardcastToggleAnimatorBool(string name)
    {
        LoadAllBattleUnit();

        foreach (BattleUnit unit in _battleUnitList)
        {
            unit.gameObject.SendMessage("ToggleAnimatorBool", name);
        }
    }

    public void BoardcastToggleTestMoving()
    {
        LoadAllBattleUnit();

        foreach (BattleUnit unit in _battleUnitList)
        {
            unit.gameObject.SendMessage("ToggleTestMoving");
        }
    }

    public void BoardcastToggleIdle()
    {
        LoadAllBattleUnit();

        foreach (BattleUnit unit in _battleUnitList)
        {
            unit.gameObject.SendMessage("ToggleIdle");
        }
    }

    #endregion
}
