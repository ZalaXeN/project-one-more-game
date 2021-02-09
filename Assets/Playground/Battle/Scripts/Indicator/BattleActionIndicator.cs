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

        public GameObject actionAreaIndicator;
        public Image indicatorImage;

        public GameObject actionRangeIndicator;

        public Sprite boxSprite;
        public Sprite capsuleSprite;

        private RectTransform rectTransform;

        private void Update()
        {
            UpdateIndicator();
            UpdateIndicatorStatus();
        }

        [ContextMenu("Update Indicator")]
        void UpdateIndicator()
        {
            if (!actionArea || !actionAreaIndicator)
                return;

            if (!rectTransform)
                rectTransform = transform as RectTransform;

            transform.position = actionArea.transform.position;
            rectTransform.sizeDelta = actionArea.GetAreaSizeDelta();

            indicatorImage.sprite = GetAreaSpriteByType();
        }

        void UpdateIndicatorStatus()
        {
            if (CheckShowIndicatorByBattleState() && !actionAreaIndicator.activeInHierarchy)
                actionAreaIndicator.SetActive(true);

            if (!CheckShowIndicatorByBattleState() && actionAreaIndicator.activeInHierarchy)
                actionAreaIndicator.SetActive(false);

            actionRangeIndicator.SetActive(actionAreaIndicator.activeInHierarchy && BattleManager.main?.battleState == BattleState.PlayerInput);

            if (!actionAreaIndicator.activeInHierarchy)
                return;

            indicatorImage.color = actionArea.HasUnitInArea() ? Color.red : Color.green;
        }

        bool CheckShowIndicatorByBattleState()
        {
            if (BattleManager.main?.battleState == BattleState.Battle)
                return true;

            if (BattleManager.main?.battleState == BattleState.PlayerInput)
            {
                if (BattleManager.main.IsCurrentActionHasTargetType(SkillTargetType.Area))
                    return true;

                if (BattleManager.main.IsCurrentActionHasTargetType(SkillTargetType.Projectile))
                    return true;
            }

            return false;
        }

        Sprite GetAreaSpriteByType()
        {
            switch (actionArea.GetAreaType())
            {
                case BattleActionArea.AreaType.Box:
                    return boxSprite;
                case BattleActionArea.AreaType.Capsule:
                    return capsuleSprite;
                default:
                    return boxSprite;
            }
        }
    }
}