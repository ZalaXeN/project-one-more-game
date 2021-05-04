using TMPro;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class BattleDamageNumber : MonoBehaviour
    {
        public TextMeshProUGUI damageText;
        [Range(0,100f)]
        public float floatingSpeed = 50f;

        private float _timer = 0f;
        private float _showTime = 2f;
        private Vector3 _targetPosition;
        private Color _startColor = Color.white;

        private void OnEnable()
        {
            _timer = 0f;
            Invoke("Disable", _showTime);
        }

        private void Update()
        {
            _timer += Time.deltaTime;
            UpdateAnimate();
        }

        private void OnDisable()
        {
            
        }

        private void UpdateAnimate()
        {
            float timeRatio = _timer / _showTime;
            damageText.color = Color.Lerp(_startColor, Color.clear, timeRatio);
            damageText.rectTransform.anchoredPosition += Vector2.up * Time.deltaTime * floatingSpeed;

            transform.position = Camera.main.WorldToScreenPoint(_targetPosition);
        }

        public void Show(string text, Vector3 position)
        {
            damageText.text = text;
            _targetPosition = position;

            // Overlay Canvas
            transform.position = Camera.main.WorldToScreenPoint(_targetPosition);

            // World Canvas
            //transform.position = position;

            damageText.rectTransform.anchoredPosition = Vector2.zero;
            _startColor = damageText.color;
            gameObject.SetActive(true);
        }

        private void Disable()
        {
            damageText.color = _startColor;
            gameObject.SetActive(false);
        }
    }
}
