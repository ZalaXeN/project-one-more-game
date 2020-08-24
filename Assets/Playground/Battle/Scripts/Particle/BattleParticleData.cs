using UnityEngine;
using System.Collections;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(fileName = "BattleParticleData", menuName = "Battle/Particle/Data", order = 1)]
    public class BattleParticleData : ScriptableObject
    {
        public BattleParticle[] particles;
    }
}
