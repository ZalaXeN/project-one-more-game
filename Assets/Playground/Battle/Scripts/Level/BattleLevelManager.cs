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
    }

    public class BattleLevelManager : MonoBehaviour
    {
        public List<BattleLevelSpawnTime> levelSpawnTimeList;

        [HideInInspector]
        public float spawnTimer;

        private BattleLevelSpawnTime _defaultTargetLevelSpawnTime = new BattleLevelSpawnTime();

        public void UpdateSpawnTime(float time)
        {
            spawnTimer += time;
            CheckLevelSpawn(spawnTimer);
        }

        private void CheckLevelSpawn(float time)
        {
            BattleLevelSpawnTime targetLevelSpawnTime = _defaultTargetLevelSpawnTime;
            bool found = false;
            foreach (BattleLevelSpawnTime levelSpawn in levelSpawnTimeList)
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

            // TODO Spawn with prefab id
            bool spawnSuccess = BattleManager.main.SpawnMinion(
                targetLevelSpawnTime.spawnId, 
                targetLevelSpawnTime.team);

            targetLevelSpawnTime.isDone = spawnSuccess;

            if (!spawnSuccess)
                spawnTimer = targetLevelSpawnTime.time;
        }
    }
}
