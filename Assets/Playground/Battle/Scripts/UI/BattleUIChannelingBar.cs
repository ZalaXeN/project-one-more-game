using UnityEngine;
using UnityEngine.UI;

namespace ProjectOneMore.Battle
{
    public class BattleUIChannelingBar : BattleUIElement
    {
        public Image barImage;

        public void SetFillAmount(float amount)
        {
            barImage.fillAmount = amount;
        }
    }
}