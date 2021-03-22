using UnityEngine;
using UnityEngine.Events;

namespace ProjectOneMore.Battle 
{
    [System.Serializable]
    public class BattleHitDamageEvent : UnityEvent<BattleDamage.DamageMessage>
    {

    }

    public class BattleDamager : MonoBehaviour
    {
        public BattleDamage.DamageMessage damage;
        public BattleHitDamageEvent OnHit;

        // Test
        private void OnTriggerEnter(Collider other)
        {
            BattleDamagable damagableHit = other.GetComponent<BattleDamagable>();
            if (damagableHit != null)
            {
                damagableHit.OnTakeDamage.Invoke(damage);
                OnHit.Invoke(damage);
            }
        }
    }
}
