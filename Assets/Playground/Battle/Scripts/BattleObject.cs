using System.Collections;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class BattleObject : MonoBehaviour
    {
        public BattleUnitStat hp;

        private void Start()
        {
            InitStats();
        }

        private void InitStats()
        {
            hp.current = hp.max;
        }

        public void TakeDamage(BattleDamage.DamageMessage damage)
        {
            BattleManager.main.ShowDamageNumber(damage.damage, transform.position);

            hp.current -= damage.damage;

            BattleManager.main.battleParticleManager.ShowParticle(damage.hitEffect, transform.position);

            if (!IsAlive())
            {
                Destroy(gameObject);
            }
        }

        private bool IsAlive()
        {
            return hp.current > 0;
        }
    }
}