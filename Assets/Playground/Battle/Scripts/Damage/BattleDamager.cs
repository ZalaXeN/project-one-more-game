using UnityEngine;
using UnityEngine.Events;

namespace ProjectOneMore.Battle 
{
    [System.Serializable]
    public class BattleHitDamageEvent : UnityEvent<BattleDamage>
    {

    }

    public class BattleDamager : MonoBehaviour
    {
        public BattleDamage damage;
        public BattleHitDamageEvent OnHit;

        // Test
        private void OnTriggerEnter(Collider other)
        {
            BattleDamagable damagableHit = other.GetComponent<BattleDamagable>();
            if (damagableHit != null)
            {
                if (damage == null)
                    damage = new BattleDamage(null, 100, BattleDamageType.Physical);

                damagableHit.OnTakeDamage.Invoke(damage);
                //Invoke("Destroy", 8f);
            }
        }

        // Test
        private void OnCollisionEnter(Collision collision)
        {
            BattleDamagable damagableHit = collision.gameObject.GetComponent<BattleDamagable>();
            if (damagableHit != null)
            {
                if (damage == null)
                    damage = new BattleDamage(null, 100, BattleDamageType.Physical);

                damagableHit.OnTakeDamage.Invoke(damage);
                //Invoke("Destroy", 8f);
            }
        }

        // Test
        private void Destroy()
        {
            Destroy(gameObject);
        }
    }
}
