using UnityEngine;

public class BattleSpawnUnitButton : MonoBehaviour
{
    [SerializeField] BattleTeam battleTeam = BattleTeam.None;
    [SerializeField] BattleUnit unitPrefab = null;

    public void Spawn()
    {
        BattleManager.CommandSpawnUnit(unitPrefab, battleTeam);
    }
}
