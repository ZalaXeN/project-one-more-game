using UnityEngine;
using System.Collections;

namespace ProjectOneMore.Battle
{
    public enum BattleDamageType
    {
        Physical,
        Magical,
        Heal,
        Hp_Removal
    }

    [System.Serializable]
    public class BattleDamage
    {
        [System.Serializable]
        public struct DamageMessage
        {
            public BattleUnit owner;
            public int damage;
            public BattleDamageType damageType;
            public string hitEffect;
            public SkillEffectTarget effectTarget;
            public Vector3 hitPosition;
            public float knockbackPower;
        }
    }
}
