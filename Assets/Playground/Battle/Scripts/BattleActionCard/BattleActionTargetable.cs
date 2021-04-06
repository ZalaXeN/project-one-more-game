using System.Collections;
using UnityEngine;
using UnityEngine.EventSystems;

namespace ProjectOneMore.Battle
{
    public class BattleActionTargetable : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler, IPointerClickHandler
    {
        public Transform spriteRootTransform;

        protected int _tempLayer;
        protected BattleUnit _unit;
        protected BattleDamagable _damagable;

        public BattleUnit GetBattleUnit()
        {
            if (!_unit)
            {
                _unit = GetComponent<BattleUnit>();
            }

            return _unit;
        }

        public BattleDamagable GetBattleDamagable()
        {
            if (!_damagable)
            {
                _damagable = GetComponent<BattleDamagable>();
            }

            return _damagable;
        }

        void Start()
        {
            _tempLayer = gameObject.layer;
        }

        void IPointerEnterHandler.OnPointerEnter(PointerEventData eventData)
        {
            if (BattleManager.main.battleState == BattleState.PlayerInput)
                BattleManager.main.SelectTarget(this);
        }

        void IPointerExitHandler.OnPointerExit(PointerEventData eventData)
        {
            if (BattleManager.main.battleState == BattleState.PlayerInput)
                BattleManager.main.DeselectTarget();
        }

        void IPointerClickHandler.OnPointerClick(PointerEventData eventData)
        {
            BattleManager.main.SelectTarget(this);
            SetCurrentActionTargetThisUnit();
        }

        private void SetCurrentActionTargetThisUnit()
        {
            if (BattleManager.main.battleState != BattleState.PlayerInput)
                return;

            if (BattleManager.main.CanCurrentActionTarget(this))
            {
                BattleManager.main.SetCurrentActionTarget(this);
                BattleManager.main.CurrentActionTakeAction();
            }
        }

        #region Outline Highlight

        public void Highlight()
        {
            int targetLayer = 13; // Layer "Target"
            _tempLayer = gameObject.layer;
            ChangeLayerForAll(targetLayer);
        }

        public void DeHighlight()
        {
            ChangeLayerForAll(_tempLayer);
        }

        private void ChangeLayerForAll(int targetLayer)
        {
            gameObject.layer = targetLayer;
            Transform targetTransform = spriteRootTransform ? spriteRootTransform : transform;

            foreach (Transform child in targetTransform)
            {
                if (child.GetComponent<SwingEffector>())
                    continue;

                child.gameObject.layer = targetLayer;
            }
        }
        #endregion
    }
}