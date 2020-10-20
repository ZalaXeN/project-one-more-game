using UnityEngine;
using Unity.Mathematics;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(fileName = "LaunchProjectile", menuName = "Battle/Action/LaunchProjectile", order = 2)]
    public class BA_LaunchProjectile : BattleAction
    {
        // TODO
        // Add scriptable object for projectile data
        //public string projectilePrefabId;

        public GameObject projectilePrefabId;
        public Vector3 launchPosition;
        public float travelTime;
        public bool inputable;

        public override void Execute(BattleActionCard card)
        {
            if (card.owner == null)
                return;

            //BattleManager.main.battleProjectileManager.SpawnProjectile(launchPosition, travelTime);

            // use Launch instead after re targeting system
            // BattleManager.main.battleProjectileManager.Launch(targetPosition, travelTime);
        }
    }
}
