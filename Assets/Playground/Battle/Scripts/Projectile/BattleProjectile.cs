using UnityEngine;
using System.Collections;
using System;

namespace ProjectOneMore.Battle
{
    public class BattleProjectile : MonoBehaviour
    {
        public Rigidbody rb;
        public Vector3 moveSpeed;
        public TrajectoryController trajectoryController;

        private Vector3 _startPos;

        public void Hide()
        {
            transform.position = _startPos;
            transform.position += Vector3.up * 10;

            rb.isKinematic = true;
            rb.useGravity = false;
            rb.rotation = Quaternion.identity;

            gameObject.SetActive(false);
        }

        public void Show(Vector3 position)
        {
            Reset();
            transform.position = position;
            _startPos = transform.position;
        }

        public void Launch(Vector3 targetPosition, float travelTime)
        {
            if (trajectoryController == null)
                return;

            trajectoryController.targetPos = targetPosition;
            trajectoryController.travelTime = travelTime;
            trajectoryController.CalcVerocityFromTarget();

            moveSpeed = trajectoryController.velocity;

            rb.isKinematic = false;
            rb.useGravity = true;
            rb.velocity = moveSpeed;
        }

        public void SetLineRenderer(LineRenderer lineRenderer)
        {
            trajectoryController.line = lineRenderer;
        }

        private void Reset()
        {
            transform.position = _startPos;

            rb.isKinematic = true;
            rb.useGravity = false;
            rb.rotation = Quaternion.identity;
        }

        private void Update()
        {
            DisableIfOffscreen();
        }

        private void DisableIfOffscreen()
        {
            if (transform.position.y < -20f)
                Hide();
        }
    }
}
