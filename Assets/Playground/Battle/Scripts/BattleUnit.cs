using UnityEngine;
using Unity.Entities;
using System.Collections;
using ProjectOneMore;

namespace ProjectOneMore.Battle
{
    [GenerateAuthoringComponent]
    public class BattleUnit : IComponentData
    {
        public KeeperData baseData;

        public BattleUnitStat hp;
        public BattleUnitStat en;
        public BattleUnitStat pow;
        public BattleUnitStat cri;
        public BattleUnitStat spd;
        public BattleUnitStat def;
    }
}
