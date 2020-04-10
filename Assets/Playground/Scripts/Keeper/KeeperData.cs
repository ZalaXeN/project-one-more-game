using UnityEngine;
using System.Collections;

namespace ProjectOneMore
{
    [System.Serializable]
    public struct KeeperStats
    {
        public int POW;
        public int CRI;
        public int SPD;
        public int HP;
        public int DEF;
        public int EN;
    }

    [System.Serializable]
    public class KeeperData
    {
        public string keeperId;
        public string keeperName;
        public KeeperStats baseStats;
    }
}
