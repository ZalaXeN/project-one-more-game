using System.Collections;
using UnityEngine;
using UnityEngine.UI;

namespace ProjectOneMore.Battle
{
    public class BattleActionIndicator : MonoBehaviour
    {
        public GameObject actionAreaIndicator;
        public Image indicatorImage;

        public GameObject actionRangeIndicator;

        public Sprite indicatorSprite;

        private RectTransform rectTransform;

        private bool _isFollowMouse;

        private void Update()
        {
            //UpdateIndicatorStatus();
            UpdateIndicator();
        }

        public void ShowAreaIndicator(Vector3 position, Vector2 sizeDelta, bool followMouse = true)
        {
            transform.position = position;
            rectTransform.sizeDelta = sizeDelta;
            _isFollowMouse = followMouse;

            actionAreaIndicator.SetActive(true);
        }

        public void HideAreaIndicator()
        {
            actionAreaIndicator.SetActive(false);
        }

        void UpdateIndicator()
        {
            if (!actionAreaIndicator || !actionAreaIndicator.activeInHierarchy)
                return;

            if (!rectTransform)
                rectTransform = transform as RectTransform;

            indicatorImage.sprite = indicatorSprite;

            if (_isFollowMouse)
                transform.position = BattleManager.main.GetGroundMousePosition();
        }

        void UpdateIndicatorStatus()
        {
            //indicatorImage.color = actionArea.HasUnitInArea() ? Color.red : Color.green;
        }
    }
}