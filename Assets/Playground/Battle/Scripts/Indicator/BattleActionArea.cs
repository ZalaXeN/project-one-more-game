using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    [RequireComponent(typeof(Collider), typeof(Rigidbody))]
    public class BattleActionArea : MonoBehaviour
    {
        public Transform parentTransform;
        public Transform groundTransform;
        public Vector3 offsetPosition;

        private Collider _areaCollider;

        [SerializeField]
        private List<BattleUnit> _unitInAreaList = new List<BattleUnit>();

        private Vector3 _areaIndicatorScale = Vector3.one;
        private Vector3 _areaPosition = Vector3.zero;

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
            UpdateActionArea();
        }

        [ContextMenu("Update Action Area")]
        private void UpdateActionArea()
        {
            RotateToGround();
            UpdatePosition();
        }

        private void RotateToGround()
        {
            transform.rotation = Quaternion.Euler(groundTransform.rotation.eulerAngles);
        }

        private void UpdatePosition()
        {
            _areaPosition = offsetPosition;
            _areaPosition.x += GetExtentsFromCollider().x;
            _areaPosition.x *= parentTransform.localScale.x < 0 ? -1f : 1f;
            transform.localPosition = _areaPosition;
        }

        private void RemoveMissingUnitFromList()
        {
            for(int i = 0; i < _unitInAreaList.Count; i++)
            {
                if (_unitInAreaList[i] == null)
                    _unitInAreaList.Remove(_unitInAreaList[i]);
            }
        }

        private Vector3 GetExtentsFromCollider()
        {
            if (!_areaCollider)
                _areaCollider = GetComponent<Collider>();

            if (_areaCollider.GetType() == typeof(BoxCollider)) return (_areaCollider as BoxCollider).size / 2;
            return _areaCollider.bounds.size / 2;
        }

        public Vector3 GetIndicatorScale()
        {
            _areaIndicatorScale.x = Mathf.Abs(parentTransform != null ? parentTransform.localScale.x : transform.localScale.x);
            _areaIndicatorScale.y = 1f;
            _areaIndicatorScale.z = 1f;

            return _areaIndicatorScale;
        }

        public List<BattleUnit> GetUnitInAreaList()
        {
            RemoveMissingUnitFromList();
            return _unitInAreaList;
        }

        public bool HasUnitInArea()
        {
            return GetUnitInAreaList().Count > 0;
        }

        public Vector2 GetAreaSizeDelta()
        {
            if(!_areaCollider)
                _areaCollider = GetComponent<Collider>();

            if (_areaCollider.GetType() == typeof(BoxCollider)) return (_areaCollider as BoxCollider).size;
            return _areaCollider.bounds.size;
        }
    }
}