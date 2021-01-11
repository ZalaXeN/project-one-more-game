using UnityEngine;
using System.Collections;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(fileName = "SpawnMinion", menuName = "Battle/Action/SpawnMinion", order = 3)]
    public class BA_SpawnMinion : BattleAction
    {
        public string minionPrefabId;
        public BattleTeam battleTeam;

        public override void Execute(BattleActionCard card)
        {
            BattleManager.main.SpawnMinion(minionPrefabId, battleTeam);
        }
    }
}
