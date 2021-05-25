using System.Collections;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class BattleObject : MonoBehaviour
    {
        public BattleUnitStat hp;

        private Rigidbody rb;

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
            int resultDamage = BattleManager.main.GetDamage(damage, this);

            BattleManager.main.ShowDamageNumber(resultDamage, transform.position);

            hp.current -= resultDamage;

            BattleManager.main.battleParticleManager.ShowParticle(damage.hitEffect, transform.position);

            if (!IsAlive())
            {
                Destroy(gameObject);
            }
            else
            {
                Knockback(damage.hitPosition, damage.knockbackPower);
            }
        }

        private bool IsAlive()
        {
            return hp.current > 0;
        }

        private void Knockback(Vector3 hitPosition, float forcePower)
        {
            if (!rb)
                rb = GetComponent<Rigidbody>();

            if (!rb)
                return;

            Vector3 pushForce = transform.position - hitPosition;
            pushForce.y = 10f;
            rb.AddForce((pushForce.normalized * forcePower * 100f) - Physics.gravity * 0.6f);
        }
    }
}