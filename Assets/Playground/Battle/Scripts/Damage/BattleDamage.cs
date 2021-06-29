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

    public enum BattleDamageState
    {
        Init,
        Before,
        Damaging,
        Finished
    }

    [System.Serializable]
    public class BattleDamage
    {
        [System.Serializable]
        public struct DamageMessage
        {
            public BattleUnit owner;
            public int atk;
            public int levelAtk;
            public float skillMultiplier;
            public int cri;
            public bool isCritical;

            public float finalMultiplier;

            public BattleDamageType damageType;
            public string hitEffect;
            public SkillEffectTarget effectTarget;
            public Vector3 hitPosition;
            public float knockbackPower;
        }
    }
}
