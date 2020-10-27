using UnityEngine;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(fileName = "LaunchProjectile", menuName = "Battle/Action/LaunchProjectile", order = 2)]
    public class BA_LaunchProjectile : BattleAction
    {
        // TODO
        // use scriptable object for projectile data instead
        //public string projectilePrefabId;

        public BattleProjectile projectilePrefabId;

        public override void Execute(BattleActionCard card)
        {
            if (card.owner == null)
                return;

            BattleManager.main.battleProjectileManager.Launch(
                projectilePrefabId,
                card.owner.transform.position + card.launchPositionOffset,
                card.targetPosition, 
                card.travelTime,
                card.owner);
        }
    }
}
