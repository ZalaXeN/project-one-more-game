using System.Threading;
using UnityEngine;
using UnityEngine.UI;

namespace ProjectOneMore.Battle
{
    public class BattleDamageNumber : MonoBehaviour
    {
        public Text damageText;

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
            transform.position += Vector3.up * Time.deltaTime * 100f;
        }

        public void Show(string text, Vector3 position)
        {
            damageText.text = text;
            transform.position = Camera.main.WorldToScreenPoint(position);
            gameObject.SetActive(true);
        }

        private void Disable()
        {
            gameObject.SetActive(false);
        }
    }
}
