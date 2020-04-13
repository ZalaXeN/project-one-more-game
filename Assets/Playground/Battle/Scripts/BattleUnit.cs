using UnityEngine;
using Unity.Entities;
using System.Collections;
using ProjectOneMore;

namespace ProjectOneMore.Battle
{
    public enum BattleTeam
    {
        Player,
        Enemy
    }

    public class BattleUnit : MonoBehaviour
    {
        public BattleTeam team;

        public KeeperData baseData;

        public BattleUnitStat hp;
        public BattleUnitStat en;
        public BattleUnitStat pow;
        public BattleUnitStat cri;
        public BattleUnitStat spd;
        public BattleUnitStat def;
    }
}
