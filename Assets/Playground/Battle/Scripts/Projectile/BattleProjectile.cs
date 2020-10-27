using UnityEngine;
using System.Collections;
using System;

namespace ProjectOneMore.Battle
{
    public class BattleProjectile : MonoBehaviour
    {
        public Rigidbody rb;
        public Collider collider;
        public Vector3 moveSpeed;
        public TrajectoryController trajectoryController;
        public BattleDamager damager;

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

            StartCoroutine(LaunchProgress());
        }

        public void SetLineRenderer(LineRenderer lineRenderer)
        {
            trajectoryController.line = lineRenderer;
        }

        public void SetDamager(BattleUnit unit)
        {
            damager.damage = new BattleDamage(unit, unit.pow.current, BattleDamageType.Physical, "slash_hit");
        }

        private IEnumerator LaunchProgress()
        {
            yield return null;

            moveSpeed = trajectoryController.velocity;
            rb.velocity = moveSpeed;
            rb.isKinematic = false;
            rb.useGravity = true;
        }

        private void Reset()
        {
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
                Destroy(gameObject);
        }
    }
}
