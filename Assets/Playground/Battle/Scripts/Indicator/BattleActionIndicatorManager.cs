using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    [RequireComponent(typeof(Canvas))]
    public class BattleActionIndicatorManager : MonoBehaviour
    {
        public BattleActionIndicator[] indicatorPrefabs;

        private List<BattleActionIndicator> _indicatorPool = new List<BattleActionIndicator>();

        public void ShowAreaIndicator(string indicatorId, BattleActionIndicator.IndicatorMessage message)
        {
            bool reuseSuccess = ReuseIndicatorFromPool(indicatorId, message);

            if (!reuseSuccess)
                CreateNewIndicator(indicatorId, message);
        }

        private bool ReuseIndicatorFromPool(string indicatorId, BattleActionIndicator.IndicatorMessage message)
        {
            foreach (BattleActionIndicator indicator in _indicatorPool)
            {
                if (indicator.indicatorId == indicatorId && !indicator.gameObject.activeInHierarchy)
                {
                    indicator.gameObject.SetActive(true);
                    indicator.Show(message);
                    return true;
                }
            }
            return false;
        }

        private void CreateNewIndicator(string indicatorId, BattleActionIndicator.IndicatorMessage message)
        {
            GameObject indicatorPrefab = GetIndicatorPrefab(indicatorId);
            if (indicatorPrefab == null)
                return;

            GameObject indicatorGO = Instantiate(indicatorPrefab, transform);

            BattleActionIndicator indicator = indicatorGO.GetComponent<BattleActionIndicator>();
            indicator.Show(message);

            _indicatorPool.Add(indicator);
        }

        private GameObject GetIndicatorPrefab(string id)
        {
            foreach (BattleActionIndicator indicator in indicatorPrefabs)
            {
                if (indicator.indicatorId == id)
                {
                    return indicator.gameObject;
                }
            }

            return null;
        }

        public void HideAreaIndicator()
        {
            foreach(BattleActionIndicator indicator in _indicatorPool)
            {
                if(indicator.showTime == 0f)
                {
                    indicator.Hide();
                }
            }
        }
    }
}