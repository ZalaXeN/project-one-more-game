using UnityEngine;
using System.Collections;
using Unity.Entities;

namespace ProjectOneMore.Battle
{
    public class BattlePlayerActionCard : MonoBehaviour
    {
        public BattleUnit owner;
        public BattleUnit target;

        public void Target(BattleUnit target)
        {
            if (target.team == owner.team)
                return;
        }
    }
}
