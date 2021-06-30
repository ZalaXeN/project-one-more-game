using UnityEngine;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(fileName = "SpawnMinionToTarget", menuName = "Battle/Action/SpawnMinionToTarget", order = 4)]
    public class BA_SpawnMinionToTarget : BattleAction
    {
        public string minionPrefabId;
        public BattleTeam battleTeam;

        public override void Execute(BattleActionCard card)
        {
            BattleUnit unit;
            bool spawnSuccess = BattleManager.main.SpawnMinion(minionPrefabId, battleTeam, out unit);
            if (spawnSuccess)
            {
                unit.SetTargetPosition(card.targetPosition);
            }
        }
    }
}
