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
}
