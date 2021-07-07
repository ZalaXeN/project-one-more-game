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

        public BattleActionIndicator ShowAreaIndicator(string indicatorId, BattleActionIndicator.IndicatorMessage message)
        {
            BattleActionIndicator indicator = ReuseIndicatorFromPool(indicatorId, message);

            if (!indicator)
                indicator = CreateNewIndicator(indicatorId, message);

            return indicator;
        }

        private BattleActionIndicator ReuseIndicatorFromPool(string indicatorId, BattleActionIndicator.IndicatorMessage message)
        {
            foreach (BattleActionIndicator indicator in _indicatorPool)
            {
                if (indicator.indicatorId == indicatorId && !indicator.gameObject.activeInHierarchy)
                {
                    indicator.gameObject.SetActive(true);
                    indicator.Show(message);
                    return indicator;
                }
            }
            return null;
        }

        private BattleActionIndicator CreateNewIndicator(string indicatorId, BattleActionIndicator.IndicatorMessage message)
        {
            GameObject indicatorPrefab = GetIndicatorPrefab(indicatorId);
            if (indicatorPrefab == null)
                return null;

            GameObject indicatorGO = Instantiate(indicatorPrefab, transform);

            BattleActionIndicator indicator = indicatorGO.GetComponent<BattleActionIndicator>();
            indicator.Show(message);

            _indicatorPool.Add(indicator);
            return indicator;
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

        public void HideAreaIndicator(BattleState battleState)
        {
            foreach(BattleActionIndicator indicator in _indicatorPool)
            {
                indicator.Hide(battleState);
            }
        }
    }
}