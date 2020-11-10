using System.Collections.Generic;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class BattleParticleManager : MonoBehaviour
    {
        public BattleParticleData battleParticleData;

        private List<BattleParticle> _particlePool = new List<BattleParticle>();

        public void ShowParticle(string particleName, Vector3 position, bool flip = false)
        {
            bool reuseSuccess = ReuseParticleFromPool(particleName, position, flip);

            if(!reuseSuccess)
                CreateNewParticle(particleName, position, flip);
        }

        private bool ReuseParticleFromPool(string particleName, Vector3 position, bool flip)
        {
            foreach(BattleParticle particle in _particlePool)
            {
                if(particle.particleName == particleName && !particle.gameObject.activeInHierarchy)
                {
                    particle.transform.position = position;
                    FlipIfNeeded(particle.transform, flip);

                    particle.gameObject.SetActive(true);
                    return true;
                }
            }
            return false;
        }

        private void CreateNewParticle(string particleName, Vector3 position, bool flip)
        {
            GameObject particlePrefab = GetBattleParticlePrefab(particleName);
            if (particlePrefab == null)
                return;

            GameObject particleGO = Instantiate(particlePrefab, position, Quaternion.identity);

            FlipIfNeeded(particleGO.transform, flip);

            BattleParticle battleParticle = particleGO.GetComponent<BattleParticle>();
            _particlePool.Add(battleParticle);
        }

        private GameObject GetBattleParticlePrefab(string particleName)
        {
            foreach(BattleParticle particle in battleParticleData.particles)
            {
                if(particle.particleName == particleName)
                {
                    return particle.gameObject;
                }
            }

            return null;
        }

        private void FlipIfNeeded(Transform targetTransform, bool flip)
        {
            if (flip)
                FlipScale(targetTransform);
            else
                ResetFlipScale(targetTransform);
        }

        private void FlipScale(Transform targetTransform)
        {
            Vector3 targetScale = targetTransform.localScale;
            targetScale.x *= targetScale.x < 0 ? 1f : -1f; // not flip again
            targetTransform.localScale = targetScale;
        }

        private void ResetFlipScale(Transform targetTransform)
        {
            Vector3 targetScale = targetTransform.localScale;
            targetScale.x *= targetScale.x < 0 ? -1f : 1f; // reset flip
            targetTransform.localScale = targetScale;
        }
    }
}
