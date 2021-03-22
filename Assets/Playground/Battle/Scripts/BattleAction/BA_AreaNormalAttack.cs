using UnityEngine;
using Unity.Mathematics;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(fileName = "AreaAttack", menuName = "Battle/Action/AreaAttack", order = 4)]
    public class BA_AreaNormalAttack : BattleAction
    {
        [Range(0.1f, 10f)]
        public float powMultiplier = 1f;

        public string hitParticleId = "slash_hit";

        public override void Execute(BattleActionCard card)
        {
            if (card.owner == null || !card.HasTarget())
                return;

            card.owner.UpdateFlipScale(card.GetTarget().transform.position);

            foreach (BattleUnit target in card.GetTargets())
            {
                BattleDamage.DamageMessage damage;
                damage.owner = card.owner;
                damage.damage = (int)math.round(card.owner.pow.current * powMultiplier);
                damage.damageType = BattleDamageType.Physical;
                damage.hitEffect = hitParticleId;

                target.TakeDamage(damage);
            }
        }
    }
}
