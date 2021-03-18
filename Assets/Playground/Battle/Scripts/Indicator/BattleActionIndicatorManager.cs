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

        public void ShowAreaIndicator(string indicatorId, Vector3 position, Vector2 sizeDelta, float showTime = 0f, bool isFollowMouse = false)
        {
            bool reuseSuccess = ReuseIndicatorFromPool(indicatorId, position, sizeDelta, showTime, isFollowMouse);

            if (!reuseSuccess)
                CreateNewIndicator(indicatorId, position, sizeDelta, showTime, isFollowMouse);
        }

        private bool ReuseIndicatorFromPool(string indicatorId, Vector3 position, Vector2 sizeDelta, float showTime, bool isFollowMouse)
        {
            foreach (BattleActionIndicator indicator in _indicatorPool)
            {
                if (indicator.indicatorId == indicatorId && !indicator.gameObject.activeInHierarchy)
                {
                    indicator.gameObject.SetActive(true);
                    indicator.Show(position, sizeDelta, showTime, isFollowMouse);
                    return true;
                }
            }
            return false;
        }

        private void CreateNewIndicator(string indicatorId, Vector3 position, Vector2 sizeDelta, float showTime, bool isFollowMouse)
        {
            GameObject indicatorPrefab = GetIndicatorPrefab(indicatorId);
            if (indicatorPrefab == null)
                return;

            GameObject indicatorGO = Instantiate(indicatorPrefab, transform);

            BattleActionIndicator indicator = indicatorGO.GetComponent<BattleActionIndicator>();
            indicator.Show(position, sizeDelta, showTime, isFollowMouse);

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
                if(indicator.isFollowMouse)
                {
                    indicator.Hide();
                }
            }
        }
    }
}