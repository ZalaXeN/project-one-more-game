using System.Collections;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    [RequireComponent(typeof(BattleUnit))]
    public class BattleUnitController : MonoBehaviour
    {
        private BattleUnit _battleUnit;

        private void OnEnable()
        {
            _battleUnit = GetComponent<BattleUnit>();

            if (_battleUnit)
                _battleUnit.SetController(this);
        }

        private void OnDisable()
        {
            if (_battleUnit)
                _battleUnit.RemoveController();
        }
    }
}