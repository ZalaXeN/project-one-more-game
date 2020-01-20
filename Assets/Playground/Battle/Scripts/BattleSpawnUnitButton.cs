using UnityEngine;

public class BattleSpawnUnitButton : MonoBehaviour
{
    [SerializeField] BattleTeam battleTeam;
    [SerializeField] BattleUnit unitPrefab;

    public void Spawn()
    {
        BattleManager.SpawnUnit(unitPrefab, battleTeam);
    }
}
