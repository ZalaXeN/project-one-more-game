﻿using System.Collections;
using UnityEngine;
using UnityEngine.UI;

namespace ProjectOneMore.Battle
{
    public class BattleActionIndicator : MonoBehaviour
    {
        public struct IndicatorMessage
        {
            public Vector3 position;
            public Vector3 sizeDelta;
            public bool isFollowMouse;
            public bool isFollowOwner;
            public bool hasCastRange;
            public Transform ownerTransform;
            public float showTime;
            public Vector2 castRange;
            public AreaSkillData.AreaType castAreaType;
        }

        public string indicatorId;

        public GameObject actionAreaIndicator;
        public Image indicatorImage;

        public Sprite indicatorSprite;

        [HideInInspector]
        public float showTime;

        private RectTransform rectTransform;

        private bool _isFollowMouse;
        private bool _isFollowOwner;
        private bool _hasCastRange;
        private Transform _ownerTransform;
        private Vector2 _castRange;
        private AreaSkillData.AreaType _castAreaType;

        private void Update()
        {
            UpdateIndicator();
        }

        public void Show(IndicatorMessage message)
        {
            if (!rectTransform)
                rectTransform = transform as RectTransform;

            transform.position = message.position;
            rectTransform.sizeDelta = message.sizeDelta;

            _isFollowMouse = message.isFollowMouse;
            _isFollowOwner = message.isFollowOwner;
            showTime = message.showTime;

            _ownerTransform = message.ownerTransform;
            _hasCastRange = message.hasCastRange;
            _castRange = message.castRange;
            _castAreaType = message.castAreaType;

            if (message.showTime != 0f)
            {
                Invoke("Hide", message.showTime);
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
            {
                if (_hasCastRange)
                {
                    switch (_castAreaType)
                    {
                        case AreaSkillData.AreaType.Box:
                            transform.position = BattleManager.main.GetGroundMousePosition(_ownerTransform.position, _castRange);
                            break;
                        case AreaSkillData.AreaType.Circle:
                            transform.position = BattleManager.main.GetGroundMousePosition(_ownerTransform.position, _castRange.x / 2);
                            break;
                    }
                }
                else
                {
                    transform.position = BattleManager.main.GetGroundMousePosition();
                }
            }
            else if (_isFollowOwner && _ownerTransform)
                transform.position = _ownerTransform.position;
        }
    }
}