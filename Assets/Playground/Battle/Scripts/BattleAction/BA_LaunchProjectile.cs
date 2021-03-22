using UnityEngine;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(fileName = "LaunchProjectile", menuName = "Battle/Action/LaunchProjectile", order = 2)]
    public class BA_LaunchProjectile : BattleAction
    {
        // Real Projectile
        public BattleProjectile projectilePrefabId;

        public override void Execute(BattleActionCard card)
        {
            if (card.owner == null)
                return;

            card.owner.UpdateFlipScale(card.targetPosition);

            SkillData skillData = card.baseData;

            BattleManager.main.battleProjectileManager.Launch(
                projectilePrefabId,
                card.owner.transform.position + skillData.launchPositionOffset,
                card.targetPosition,
                skillData.travelTime,
                card.owner);
        }
    }
}
