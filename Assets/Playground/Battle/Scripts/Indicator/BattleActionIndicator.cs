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

        public GameObject actionRangeIndicator;

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

        private void Update()
        {
            UpdateIndicator();
        }

        public void Show(Vector3 position, Vector2 sizeDelta, float showTime = 0f)
        {
            if (!rectTransform)
                rectTransform = transform as RectTransform;

            transform.position = position;
            rectTransform.sizeDelta = sizeDelta;

            if(showTime == 0f)
                _isFollowMouse = true;
            else
            {
                _isFollowMouse = false;
                Invoke("Hide", showTime);
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