using UnityEngine;

namespace ProjectOneMore.Battle
{
    [ExecuteInEditMode]
    public class BattleParticlePlayer : MonoBehaviour
    {
        public Transform rootTransform;
        public string particleName;

        public ParticleSystem[] particles;
        private Vector3 particleScale = Vector3.one;

        public void PlayParticle(string particleName)
        {
            if (this.particleName != particleName)
                return;

            // Adjust Scale and flip position
            bool isFlip = rootTransform.localScale.x < 0;
            particleScale.x = Mathf.Abs(particleScale.x);
            particleScale.x *= isFlip ? -1f : 1f;

            foreach (ParticleSystem particle in particles)
            {
                particle.transform.localScale = particleScale;
                particle.Play(true);
            }
        }
    }
}