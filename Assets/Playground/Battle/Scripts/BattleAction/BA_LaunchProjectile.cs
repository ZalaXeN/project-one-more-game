using UnityEngine;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(fileName = "LaunchProjectile", menuName = "Battle/Action/LaunchProjectile", order = 2)]
    public class BA_LaunchProjectile : BattleAction
    {
        // Real Projectile
        public BattleProjectile projectilePrefabId;

        [Range(0.1f, 10f)] public float powMultiplier = 1f;
        [Range(0f, 10f)] public float knockbackPower = 0f;
        public BattleDamageType damageType = BattleDamageType.Physical;
        public SkillEffectTarget affectTarget = SkillEffectTarget.Enemy;
        public string hitParticleId = "slash_hit";

        public override void Execute(BattleActionCard card)
        {
            if (card.owner == null)
                return;

            card.owner.UpdateFlipScale(card.targetPosition);

            BattleDamage.DamageMessage damageMsg = new BattleDamage.DamageMessage();
            damageMsg.owner = card.owner;
            damageMsg.damage = (int)(card.owner.pow.current * powMultiplier);
            damageMsg.damageType = damageType;
            damageMsg.hitEffect = hitParticleId;
            damageMsg.effectTarget = affectTarget;
            damageMsg.knockbackPower = knockbackPower;

            SkillData skillData = card.baseData;

            Vector3 launchPos = card.owner.transform.position + skillData.launchPositionOffset;

            BattleManager.main.battleProjectileManager.Launch(
                projectilePrefabId,
                launchPos,
                card.targetPosition,
                skillData.travelTime,
                damageMsg);
        }
    }
}
