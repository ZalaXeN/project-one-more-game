using UnityEngine;
using Unity.Mathematics;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(fileName = "Attack", menuName = "Battle/Action/Attack", order = 1)]
    public class BA_Attack : BattleAction
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

            if(card.GetTarget())
                card.owner.UpdateFlipScale(card.GetTarget().transform.position);

            BattleDamage.DamageMessage damage;
            damage.owner = card.owner;
            damage.atk = card.owner.pow.current;
            damage.levelAtk = 10; // Mock up - card.owner.lv;
            damage.skillMultiplier = powMultiplier;
            damage.cri = card.owner.cri.current;
            damage.isCritical = BattleManager.main.RollCritical(card.owner.cri.current);
            damage.damageType = BattleDamageType.Physical;
            damage.hitEffect = hitParticleId;
            damage.effectTarget = effectTarget;
            damage.hitPosition = card.owner.transform.position;
            damage.knockbackPower = knockbackPower;

            BattleDamagable damagable = card.GetTarget().GetBattleDamagable();
            if (damagable)
                damagable.TakeDamage(damage);
        }
    }
}
