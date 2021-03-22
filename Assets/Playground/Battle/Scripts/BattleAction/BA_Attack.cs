using UnityEngine;
using Unity.Mathematics;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(fileName = "Attack", menuName = "Battle/Action/Attack", order = 1)]
    public class BA_Attack : BattleAction
    {
        [Range(0.1f, 10f)]
        public float powMultiplier = 1f;

        public string hitParticleId = "slash_hit";

        public override void Execute(BattleActionCard card)
        {
            if (card.owner == null || !card.HasTarget())
                return;

            if(card.GetTarget())
                card.owner.UpdateFlipScale(card.GetTarget().transform.position);

            BattleDamage.DamageMessage damage;
            damage.owner = card.owner;
            damage.damage = (int)math.round(card.owner.pow.current * powMultiplier);
            damage.damageType = BattleDamageType.Physical;
            damage.hitEffect = hitParticleId;

            card.GetTarget()?.TakeDamage(damage);
        }
    }
}
