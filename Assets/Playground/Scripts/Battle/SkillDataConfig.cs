using UnityEngine;
using System.Collections;

namespace ProjectOneMore
{
    public enum Element
    {
        EARTH,
        WATER,
        WIND,
        FIRE,
        LIGHT,
        DARK
    }

    public enum SkillType
    {
        Passive,
        Instant,
        Melee,
        Range,
        Spell
    }

    public enum SkillTargetType
    {
        Target,
        AoE,
        Projectile,
        Direction,
        Direction_AoE
    }
}
