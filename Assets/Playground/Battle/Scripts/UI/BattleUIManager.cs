using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace ProjectOneMore.Battle
{
    /// <summary>
    /// Not Real just Mockup
    /// </summary>
    public class BattleUIManager : MonoBehaviour
    {
        [Header("Panel")]
        public GameObject[] otherPanels;
        public GameObject[] actionPanels;
        public GameObject inputPanel;
        public GameObject pausePanel;

        [Header("Shuffle Deck")]
        public GameObject[] commandActions;
        [Range(1,10)]
        public int actionPerDraw = 5;

        private void Start()
        {
            BattleManager.main.PlayerTakeActionEvent += Shuffle;
        }

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

            if (Time.timeScale == 0f && !pausePanel.activeInHierarchy)
                pausePanel.SetActive(true);
            else if (Time.timeScale != 0f && pausePanel.activeInHierarchy)
                pausePanel.SetActive(false);

            if(!inputPanel.activeInHierarchy)
            {
                if (actionPanels[0].activeInHierarchy != BattleManager.main.isOnActionSelector)
                {
                    foreach (GameObject go in actionPanels)
                    {
                        go.SetActive(BattleManager.main.isOnActionSelector);
                    }
                }
            }
        }

        //--- Test
        private void Shuffle(BattleActionCard card)
        {
            
        }
        //---

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