using UnityEngine;
using Unity.Mathematics;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(fileName = "AreaAttack", menuName = "Battle/Action/AreaAttack", order = 4)]
    public class BA_AreaNormalAttack : BattleAction
    {
        public SkillEffectTarget effectTarget;

        [Range(0.1f, 10f)]
        public float powMultiplier = 1f;

        public string hitParticleId = "slash_hit";

        [Range(0f, 10f)]
        public float knockbackPower = 1f;

        public override void Execute(BattleActionCard card)
        {
            if (card.owner == null || !card.HasTarget())
                return;

            card.owner.UpdateFlipScale(card.targetPosition);

            foreach (BattleActionTargetable target in card.GetTargets())
            {
                BattleDamage.DamageMessage damage;
                damage.owner = card.owner;
                damage.damage = (int)math.round(card.owner.pow.current * powMultiplier);
                damage.damageType = BattleDamageType.Physical;
                damage.hitEffect = hitParticleId;
                damage.effectTarget = effectTarget;
                damage.hitPosition = card.owner.transform.position;
                damage.knockbackPower = knockbackPower;

                BattleDamagable damagable = target.GetBattleDamagable();
                if (damagable)
                    damagable.TakeDamage(damage);
            }
        }
    }
}
