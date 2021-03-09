using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    [RequireComponent(typeof(Collider))]
    public class BattleActionArea : MonoBehaviour
    {
        public enum AreaType
        {
            Box,
            Capsule
        }

        public BattleUnit owner;
        public Transform parentTransform;
        public Transform groundTransform;
        public Vector3 offsetPosition;

        public bool _isFollowMouse;

        private Collider _areaCollider;

        [SerializeField]
        private List<BattleUnit> _unitInAreaList = new List<BattleUnit>();

        private Vector3 _areaPosition = Vector3.zero;
        private Vector2 _areaSize = Vector2.zero;

        private void OnEnable()
        {
            _areaCollider = GetComponent<Collider>();
        }

        private void OnTriggerEnter(Collider other)
        {
            BattleUnit unit = other.GetComponent<BattleUnit>();
            if (!unit || unit == owner)
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
            UpdateState();
            UpdatePosition();
        }

        private void RotateToGround()
        {
            if (!groundTransform)
                return;

            transform.rotation = Quaternion.Euler(groundTransform.rotation.eulerAngles);
        }

        private void UpdateState()
        {
            _isFollowMouse = BattleManager.main.battleState == BattleState.PlayerInput;

            //if (_areaCollider && BattleManager.main)
            //{
            //    _areaCollider.enabled = BattleManager.main.IsCurrentActionHasTargetType(SkillTargetType.Area) ||
            //        BattleManager.main.IsCurrentActionHasTargetType(SkillTargetType.Projectile);
            //}   
        }

        private void UpdatePosition()
        {
            if (!parentTransform)
                return;

            if(_isFollowMouse)
            {
                _areaPosition = BattleManager.main.GetGroundMousePosition();
                transform.localPosition = _areaPosition;
            }
            else
            {
                if (parentTransform.localScale.x < 0)
                {
                    _areaPosition = parentTransform.position - offsetPosition;
                    _areaPosition.x -= GetExtentsFromCollider().x;
                }
                else
                {
                    _areaPosition = parentTransform.position + offsetPosition;
                    _areaPosition.x += GetExtentsFromCollider().x;
                }


                transform.localPosition = _areaPosition;
            }
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

            return GetAreaSizeDelta() / 2;
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

            if (GetAreaType() == AreaType.Box) return (_areaCollider as BoxCollider).size;
            if (GetAreaType() == AreaType.Capsule)
            {
                _areaSize.x = (_areaCollider as CapsuleCollider).radius * 2;
                _areaSize.y = _areaSize.x;
                // in game y -> z
                // Y Height = (_areaCollider as CapsuleCollider).height;
                return _areaSize;
            }
            return _areaCollider.bounds.size;
        }

        public AreaType GetAreaType()
        {
            if (_areaCollider.GetType() == typeof(BoxCollider)) return AreaType.Box;
            if (_areaCollider.GetType() == typeof(CapsuleCollider)) return AreaType.Capsule;
            return AreaType.Box;
        }
    }
}