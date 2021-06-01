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
            damageMsg.atk = card.owner.pow.current;
            damageMsg.levelAtk = 10; // Mock up - card.owner.lv;
            damageMsg.skillMultiplier = powMultiplier;
            damageMsg.cri = card.owner.cri.current;
            damageMsg.isCritical = BattleManager.main.RollCritical(card.owner.cri.current);
            damageMsg.damageType = damageType;
            damageMsg.hitEffect = hitParticleId;
            damageMsg.effectTarget = affectTarget;
            damageMsg.knockbackPower = knockbackPower;

            SkillData skillData = card.baseData;

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
                damageMsg);
        }
    }
}
