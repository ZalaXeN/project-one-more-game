using System.Collections;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class BattleActionExecutor : MonoBehaviour
    {
        public BattleUnit battleUnit;

        void ExecuteAction()
        {
            if (battleUnit)
            {
                battleUnit.ExecuteCurrentBattleAction();
            }
        }
    }
}