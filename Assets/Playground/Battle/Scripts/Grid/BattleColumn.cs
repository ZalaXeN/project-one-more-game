using UnityEngine;
using System.Collections.Generic;
using Unity.Mathematics;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace ProjectOneMore.Battle
{
    public enum BattleSide
    {
        Left,
        Right
    }

#if UNITY_EDITOR
    [ExecuteInEditMode]
#endif
    public class BattleColumn : MonoBehaviour
    {
        public BattleSide side;
        public int columnNumber;

        public float zFront = -1f;
        public float zBack = 3f;

        public float paddingFront = 0.5f;
        public float paddingBack = 1f;

        [Range(0, 5)]
        public int unitNumber;

        private static float _thickness = 10f;
        private static float _rowHeight = 2f;

        private bool _isRowsUpdating;
        private List<float> _centeredAlignRowList = new List<float>();
        private List<float> _rowPercentPosList = new List<float>();

        private Vector3 _startLine = new Vector3();
        private Vector3 _endLine = new Vector3();

        private void Update()
        {
            UpdateRows();
        }

        private void UpdateRows()
        {
            if (_centeredAlignRowList.Count == unitNumber || unitNumber <= 0 || _isRowsUpdating)
                return;

            _isRowsUpdating = true;

            // Divider Example
            // 1 = 3
            // 2 = 4
            // 3 = 3
            // 4 = 4...
            int divider = unitNumber <= 2 ? unitNumber + 1 : unitNumber - 1;
            float dividerRatio = 1f / divider;

            _centeredAlignRowList.Clear();
            _rowPercentPosList.Clear();
            float cumulative = 0f;

            for(int i = 0; i <= divider; i++)
            {
                _rowPercentPosList.Add(cumulative);
                cumulative += dividerRatio;
            }

            int j = _rowPercentPosList.Count;
            for (int i = 0; i < j; i++)
            {
                _centeredAlignRowList.Add(_rowPercentPosList[_rowPercentPosList.Count / 2]);
                _rowPercentPosList.RemoveAt(_rowPercentPosList.Count / 2);
            }

            // CheckCenteredAlignRowList();

            _isRowsUpdating = false;
        }

        //private void CheckCenteredAlignRowList()
        //{
        //    string resultCheck = "";
        //    foreach (float result in _centeredAlignRowList)
        //    {
        //        resultCheck += result + ", ";
        //    }
        //    Debug.Log(resultCheck);
        //}

        /// <summary>
        /// Get Position of target row.
        /// </summary>
        /// <param name="index">Index of target row</param>
        /// <returns>Position of target row</returns>
        public Vector3 GetRowPosition(int index)
        {
            index = math.clamp(index, 0, _centeredAlignRowList.Count - 1);

            float startRowZ = zFront + paddingFront;
            float endRowZ = zBack - paddingBack;
            float zRow = _centeredAlignRowList[index];
            float zDepth = math.lerp(startRowZ, endRowZ, zRow);

            Vector3 targetRowPos = transform.position;
            targetRowPos.z = zDepth;

            return targetRowPos;
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

            Handles.DrawBezier(_startLine, _endLine, _startLine, _endLine, Color.green, null, _thickness);
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
