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

    public class BattleDamage
    {
        private BattleUnit _owner;
        private BattleUnit _target;
        private int _damage;
        private BattleDamageType _damageType;
        private string _hitEffect;

        public BattleUnit owner
        {
            private set { _owner = value; }
            get { return _owner; }
        }

        public BattleUnit target
        {
            private set { _target = value; }
            get { return _target; }
        }

        public int damage
        {
            set { _damage = value; }
            get { return _damage; }
        }

        public BattleDamageType damageType
        {
            set { _damageType = value; }
            get { return _damageType; }
        }

        public string hitEffect
        {
            set { _hitEffect = value; }
            get { return _hitEffect; }
        }

        public BattleDamage(BattleUnit owner, int damage, BattleDamageType damageType, string hitEffect = "", BattleUnit target = null)
        {
            _owner = owner;
            _target = target;
            _damage = damage;
            _damageType = damageType;
            _hitEffect = hitEffect;
        }
    }
}
