﻿using System.Collections;
using UnityEngine;
using UnityEngine.UI;

namespace ProjectOneMore.Battle
{
    public class BattleUISelectedUnitProfile : MonoBehaviour
    {
        public GameObject panelGo;

        public Text unitNameText;
        public Text unitHpText;
        public Image unitHpBarImage;

        private void Update()
        {
            SetSelectedUnit(BattleManager.main?.selectedUnit);
        }

        private void SetSelectedUnit(BattleUnit selectedUnit)
        {
            if (!selectedUnit)
            {
                panelGo.SetActive(false);
            }
            else
            {
                panelGo.SetActive(true);
                unitNameText.text = selectedUnit.baseData.keeperName;
                unitHpText.text = string.Format("{0} / {1}", selectedUnit.hp.current, selectedUnit.hp.max);
                unitHpBarImage.fillAmount = (float)selectedUnit.hp.current / (float)selectedUnit.hp.max;
            }
        }
    }
}