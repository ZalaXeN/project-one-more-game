using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class BattleProjectileManager : MonoBehaviour
    {
        public LineRenderer lineRenderer;

        // TEST
        public GameObject projectileGO;
        public BattleProjectile projectile;

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

        public void SpawnProjectile(Vector3 position, float travelTime)
        {
            projectile.gameObject.SetActive(true);
            projectile.Show(position);
            _travelTime = travelTime;

            projectile.SetLineRenderer(lineRenderer);
            ShowLine();
        }

        public void HideProjectile()
        {
            projectile.Hide();
            HideLine();
        }

        private void Start()
        {
            HideProjectile();
        }

        private void Update()
        {
            if (projectile.gameObject.activeInHierarchy && 
                projectile.trajectoryController != null && 
                BattleManager.main.battleState == BattleState.PlayerInput &&
                projectile.rb.isKinematic)
            {
                ShowLine();
                _mousePos = Input.mousePosition;

                RaycastHit hit;
                Ray ray = Camera.main.ScreenPointToRay(_mousePos);

                if (Physics.Raycast(ray, out hit, Mathf.Infinity, projectile.trajectoryController.canHit))
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

                projectile.trajectoryController.targetPos = _pointPos;
                projectile.trajectoryController.RenderTrajectory();
            }

            if (projectile.gameObject.activeInHierarchy && Input.GetMouseButtonDown(0) && projectile.rb.isKinematic && BattleManager.main.battleState == BattleState.PlayerInput)
            {
                projectile.Launch(_pointPos, _travelTime);
                HideLine();

                // Test Only Remove After Test
                BattleManager.main.ExitPlayerInput();
            }
        }
    }
}