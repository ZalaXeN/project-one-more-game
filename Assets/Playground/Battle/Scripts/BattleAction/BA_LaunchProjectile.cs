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

            BattleDamage.DamageMessage damage = new BattleDamage.DamageMessage();
            damage.owner = card.owner;
            damage.atk = card.owner.pow.current;
            damage.levelAtk = 10; // Mock up - card.owner.lv;
            damage.skillMultiplier = powMultiplier;
            damage.cri = card.owner.cri.current;
            damage.isCritical = BattleManager.main.RollCritical(card.owner.cri.current);
            damage.finalMultiplier = 1f;
            damage.damageType = damageType;
            damage.hitEffect = hitParticleId;
            damage.effectTarget = affectTarget;
            damage.knockbackPower = knockbackPower;

            AbilityData skillData = card.baseData;

            Vector3 launceOffset = skillData.launchPositionOffset;
            launceOffset.x *= card.owner.IsFliped() ? -1f : 1f;

            Vector3 launchPos = card.owner.transform.position + launceOffset;

            //BattleManager.main.battleProjectileManager.Launch(
            //    projectilePrefabId,
            //    launchPos,
            //    card.targetPosition,
            //    skillData.MaxTravelTime,
            //    damageMsg);

            BattleManager.main.battleProjectileManager.Launch(
                projectilePrefabId,
                launchPos,
                card.targetPosition,
                skillData.MaxRange,
                skillData.MinTravelTime,
                skillData.MaxTravelTime,
                damage);
        }
    }
}
