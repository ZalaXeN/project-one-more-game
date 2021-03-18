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

        public void ShowAreaIndicator(string indicatorId, Vector3 position, Vector2 sizeDelta, bool isFollowMouse = false, float showTime = 0f)
        {
            bool reuseSuccess = ReuseIndicatorFromPool(indicatorId, position, sizeDelta, isFollowMouse, showTime);

            if (!reuseSuccess)
                CreateNewIndicator(indicatorId, position, sizeDelta, isFollowMouse, showTime);
        }

        public void ShowAreaIndicator(string indicatorId, Vector3 position, Vector2 sizeDelta, Transform followTransform, float showTime = 0f)
        {
            bool reuseSuccess = ReuseIndicatorFromPool(indicatorId, position, sizeDelta, followTransform, showTime);

            if (!reuseSuccess)
                CreateNewIndicator(indicatorId, position, sizeDelta, followTransform, showTime);
        }

        private bool ReuseIndicatorFromPool(string indicatorId, Vector3 position, Vector2 sizeDelta, bool isFollowMouse, float showTime)
        {
            foreach (BattleActionIndicator indicator in _indicatorPool)
            {
                if (indicator.indicatorId == indicatorId && !indicator.gameObject.activeInHierarchy)
                {
                    indicator.gameObject.SetActive(true);
                    indicator.Show(position, sizeDelta, isFollowMouse, showTime);
                    return true;
                }
            }
            return false;
        }

        private bool ReuseIndicatorFromPool(string indicatorId, Vector3 position, Vector2 sizeDelta, Transform followTransform, float showTime)
        {
            foreach (BattleActionIndicator indicator in _indicatorPool)
            {
                if (indicator.indicatorId == indicatorId && !indicator.gameObject.activeInHierarchy)
                {
                    indicator.gameObject.SetActive(true);
                    indicator.Show(position, sizeDelta, followTransform, showTime);
                    return true;
                }
            }
            return false;
        }

        private void CreateNewIndicator(string indicatorId, Vector3 position, Vector2 sizeDelta, bool isFollowMouse, float showTime)
        {
            GameObject indicatorPrefab = GetIndicatorPrefab(indicatorId);
            if (indicatorPrefab == null)
                return;

            GameObject indicatorGO = Instantiate(indicatorPrefab, transform);

            BattleActionIndicator indicator = indicatorGO.GetComponent<BattleActionIndicator>();
            indicator.Show(position, sizeDelta, isFollowMouse, showTime);

            _indicatorPool.Add(indicator);
        }

        private void CreateNewIndicator(string indicatorId, Vector3 position, Vector2 sizeDelta, Transform followTransform, float showTime)
        {
            GameObject indicatorPrefab = GetIndicatorPrefab(indicatorId);
            if (indicatorPrefab == null)
                return;

            GameObject indicatorGO = Instantiate(indicatorPrefab, transform);

            BattleActionIndicator indicator = indicatorGO.GetComponent<BattleActionIndicator>();
            indicator.Show(position, sizeDelta, followTransform, showTime);

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