using UnityEngine;
using System.Collections.Generic;
using Unity.Mathematics;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace ProjectOneMore.Battle
{
#if UNITY_EDITOR
    [ExecuteInEditMode]
#endif
    public class BattleColumn : MonoBehaviour
    {
        public BattleTeam team;
        public int columnNumber;
        public BattleUnitAttackType zone;

        public float zFront = -1f;
        public float zBack = 3f;

        public float paddingFront = 0.5f;
        public float paddingBack = 1f;

        private static float _thickness = 1f;
        private static float _rowHeight = 2f;

        private List<float> _centeredAlignRowList = new List<float>();
        private List<float> _rowPercentPosList = new List<float>();
        private List<BattleUnit> _assignedBattleUnit = new List<BattleUnit>();

        private Vector3 _startLine = new Vector3();
        private Vector3 _endLine = new Vector3();

        private float _lastestRemoveDepth = -1f;
        private float _targetUnitDepth = -1f;
        private float _targetDepth = -1f;

        private void OnDisable()
        {
            if (BattleManager.main == null)
                return;

            BattleManager.main.UnitDeadEvent -= OnUnitDeadEvent;
        }

        public void UpdateRows(bool triggerEvent = true)
        {
            if (_centeredAlignRowList.Count == _assignedBattleUnit.Count || _assignedBattleUnit.Count <= 0)
                return;

            // Divider Example
            // 1 = 3
            // 2 = 4
            // 3 = 3
            // 4 = 4...
            int divider = _assignedBattleUnit.Count <= 2 ? _assignedBattleUnit.Count + 1 : _assignedBattleUnit.Count - 1;
            float dividerRatio = 1f / divider;

            _centeredAlignRowList.Clear();
            _rowPercentPosList.Clear();
            float cumulative = 0f;

            for(int i = 0; i <= divider; i++)
            {
                _rowPercentPosList.Add(cumulative);
                cumulative += dividerRatio;
            }

            // Center First
            int halfIndex = _rowPercentPosList.Count / 2;
            float lastestValue = _rowPercentPosList[halfIndex];
            bool isLower = true;

            // Add Only use to centered align
            for (int i = 0; i < _assignedBattleUnit.Count; i++)
            {
                _centeredAlignRowList.Add(lastestValue);
                _rowPercentPosList.Remove(lastestValue);

                if(isLower)
                    lastestValue = GetHighestLessValueFromRowList(lastestValue);
                else
                    lastestValue = GetLowestMoreValueFromRowList(lastestValue);

                isLower = !isLower;
            }

            if (_targetUnitDepth != -1f)
                _targetDepth = GetNearestColumnDepth(_lastestRemoveDepth);

            if (triggerEvent)
                BattleManager.main.TriggerColumnUpdatedEvent(this);

            //CheckCenteredAlignRowList();
        }

        private float GetLowestMoreValueFromRowList(float value)
        {
            float lowestRow = 1f;
            foreach(float row in _rowPercentPosList)
            {
                if (row > value && row < lowestRow)
                {
                    lowestRow = row;
                }
            }
            return lowestRow;
        }

        private float GetHighestLessValueFromRowList(float value)
        {
            float highestRow = 0f;
            foreach (float row in _rowPercentPosList)
            {
                if (row < value && row > highestRow)
                    highestRow = row;
            }
            return highestRow;
        }

        private void CheckCenteredAlignRowList()
        {
            string resultCheck = "";
            foreach (float result in _centeredAlignRowList)
            {
                resultCheck += result + ", ";
            }
            Debug.Log(resultCheck);
        }

        /// <summary>
        /// Get Position of target row.
        /// </summary>
        /// <param name="columnDepth">z depth of target row</param>
        /// <returns>Position of target row</returns>
        public Vector3 GetRowPosition(float columnDepth)
        {
            columnDepth = math.clamp(columnDepth, 0f, 1f);

            float startRowZ = zFront + paddingFront;
            float endRowZ = zBack - paddingBack;
            float zDepth = math.lerp(startRowZ, endRowZ, columnDepth);

            Vector3 targetRowPos = transform.position;
            targetRowPos.z = zDepth;

            return targetRowPos;
        }

        public float GetColumnDepth(int index)
        {
            if (_centeredAlignRowList.Count <= 0)
                return 0.5f;

            index = math.clamp(index, 0, _centeredAlignRowList.Count - 1);
            return _centeredAlignRowList[index];
        }

        public float GetNearestColumnDepth(float columnDepth, BattleUnit unit = null, bool exceptSelf = false)
        {
            // Return reserved from lastest removed first for target depth
            if (columnDepth == _targetUnitDepth && _targetUnitDepth != -1f)
            {
                if (_targetUnitDepth == 1f || _targetUnitDepth == 0f && _assignedBattleUnit.Count >= 3)
                    _targetDepth = _targetUnitDepth;

                _targetUnitDepth = -1f;
                return _targetDepth;
            }

            float nearestDepth = columnDepth;
            float nearestDistance = 1f;

            foreach (float depth in _centeredAlignRowList)
            {
                if (exceptSelf && depth == columnDepth)
                    continue;

                if (depth == columnDepth)
                    return depth;

                if (math.distance(depth, columnDepth) < nearestDistance)
                {
                    if (unit != null && HasAnotherUnitOnDepth(depth, unit))
                        continue;

                    nearestDepth = depth;
                    nearestDistance = math.distance(depth, columnDepth);
                }
            }

            return nearestDepth;
        }

        public float GetEmptyCenteredFirstColumnDepth(BattleUnit unit)
        {
            foreach (float depth in _centeredAlignRowList)
            {
                if (unit == null || HasAnotherUnitOnDepth(depth, unit))
                    continue;

                return depth;
            }
            return 0f;
        }

        public bool HasAnotherUnitOnDepth(float depth, BattleUnit targetUnit)
        {
            foreach (BattleUnit unit in _assignedBattleUnit)
            {
                if (unit.columnDepth == depth && targetUnit != unit)
                {
                    return true;
                }
            }
            return false;
        }

        public int GetColumnIndex(float columnDepth)
        {
            for(int i = 0; i < _centeredAlignRowList.Count; i++)
            {
                if (columnDepth == _centeredAlignRowList[i])
                    return i;
            }
            return 0;
        }

        public int GetUnitNumber()
        {
            return _assignedBattleUnit.Count;
        }

        public void Initialize()
        {
            BattleManager.main.UnitDeadEvent += OnUnitDeadEvent;
        }

        public void AssignUnit(BattleUnit unit)
        {
            if (_assignedBattleUnit.Contains(unit))
                return;

            _assignedBattleUnit.Add(unit);
        }

        public bool HasUnit(BattleUnitAttackType unitAttackType)
        {
            foreach(BattleUnit unit in _assignedBattleUnit)
            {
                if (unit.attackType == unitAttackType)
                    return true;
            }

            return false;
        }

        public void RemoveUnit(BattleUnit unit)
        {
            if (_assignedBattleUnit.Contains(unit))
            {
                _lastestRemoveDepth = unit.columnDepth;
                _targetUnitDepth = GetNearestColumnDepth(_lastestRemoveDepth, null, true);

                _assignedBattleUnit.Remove(unit);
                UpdateRows();
            }
        }

        public BattleUnit PopUnit()
        {
            BattleUnit targetUnit = GetUnitOnDepth(_centeredAlignRowList[0]);
            _assignedBattleUnit.Remove(targetUnit);
            return targetUnit;
        }

        public BattleUnit GetUnitOnDepth(float columnDepth)
        {
            BattleUnit nearestUnit = null;
            float nearestDistance = 1f;

            foreach (BattleUnit unit in _assignedBattleUnit)
            {
                if (unit.columnDepth == columnDepth)
                    return unit;

                if(nearestUnit == null)
                {
                    nearestUnit = unit;
                    continue;
                }

                if (math.distance(unit.columnDepth, columnDepth) < nearestDistance)
                {
                    nearestUnit = unit;
                    nearestDistance = math.distance(unit.columnDepth, columnDepth);
                }
            }

            return nearestUnit;
        }

        private void OnUnitDeadEvent(BattleUnit unit)
        {
            RemoveUnit(unit);
        }

#if UNITY_EDITOR
        private void OnDrawGizmos()
        {
            DrawColumnGizmos();
            DrawRowsGizmos();
        }

        private void DrawColumnGizmos()
        {
            _startLine = transform.position;
            _startLine.z = zFront;

            _endLine = transform.position;
            _endLine.z = zBack;

            Color drawColor = zone == BattleUnitAttackType.Melee ? Color.red : Color.green;

            Handles.DrawBezier(_startLine, _endLine, _startLine, _endLine, drawColor, null, _thickness);
        }

        private void DrawRowsGizmos()
        {
            float startRowZ = zFront + paddingFront;
            float endRowZ = zBack - paddingBack;
            foreach (float zRow in _centeredAlignRowList)
            {
                float zDepth = math.lerp(startRowZ, endRowZ, zRow);

                Vector3 rowStartLine = transform.position;
                rowStartLine.z = zDepth;

                Vector3 rowEndLine = transform.position;
                rowEndLine.y = _rowHeight;
                rowEndLine.z = zDepth;

                Handles.color = Color.blue;
                Handles.DrawLine(rowStartLine, rowEndLine);
            }
        }
#endif
    }
}
