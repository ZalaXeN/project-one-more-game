using UnityEngine;
using UnityEngine.Events;

namespace ProjectOneMore.Battle
{
    [System.Serializable]
    public class BattleTakeDamageEvent : UnityEvent<BattleDamage.DamageMessage>
    {

    }

    public class BattleDamagable : MonoBehaviour
    {
        public BattleTakeDamageEvent OnTakeDamage;
    }
}
