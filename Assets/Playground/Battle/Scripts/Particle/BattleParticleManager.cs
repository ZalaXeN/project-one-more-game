using System.Collections.Generic;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class BattleParticleManager : MonoBehaviour
    {
        public BattleParticleData battleParticleData;

        private List<BattleParticle> _particlePool = new List<BattleParticle>();

        public void ShowParticle(string particleName, Vector3 position)
        {
            bool reuseSuccess = ReuseParticleFromPool(particleName, position);

            if(!reuseSuccess)
                CreateNewParticle(particleName, position);
        }

        private bool ReuseParticleFromPool(string particleName, Vector3 position)
        {
            foreach(BattleParticle particle in _particlePool)
            {
                if(particle.particleName == particleName && !particle.gameObject.activeInHierarchy)
                {
                    particle.transform.position = position;
                    particle.gameObject.SetActive(true);
                    return true;
                }
            }
            return false;
        }

        private void CreateNewParticle(string particleName, Vector3 position)
        {
            GameObject particlePrefab = GetBattleParticlePrefab(particleName);
            if (particlePrefab == null)
                return;

            GameObject particleGO = Instantiate(particlePrefab, position, Quaternion.identity);
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
    }
}
