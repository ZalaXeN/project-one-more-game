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
        public Transform spriteRootTransform;

        public bool canHitGround;
        public LayerMask groundLayer;

        //public float torqueSpeed;
        public float spriteRotateSpeed;

        public BattleUnitSpriteLookDirection spriteLookDirection;

        private bool _threw;

        public void Hide()
        {
            Reset();

            spriteRootTransform.gameObject.SetActive(false);
        }

        public void Show(Vector3 position)
        {
            Reset();

            transform.position = position;

            spriteRootTransform.gameObject.SetActive(true);
        }

        public void UpdateFlip(Vector3 lookPos)
        {
            if (lookPos.x < transform.position.x)
            {
                if (transform.localScale.x < 0 && spriteLookDirection == BattleUnitSpriteLookDirection.Left)
                    FlipScaleX();
                else if (transform.localScale.x > 0 && spriteLookDirection == BattleUnitSpriteLookDirection.Right)
                    FlipScaleX();
            }
            else if (lookPos.x > transform.position.x)
            {
                if (transform.localScale.x > 0 && spriteLookDirection == BattleUnitSpriteLookDirection.Left)
                    FlipScaleX();
                else if (transform.localScale.x < 0 && spriteLookDirection == BattleUnitSpriteLookDirection.Right)
                    FlipScaleX();
            }
        }

        private void FlipScaleX()
        {
            Vector3 targetFlipScale = transform.localScale;
            targetFlipScale.x *= -1;
            transform.localScale = targetFlipScale;
        }

        public void Launch(Vector3 targetPosition, float travelTime)
        {
            if (trajectoryController == null)
                return;

            trajectoryController.targetPos = targetPosition;
            trajectoryController.travelTime = travelTime;
            trajectoryController.CalcVerocityFromTarget();

            UpdateFlip(targetPosition);

            StartCoroutine(LaunchProcess());
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
            if (!_threw)
                return;

            BattleUnit unit = damagable.GetComponent<BattleUnit>();

            if (damagable.GetComponent<BattleObject>())
            {
                DestroyProcess();
                return;
            }
            else if (unit)
            {
                if (damageMsg.effectTarget == SkillEffectTarget.All)
                    DestroyProcess();
                else if (damageMsg.effectTarget == SkillEffectTarget.Enemy && unit.team != damageMsg.owner.team)
                {
                    DestroyProcess();
                }
                else if (damageMsg.effectTarget == SkillEffectTarget.Ally && unit.team == damageMsg.owner.team)
                {
                    DestroyProcess();
                }
                else if (damageMsg.effectTarget == SkillEffectTarget.Self && unit == damageMsg.owner)
                {
                    DestroyProcess();
                }
            }
        }

        private void DestroyProcess()
        {
            Hide();
            // If have TrailRenderer
            // Let TrailRenderer Destroy on Autodestruct
            Destroy(gameObject);
        }

        private IEnumerator LaunchProcess()
        {
            yield return null;

            moveSpeed = trajectoryController.velocity;
            rb.velocity = moveSpeed;
            rb.isKinematic = false;
            rb.useGravity = true;
            rb.detectCollisions = true;
            projectileCollider.enabled = true;

            _threw = true;

            //rb.AddTorque(rb.transform.TransformDirection(Vector3.forward) * torqueSpeed, ForceMode.Impulse);

            spriteRootTransform.gameObject.SetActive(true);
        }

        private void Reset()
        {
            rb.isKinematic = true;
            rb.useGravity = false;
            rb.rotation = Quaternion.identity;
            rb.detectCollisions = false;
            projectileCollider.enabled = false;

            _threw = false;
        }

        private void Update()
        {
            RotateSprite();
            DisableIfOffscreen();
        }

        private void DisableIfOffscreen()
        {
            if (transform.position.y < -20f || transform.position.y > 20f)
                DestroyProcess();
        }

        private void RotateSprite()
        {
            if (!_threw)
                return;

            if(transform.localScale.x > 0f)
                transform.localEulerAngles += Vector3.forward * spriteRotateSpeed * Time.deltaTime;
            else
                transform.localEulerAngles -= Vector3.forward * spriteRotateSpeed * Time.deltaTime;
        }

        private void OnCollisionEnter(Collision collision)
        {
            HandleHitGround(collision.gameObject);
        }

        private void HandleHitGround(GameObject go)
        {
            if (!_threw)
                return;

            //Check hit ground layer
            if ((groundLayer.value & 1 << go.layer) != 0)
            {
                if (canHitGround)
                {
                    DestroyProcess();
                }
            }
        }
    }
}
