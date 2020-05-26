using ProjectOneMore.Battle;
using UnityEngine;
using UnityEngine.UI;

namespace ProjectOneMore.Battle
{
    [RequireComponent(typeof(Text))]
    public class BattleSpawnTimerText : MonoBehaviour
    {
        private Text _text;

        private void OnEnable()
        {
            _text = GetComponent<Text>();
        }

        void Update()
        {
            SetTimeText();
        }

        void SetTimeText()
        {
            _text.text = "Time: " + BattleManager.main.battleTime;
            _text.text += "\nSpawn Time: " + BattleManager.main.spawnTimer;
        }
    }
}
