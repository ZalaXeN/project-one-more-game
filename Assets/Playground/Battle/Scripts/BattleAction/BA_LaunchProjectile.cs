using UnityEngine;
using Unity.Mathematics;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(fileName = "LaunchProjectile", menuName = "Battle/Action/LaunchProjectile", order = 2)]
    public class BA_LaunchProjectile : BattleAction
    {
        public override void Execute(BattleActionCard card)
        {
            if (card.owner == null || card.GetTarget() == null)
                return;          
        }
    }
}
