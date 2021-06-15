﻿using UnityEngine;
using ProjectOneMore.Battle;

namespace ProjectOneMore
{
    [CreateAssetMenu(fileName = "AbilityData", menuName = "Data/Ability", order = 0)]
    public class AbilityData : ScriptableObject
    {
        public enum AreaType
        {
            Box,
            Circle
        }

        [Header("Skill Detail")]
        public string skillId;
        public string skillName;
        public SkillType skillType;
        public SkillEffectTarget skillEffectTarget;
        public SkillTargetType skillTargetType;
        public float minCooldown;
        public float maxCooldown;

        [Space, Header("Action")]
        public string animationId;
        public BattleAction[] battleActions;

        [Space, Header("Targeting")]
        public AreaType targetAreaType;
        public Vector3 targetRange;
        public Vector3 offset;
        public bool lockTargetPositionToOwner;

        [Space, Header("Area and Draw Indicator")]
        public Vector3 sizeDelta;

        [Space, Header("Projectile")]
        // Targeting Projectile not real
        public BattleProjectile projectilePrefab;
        public Vector3 launchPositionOffset = new Vector3(0f, 2f, 0f);
        public float MaxRange = 5f;
        public float MinTravelTime = 1f;
        public float MaxTravelTime = 1f;

        public float GetRandomSkillCooldown()
        {
            return Random.Range(minCooldown, maxCooldown);
        }
    }
}