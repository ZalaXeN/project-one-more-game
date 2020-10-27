using UnityEngine;
using Unity.Mathematics;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(fileName = "Attack", menuName = "Battle/Action/Attack", order = 1)]
    public class BA_Attack : BattleAction
    {
        [Range(0.1f, 10f)]
        public float powMultiplier = 1f;

        public override void Execute(BattleActionCard card)
        {
            if (card.owner == null || card.GetTarget() == null)
                return;

            BattleDamage damage = new BattleDamage(
                card.owner,
                (int)math.round(card.owner.pow.current * powMultiplier),
                BattleDamageType.Physical,
                "slash_hit");

            card.GetTarget().TakeDamage(damage);
        }
    }
}
