using UnityEngine;
using UnityEngine.Events;

namespace ProjectOneMore.Battle 
{
    [System.Serializable]
    public class BattleHitDamageEvent : UnityEvent<BattleDamage.DamageMessage, BattleDamagable>
    {

    }

    public class BattleDamager : MonoBehaviour
    {
        public BattleDamage.DamageMessage damage;
        public BattleHitDamageEvent OnHit;

        private void OnCollisionEnter(Collision collision)
        {
            ProcessHit(collision);
        }

        private void ProcessHit(Collision collision)
        {
            BattleDamagable damagableHit = collision.gameObject.GetComponent<BattleDamagable>();
            if (damagableHit != null)
            {
                damage.hitPosition = collision.GetContact(0).point;

                damagableHit.OnTakeDamage.Invoke(damage);
                OnHit.Invoke(damage, damagableHit);
            }
        }
    }
}
