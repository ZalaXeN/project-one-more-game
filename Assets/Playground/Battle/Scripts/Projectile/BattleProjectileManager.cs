using UnityEngine;
using UnityEngine.InputSystem;

namespace ProjectOneMore.Battle
{
    public class BattleProjectileManager : MonoBehaviour
    {
        public LineRenderer lineRenderer;

        private BattleProjectile targetingProjectile;

        [SerializeField]
        private Vector3 _pointPos;

        private float _travelTime = 1f;
        private Vector3 _castPosition;
        private Vector3 _castRange;

        public void ShowLine()
        {
            lineRenderer.enabled = true;
        }

        public void HideLine()
        {
            lineRenderer.enabled = false;
        }

        private BattleProjectile CreateProjectile(BattleProjectile projectilePrefab, Vector3 position)
        {
            GameObject projectileGO = Instantiate(projectilePrefab.gameObject, position, Quaternion.identity);
            BattleProjectile projectile = projectileGO.GetComponent<BattleProjectile>();
            return projectile;
        }

        public void SpawnProjectileWithTargeting(BattleProjectile projectilePrefab, Vector3 position, float travelTime, Vector3 castPosition, Vector3 castRange)
        {
            BattleProjectile projectile = CreateProjectile(projectilePrefab, position);

            targetingProjectile = projectile;
            projectile.Show(position);
            _travelTime = travelTime;

            _castPosition = castPosition;
            _castRange = castRange;

            targetingProjectile.projectileCollider.enabled = false;
            targetingProjectile.SetLineRenderer(lineRenderer);
            ShowLine();
        }

        public void Launch(BattleProjectile projetilePrefab, Vector3 launchPosition, Vector3 targetPosition, float travelTime, BattleDamage.DamageMessage damageMsg)
        {
            BattleProjectile projectile = CreateProjectile(projetilePrefab, launchPosition);

            projectile.SetDamage(damageMsg);
            projectile.Show(launchPosition);
            projectile.Launch(targetPosition, travelTime);
        }

        public void Launch(BattleProjectile projetilePrefab, Vector3 launchPosition, Vector3 targetPosition, float MaxRange, float MinTravelTime, float MaxTravelTime, BattleDamage.DamageMessage damageMsg)
        {
            BattleProjectile projectile = CreateProjectile(projetilePrefab, launchPosition);

            projectile.SetDamage(damageMsg);
            projectile.Show(launchPosition);

            float targetDistance = Vector3.Distance(launchPosition, targetPosition);
            float travelRatio = Mathf.Clamp((targetDistance / MaxRange), 0, MaxRange);
            float travelTime = Mathf.Lerp(MinTravelTime, MaxTravelTime, travelRatio);

            projectile.Launch(targetPosition, travelTime);
        }

        private void SetPointPosition()
        {
            _pointPos = BattleManager.main.GetGroundMousePosition(_castPosition, _castRange);
        }

        private void RenderTrajectory()
        {
            if (targetingProjectile.trajectoryController == null)
                return;

            targetingProjectile.trajectoryController.travelTime = _travelTime;
            targetingProjectile.trajectoryController.targetPos = _pointPos;
            targetingProjectile.trajectoryController.RenderTrajectory();
        }

        private bool IsTargeting()
        {
            return 
                targetingProjectile != null &&
                targetingProjectile.gameObject.activeInHierarchy &&
                BattleManager.main.battleState == BattleState.PlayerInput &&
                targetingProjectile.rb.isKinematic;
        }

        private void Update()
        {
            // Targeting
            if (IsTargeting())
            {
                ShowLine();
                SetPointPosition();
                RenderTrajectory();

                // Launch Click
                if (Mouse.current.leftButton.wasPressedThisFrame)
                {
                    BattleManager.main.SetCurrentActionTarget(_pointPos);
                    HideLine();
                    Destroy(targetingProjectile.gameObject);
                    BattleManager.main.CurrentActionTakeAction();
                }
            }
        }
    }
}