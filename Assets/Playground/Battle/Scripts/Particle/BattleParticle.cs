using UnityEngine;

namespace ProjectOneMore.Battle
{
    [RequireComponent(typeof(ParticleSystem))]
    public class BattleParticle : MonoBehaviour
    {
        private ParticleSystem _particle;

        public string particleName;
        public float disableTime;

        private void Reset()
        {
            disableTime = GetParticleSystem().main.duration;
        }

        private void OnEnable()
        {
            if (disableTime > 0)
            {
                Invoke("Disable", disableTime);
                GetParticleSystem().Play(true);
            }
        }

        private void Disable()
        {
            gameObject.SetActive(false);
        }

        private ParticleSystem GetParticleSystem()
        {
            if (_particle == null)
                _particle = GetComponent<ParticleSystem>();

            return _particle;
        }
    }
}
