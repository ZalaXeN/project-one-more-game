using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    [RequireComponent(typeof(Collider), typeof(Rigidbody))]
    public class BattleActionArea : MonoBehaviour
    {
        public Transform groundTransform;

        private Collider _areaCollider;

        [SerializeField]
        private List<BattleUnit> _unitInAreaList = new List<BattleUnit>();

        private void OnEnable()
        {
            _areaCollider = GetComponent<Collider>();
        }

        private void OnTriggerEnter(Collider other)
        {
            BattleUnit unit = other.GetComponent<BattleUnit>();
            if (!unit)
                return;

            if(!_unitInAreaList.Contains(unit))
                _unitInAreaList.Add(unit);
        }

        private void OnTriggerExit(Collider other)
        {
            BattleUnit unit = other.GetComponent<BattleUnit>();
            if (!unit)
                return;

            if(_unitInAreaList.Contains(unit))
                _unitInAreaList.Remove(unit);
        }

        private void Update()
        {
            CounterBillboard();
        }

        private void CounterBillboard()
        {
            transform.rotation = Quaternion.Euler(groundTransform.rotation.eulerAngles);
        }

        private void RemoveMissingUnitFromList()
        {
            for(int i = 0; i < _unitInAreaList.Count; i++)
            {
                if (_unitInAreaList[i] == null)
                    _unitInAreaList.Remove(_unitInAreaList[i]);
            }
        }

        public List<BattleUnit> GetUnitInAreaList()
        {
            RemoveMissingUnitFromList();
            return _unitInAreaList;
        }
    }
}