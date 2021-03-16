using System.Collections;
using UnityEngine;
using ProjectOneMore.Battle;

namespace ProjectOneMore
{
    [CreateAssetMenu(fileName = "SkillData", menuName = "Data/Skill/Projectile", order = 0)]
    public class ProjectileSkillData : SkillData
    {
        // Targeting Projectile not real
        public BattleProjectile projectilePrefab;
        public Vector3 launchPositionOffset = new Vector3(0f, 5f, 0f);
        public float travelTime = 1f;
    }
}