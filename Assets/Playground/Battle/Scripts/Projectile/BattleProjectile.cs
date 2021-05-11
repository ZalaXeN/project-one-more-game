using UnityEngine;
using System.Collections;
using System;

namespace ProjectOneMore.Battle
{
    public class BattleProjectile : MonoBehaviour
    {
        public Rigidbody rb;
        public Collider projectileCollider;
        public Vector3 moveSpeed;
        public TrajectoryController trajectoryController;
        public BattleDamager damager;

        public bool canHitGround;
        public LayerMask groundLayer;

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

        public void SetDamage(BattleDamage.DamageMessage damageMsg)
        {
            damager.damage = damageMsg;
        }

        // Use on Damager
        public void OnHitHandle(BattleDamage.DamageMessage damageMsg, BattleDamagable damagable)
        {
            BattleUnit unit = damagable.GetComponent<BattleUnit>();

            if (damagable.GetComponent<BattleObject>())
            {
                Destroy(gameObject);
                return;
            }
            else if (unit)
            {
                if(damageMsg.effectTarget == SkillEffectTarget.All)
                    Destroy(gameObject);
                else if (damageMsg.effectTarget == SkillEffectTarget.Enemy && unit.team != damageMsg.owner.team)
                {
                    Destroy(gameObject);
                }
                else if (damageMsg.effectTarget == SkillEffectTarget.Ally && unit.team == damageMsg.owner.team)
                {
                    Destroy(gameObject);
                }
                else if (damageMsg.effectTarget == SkillEffectTarget.Self && unit == damageMsg.owner)
                {
                    Destroy(gameObject);
                }
            }
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
            if (transform.position.y < -20f || transform.position.y > 20f)
                Destroy(gameObject);
        }

        private void OnCollisionEnter(Collision collision)
        {
            //Check hit ground layer
            if((groundLayer.value & 1 << collision.gameObject.layer) != 0)
            {
                if (canHitGround)
                {
                    Destroy(gameObject);
                }
            }
        }
    }
}
