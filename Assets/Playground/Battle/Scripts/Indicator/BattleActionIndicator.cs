using System.Collections;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    // TODO 
    // Make real
    public class BattleActionIndicator : MonoBehaviour
    {
        public Transform targetTransform;

        public GameObject attackRangeIndicator;

        private void Update()
        {
            transform.position = targetTransform.position;

            UpdateIndicator();
        }

        void UpdateIndicator()
        {
            if (BattleManager.main?.battleState == BattleState.Battle && !attackRangeIndicator.activeInHierarchy)
                attackRangeIndicator.SetActive(true);

            if (BattleManager.main?.battleState != BattleState.Battle && attackRangeIndicator.activeInHierarchy)
                attackRangeIndicator.SetActive(false);
        }
    }
}