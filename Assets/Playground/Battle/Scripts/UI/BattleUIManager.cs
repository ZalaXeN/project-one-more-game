using UnityEngine;
using UnityEngine.UI;

namespace ProjectOneMore.Battle
{
    public class BattleUIManager : MonoBehaviour
    {
        public GameObject[] otherPanels;
        public GameObject inputPanel;

        private void Update()
        {
            if (BattleManager.main == null)
                return;

            if(BattleManager.main.battleState == BattleState.PlayerInput && !inputPanel.activeInHierarchy)
            {
                ShowInputPanel();
                HideOtherPanels();
            }
            else if (BattleManager.main.battleState != BattleState.PlayerInput && inputPanel.activeInHierarchy)
            {
                HideInputPanel();
                ShowOtherPanels();
            }
        }

        private void ShowInputPanel()
        {
            inputPanel.SetActive(true);
        }

        private void HideInputPanel()
        {
            inputPanel.SetActive(false);
        }

        private void ShowOtherPanels()
        {
            foreach(GameObject go in otherPanels)
            {
                go.SetActive(true);
            }
        }

        private void HideOtherPanels()
        {
            foreach (GameObject go in otherPanels)
            {
                go.SetActive(false);
            }
        }
    }
}