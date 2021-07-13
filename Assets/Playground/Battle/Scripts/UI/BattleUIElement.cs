using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class BattleUIElement : MonoBehaviour
    {
        private Vector3 _targetPosition;

        protected void Update()
        {
            OnUpdate();
        }

        protected virtual void OnUpdate()
        {
            UpdatePosition();
        }

        protected void UpdatePosition()
        {
            transform.position = Camera.main.WorldToScreenPoint(_targetPosition);
        }

        protected virtual void OnShow(Vector3 position)
        {
            SetPosition(position);
        }

        protected void SetPosition(Vector3 position)
        {
            _targetPosition = position;

            // Overlay Canvas
            transform.position = Camera.main.WorldToScreenPoint(_targetPosition);

            // World Canvas
            //transform.position = position;
        }

        public void Show(Vector3 position)
        {
            OnShow(position);
            gameObject.SetActive(true);
        }

        public void Disable()
        {
            gameObject.SetActive(false);
        }
    }
}