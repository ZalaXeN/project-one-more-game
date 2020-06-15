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
    }
}
