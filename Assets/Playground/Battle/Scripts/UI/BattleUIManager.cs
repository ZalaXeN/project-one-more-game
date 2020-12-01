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
        public GameObject inputPanel;

        [Header("Shuffle Deck")]
        public GameObject[] commandActions;
        [Range(1,10)]
        public int actionPerDraw = 5;

        private List<GameObject> calcActionGOList = new List<GameObject>();
        private List<GameObject> targetActionGOList = new List<GameObject>();

        private void Start()
        {
            Shuffle();

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
        }

        //--- Test
        private void Shuffle(BattleActionCard card)
        {
            Shuffle();
        }

        public void Shuffle()
        {
            if (commandActions.Length < 1)
                return;

            calcActionGOList.Clear();
            foreach (GameObject go in commandActions)
            {
                go.SetActive(false);
                calcActionGOList.Add(go);
            }

            targetActionGOList.Clear();
            for(int i = 0; i < actionPerDraw; i++)
            {
                GameObject targetGo = calcActionGOList[Random.Range(0, calcActionGOList.Count)];

                targetActionGOList.Add(targetGo);
                calcActionGOList.Remove(targetGo);
            }

            foreach (GameObject go in targetActionGOList)
            {
                go.SetActive(true);
            }
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