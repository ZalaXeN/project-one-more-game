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
                value = math.clamp(value, 0, max);
                _current = value;
            }
        }
    }
}