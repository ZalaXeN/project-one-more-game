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

        private void OnTriggerEnter(Collider other)
        {
            ProcessHit(other);
        }

        private void ProcessHit(Collider other)
        {
            BattleDamagable damagableHit = other.gameObject.GetComponent<BattleDamagable>();
            if (damagableHit != null)
            {
                damage.hitPosition = transform.position;
                damagableHit.OnTakeDamage.Invoke(damage);
                OnHit.Invoke(damage, damagableHit);
            }
        }
    }
}
