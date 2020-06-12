using System.Collections.Generic;
using UnityEngine;
using ProjectOneMore.Battle;

namespace ProjectOneMore
{
    [CreateAssetMenu(fileName = "LevelData", menuName = "Level/Data", order = 2)]
    public class LevelData : ScriptableObject
    {
        public string levelId;
        public BattleLevelSpawnTime[] levelStartSpawn;
        public BattleLevelSpawnTime[] levelSpawnTimes;
    }
}
