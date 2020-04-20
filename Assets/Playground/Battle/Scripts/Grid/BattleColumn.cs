using UnityEngine;
using System.Collections;
using UnityEditor;

namespace ProjectOneMore.Battle
{
    public enum BattleSide
    {
        Left,
        Right
    }

    public class BattleColumn : MonoBehaviour
    {
        public BattleSide side;
        public int columnNumber;

        [Range(0, 4)]
        public int unitNumber;

        private static float zFront = -1f;
        private static float zBack = 3f;
        private static float thickness = 10f;

        private Vector3 startLine = new Vector3();
        private Vector3 endLine = new Vector3();

        private void OnDrawGizmos()
        {
            startLine = transform.position;
            startLine.z = zFront;

            endLine = transform.position;
            endLine.z = zBack;

            Handles.DrawBezier(startLine, endLine, startLine, endLine, Color.green, null, thickness);
        }
    }
}
