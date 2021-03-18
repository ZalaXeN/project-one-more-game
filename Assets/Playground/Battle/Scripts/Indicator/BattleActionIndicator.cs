using System.Collections;
using UnityEngine;
using UnityEngine.UI;

namespace ProjectOneMore.Battle
{
    public class BattleActionIndicator : MonoBehaviour
    {
        public string indicatorId;

        public GameObject actionAreaIndicator;
        public Image indicatorImage;

        public Sprite indicatorSprite;

        private RectTransform rectTransform;

        private bool _isFollowMouse;
        public bool isFollowMouse
        {
            get
            {
                return _isFollowMouse;
            }
            private set
            {
                _isFollowMouse = value;
            }
        }

        private float _showTime;
        public float showTime
        {
            get
            {
                return _showTime;
            }
            private set
            {
                _showTime = value;
            }
        }

        private void Update()
        {
            UpdateIndicator();
        }

        public void Show(Vector3 position, Vector2 sizeDelta, float showTime = 0f, bool isFollowMouse = false)
        {
            if (!rectTransform)
                rectTransform = transform as RectTransform;

            transform.position = position;
            rectTransform.sizeDelta = sizeDelta;

            _isFollowMouse = isFollowMouse;

            if (showTime != 0f)
            {
                Invoke("Hide", showTime);
                _showTime = showTime;
            }

            actionAreaIndicator.SetActive(true);
        }

        public void Hide()
        {
            actionAreaIndicator.SetActive(false);
        }

        void UpdateIndicator()
        {
            if (!actionAreaIndicator || !actionAreaIndicator.activeInHierarchy)
                return;

            if (_isFollowMouse)
                transform.position = BattleManager.main.GetGroundMousePosition();
        }
    }
}