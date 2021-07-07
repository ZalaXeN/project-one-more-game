using System.Collections;
using UnityEngine;
using UnityEngine.UI;

namespace ProjectOneMore.Battle
{
    public class BattleActionIndicator : MonoBehaviour
    {
        public struct IndicatorMessage
        {
            public Vector3 position;
            public Vector3 offset;
            public Vector3 sizeDelta;
            public bool isFollowMouse;
            public bool isFollowOwner;
            public bool hasCastRange;
            public Transform ownerTransform;
            public float showTime;
            public Vector2 castRange;
            public AbilityData.AreaType castAreaType;
            public BattleState targetBattleState;
        }

        public string indicatorId;

        public GameObject actionAreaIndicator;
        public Image indicatorImage;

        public Sprite indicatorSprite;

        private RectTransform rectTransform;

        private IndicatorMessage indicatorData;

        private void Update()
        {
            UpdateIndicator();
        }

        public void Show(IndicatorMessage message)
        {
            if (!rectTransform)
                rectTransform = transform as RectTransform;

            indicatorData = message;

            transform.position = indicatorData.position;
            rectTransform.sizeDelta = indicatorData.sizeDelta;

            if (indicatorData.showTime != 0f)
            {
                Invoke("Hide", indicatorData.showTime);
            }

            actionAreaIndicator.SetActive(true);
        }

        public void Hide()
        {
            if (indicatorData.showTime == 0f)
            {
                actionAreaIndicator.SetActive(false);
            }
        }

        public void Hide(BattleState battleState)
        {
            if (indicatorData.showTime == 0f)
            {
                if((indicatorData.targetBattleState & battleState) != battleState)
                    actionAreaIndicator.SetActive(false);
            }
        }

        void UpdateIndicator()
        {
            if (!actionAreaIndicator || !actionAreaIndicator.activeInHierarchy)
                return;

            if (indicatorData.isFollowMouse)
            {
                if (indicatorData.hasCastRange)
                {
                    switch (indicatorData.castAreaType)
                    {
                        case AbilityData.AreaType.Box:
                            transform.position = BattleManager.main.GetGroundMousePosition(indicatorData.ownerTransform.position + indicatorData.offset, indicatorData.castRange);
                            break;
                        case AbilityData.AreaType.Circle:
                            transform.position = BattleManager.main.GetGroundMousePosition(indicatorData.ownerTransform.position + indicatorData.offset, indicatorData.castRange.x / 2);
                            break;
                        case AbilityData.AreaType.Ground:
                            transform.position = BattleManager.main.GetGroundMousePosition();
                            break;
                    }
                }
                else
                {
                    transform.position = BattleManager.main.GetGroundMousePosition();
                }
            }
            else if (indicatorData.isFollowOwner && indicatorData.ownerTransform)
                transform.position = indicatorData.ownerTransform.position + indicatorData.offset;
        }
    }
}