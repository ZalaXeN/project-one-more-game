using System.Collections.Generic;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class BattleDamageNumberPool : MonoBehaviour
    {
        public Canvas uiCanvas;
        public BattleDamageNumber battleDamageNumberPrefab;

        private List<BattleDamageNumber> _battleDamageNumbers = new List<BattleDamageNumber>();

        public void ShowDamageNumber(int damage, Vector3 position)
        {
            BattleDamageNumber damageNumber = GetDamageNumber();
            damageNumber.Show("" + damage, position);
        }

        private BattleDamageNumber GetDamageNumber()
        {
            foreach(BattleDamageNumber number in _battleDamageNumbers)
            {
                if(number.gameObject.activeSelf == false)
                {
                    return number;
                }
            }

            // Create New
            BattleDamageNumber damageNumber = Instantiate(
                battleDamageNumberPrefab.gameObject, uiCanvas.transform).GetComponent<BattleDamageNumber>();

            _battleDamageNumbers.Add(damageNumber);

            return damageNumber;
        }
    }
}
