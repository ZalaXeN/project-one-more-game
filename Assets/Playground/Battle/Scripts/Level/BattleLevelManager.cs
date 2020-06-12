using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace ProjectOneMore.Battle
{
    public class BattleLevelManager : MonoBehaviour
    {
        public LevelDataController levelDataController;

        private List<BattleLevelSpawnTime> _startSpawn = new List<BattleLevelSpawnTime>();
        private List<BattleLevelSpawnTime> _levelSpawnTimeList = new List<BattleLevelSpawnTime>();

        [HideInInspector]
        public float spawnTimer;

        private BattleLevelSpawnTime _defaultTargetLevelSpawnTime = new BattleLevelSpawnTime();

        private WaitForSeconds _waitForSpawnEnemyInterval = new WaitForSeconds(0.3f);

        public void LoadLevel(string levelId)
        {
            levelDataController.LoadBattleLevelStartSpawnList(_startSpawn, levelId);
            levelDataController.LoadBattleLevelSpawnTimeList(_levelSpawnTimeList, levelId);
        }

        #region Start Spawn
        public Coroutine SpawnStartMinion()
        {
            return StartCoroutine(SpawnStartedEnemy());
        }

        private IEnumerator SpawnStartedEnemy()
        {
            foreach (BattleLevelSpawnTime levelSpawn in _startSpawn)
            {
                BattleManager.main.SpawnMinion(levelSpawn.spawnId, levelSpawn.team);
                yield return _waitForSpawnEnemyInterval;
            }
        }
        #endregion

        #region Spawn Time
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
        #endregion
    }
}
