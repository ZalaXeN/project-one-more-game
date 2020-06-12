using UnityEngine;
using System.Collections.Generic;
using ProjectOneMore.Battle;

namespace ProjectOneMore
{
    [CreateAssetMenu(fileName = "LevelDataController", menuName = "Level/DataController", order = 1)]
    public class LevelDataController : ScriptableObject
    {
        [SerializeField]
        private LevelData[] _levelDatas = { };

        public void LoadBattleLevelStartSpawnList(List<BattleLevelSpawnTime> targetList, string levelId)
        {
            LevelData targetLevel = GetLevelData(levelId);
            if (targetLevel == null || targetList == null)
                return;

            targetList.Clear();
            foreach (BattleLevelSpawnTime spawn in targetLevel.levelStartSpawn)
            {
                BattleLevelSpawnTime spawnTime = new BattleLevelSpawnTime(spawn);
                targetList.Add(spawnTime);
            }
        }

        public void LoadBattleLevelSpawnTimeList(List<BattleLevelSpawnTime> targetList, string levelId)
        {
            LevelData targetLevel = GetLevelData(levelId);
            if (targetLevel == null || targetList == null)
                return;

            targetList.Clear();
            foreach (BattleLevelSpawnTime spawn in targetLevel.levelSpawnTimes)
            {
                BattleLevelSpawnTime spawnTime = new BattleLevelSpawnTime(spawn);
                targetList.Add(spawnTime);
            }
        }

        private LevelData GetLevelData(string levelId)
        {
            foreach (LevelData data in _levelDatas)
            {
                if (data.levelId == levelId)
                    return data;
            }
            return null;
        }
    }
}
