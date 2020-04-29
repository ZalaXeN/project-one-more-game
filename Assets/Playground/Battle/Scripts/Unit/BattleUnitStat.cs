using Unity.Mathematics;

namespace ProjectOneMore.Battle
{
    [System.Serializable]
    public class BattleUnitStat
    {
        public int max;

        private int _current;
        public int current
        {
            get { return _current; }
            set
            {
                _current = math.clamp(value, 0, max);
            }
        }
    }
}