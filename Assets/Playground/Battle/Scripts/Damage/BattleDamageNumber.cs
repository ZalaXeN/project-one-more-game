using System.Threading;
using UnityEngine;
using UnityEngine.UI;

namespace ProjectOneMore.Battle
{
    public class BattleDamageNumber : MonoBehaviour
    {
        public Text damageText;
        [Range(0,100f)]
        public float floatingSpeed = 50f;

        private float _timer = 0f;
        private float _showTime = 2f;

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
            damageText.color = Color.Lerp(Color.red, Color.clear, timeRatio);
            damageText.rectTransform.anchoredPosition += Vector2.up * Time.deltaTime * floatingSpeed;
        }

        public void Show(string text, Vector3 position)
        {
            damageText.text = text;
            // Overlay Canvas
            transform.position = Camera.main.WorldToScreenPoint(position);

            // World Canvas
            //transform.position = position;

            damageText.rectTransform.anchoredPosition = Vector2.zero;
            gameObject.SetActive(true);
        }

        private void Disable()
        {
            gameObject.SetActive(false);
        }
    }
}
