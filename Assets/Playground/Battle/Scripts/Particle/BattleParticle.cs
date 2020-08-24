using UnityEngine;

namespace ProjectOneMore.Battle
{
    [RequireComponent(typeof(ParticleSystem))]
    public class BattleParticle : MonoBehaviour
    {
        public string particleName;
        public float disableTime;

        private void Reset()
        {
            disableTime = GetComponent<ParticleSystem>().time;
        }

        private void OnEnable()
        {
            Invoke("Disable", disableTime);
        }

        private void Disable()
        {
            gameObject.SetActive(false);
        }
    }
}
