using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    [System.Serializable]
    public class BattleLevelSpawnTime
    {
        public float time;
        public string spawnId;
        public BattleTeam team;
        public bool isDone;

        public BattleLevelSpawnTime()
        {

        }

        public BattleLevelSpawnTime(BattleLevelSpawnTime prototype)
        {
            time = prototype.time;
            spawnId = prototype.spawnId;
            team = prototype.team;
            isDone = false;
        }
    }

    public class BattleLevelManager : MonoBehaviour
    {
        public LevelDataController levelDataController;

        private List<BattleLevelSpawnTime> _levelSpawnTimeList = new List<BattleLevelSpawnTime>();

        [HideInInspector]
        public float spawnTimer;

        private BattleLevelSpawnTime _defaultTargetLevelSpawnTime = new BattleLevelSpawnTime();

        public void LoadLevel(string levelId)
        {
            levelDataController.LoadBattleLevelSpawnTimeList(_levelSpawnTimeList, levelId);
        }

        public void UpdateSpawnTime(float time)
        {
            spawnTimer += time;
            CheckLevelSpawn(spawnTimer);
        }

        private void CheckLevelSpawn(float time)
        {
            BattleLevelSpawnTime targetLevelSpawnTime = _defaultTargetLevelSpawnTime;
            bool found = false;
            foreach (BattleLevelSpawnTime levelSpawn in _levelSpawnTimeList)
            {
                if(levelSpawn.time <= time && !levelSpawn.isDone)
                {
                    targetLevelSpawnTime = levelSpawn;
                    targetLevelSpawnTime.isDone = true;
                    found = true;
                    break;
                }
            }

            if (!found)
                return;

            bool spawnSuccess = BattleManager.main.SpawnMinion(
                targetLevelSpawnTime.spawnId, 
                targetLevelSpawnTime.team);

            targetLevelSpawnTime.isDone = spawnSuccess;

            if (!spawnSuccess)
                spawnTimer = targetLevelSpawnTime.time;
        }
    }
}
