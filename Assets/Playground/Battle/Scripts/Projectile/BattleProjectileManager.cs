using UnityEngine;
using UnityEngine.InputSystem;

namespace ProjectOneMore.Battle
{
    public class BattleProjectileManager : MonoBehaviour
    {
        public LineRenderer lineRenderer;

        private BattleProjectile targetingProjectile;

        [SerializeField]
        private Vector3 _mousePos;

        [SerializeField]
        private Vector3 _pointPos;

        private float _travelTime = 1f;

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

        public void SpawnProjectileWithTargeting(BattleProjectile projectilePrefab, Vector3 position, float travelTime)
        {
            BattleProjectile projectile = CreateProjectile(projectilePrefab, position);

            targetingProjectile = projectile;
            projectile.Show(position);
            _travelTime = travelTime;

            targetingProjectile.projectileCollider.enabled = false;
            targetingProjectile.SetLineRenderer(lineRenderer);
            ShowLine();
        }

        public void Launch(BattleProjectile projetilePrefab, Vector3 launchPosition, Vector3 targetPosition, float travelTime, BattleUnit owner = null)
        {
            BattleProjectile projectile = CreateProjectile(projetilePrefab, launchPosition);

            // Test Damage
            if(owner != null)
            {
                projectile.SetDamager(owner);
            }

            projectile.Show(launchPosition);
            projectile.Launch(targetPosition, travelTime);
        }

        public void HideProjectile()
        {
            if (!targetingProjectile)
                return;

            targetingProjectile.Hide();
            HideLine();
        }

        private void SetPointPosition()
        {
            _mousePos = Mouse.current.position.ReadValue();
            RaycastHit hit;
            Ray ray = Camera.main.ScreenPointToRay(_mousePos);

            if (Physics.Raycast(ray, out hit, Mathf.Infinity, targetingProjectile.trajectoryController.canHit))
            {
                _pointPos = hit.point;
            }
            else
            {
                _mousePos.z = Camera.main.nearClipPlane - Camera.main.transform.position.z;
                _mousePos.y = 0f;

                _pointPos = Camera.main.ScreenToWorldPoint(_mousePos);
                _pointPos.y = 0f;
                _pointPos.z = transform.position.z;
            }
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

        private void Start()
        {
            HideProjectile();
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