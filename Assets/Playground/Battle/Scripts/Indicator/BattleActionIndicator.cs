using System.Collections;
using UnityEngine;
using UnityEngine.UI;

namespace ProjectOneMore.Battle
{
    // TODO 
    // Make real
    public class BattleActionIndicator : MonoBehaviour
    {
        public BattleActionArea actionArea;

        public GameObject attackRangeIndicator;
        public Image indicatorImage;

        private RectTransform rectTransform;

        private void Update()
        {
            UpdateIndicator();
            UpdateIndicatorStatus();
        }

        [ContextMenu("Update Indicator")]
        void UpdateIndicator()
        {
            if (!actionArea || !attackRangeIndicator)
                return;

            if (!rectTransform)
                rectTransform = transform as RectTransform;

            transform.position = actionArea.transform.position;
            transform.localScale = actionArea.GetIndicatorScale();
            rectTransform.sizeDelta = actionArea.GetAreaSizeDelta();
        }

        void UpdateIndicatorStatus()
        {
            if (BattleManager.main?.battleState == BattleState.Battle && !attackRangeIndicator.activeInHierarchy)
                attackRangeIndicator.SetActive(true);

            if (BattleManager.main?.battleState != BattleState.Battle && attackRangeIndicator.activeInHierarchy)
                attackRangeIndicator.SetActive(false);

            if (!attackRangeIndicator.activeInHierarchy)
                return;

            indicatorImage.color = actionArea.HasUnitInArea() ? Color.red : Color.green;
        }
    }
}