using UnityEngine;
using System.Collections;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(fileName = "SpawnMinion", menuName = "Battle/Action/SpawnMinion", order = 2)]
    public class BA_SpawnMinion : BattleAction
    {
        public GameObject minionPrefab;
        public BattleUnitAttackType attackType;
        public BattleTeam battleTeam;

        public override void Execute(BattlePlayerActionCard card)
        {
            BattleManager.main.SpawnMinion(minionPrefab, attackType, battleTeam);
        }
    }
}
