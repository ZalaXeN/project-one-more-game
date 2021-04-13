using Cinemachine;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class BattleCameraManager : MonoBehaviour
    {
        public enum CameraMode
        {
            Free,
            Directed
        }

        [Space, Header("Camera Settings")]
        [SerializeField] private Camera _mainCamera;
        [SerializeField] private CinemachineVirtualCamera _mainVCam;
        [SerializeField] private CinemachineVirtualCamera _directedVCam;
        [SerializeField] private CinemachineVirtualCamera _skillTargetVCam;

        [Space, Header("Target Group Settings")]
        [SerializeField] private CinemachineTargetGroup _directedTargetGroup;

        [Space, Header("Test Settings")]
        [SerializeField] private CinemachineVirtualCamera[] virtualCameras;

        public CameraMode cameraMode;

        public void SetCameraActive(int id)
        {
            if (id >= virtualCameras.Length)
                return;

            for (int i = 0; i < virtualCameras.Length; i++)
            {
                if (i == id)
                    virtualCameras[i].Priority = GameConfig.MAIN_CAMERA_PRIORITY;
                else
                    virtualCameras[i].Priority = GameConfig.INACTIVE_CAMERA_PRIORITY;
            }
        }

        private void Update()
        {
            DirectDirectedCamera();
            DirectSkillTargetCamera();
        }

        void DirectDirectedCamera()
        {
            if (!_directedVCam)
                return;

            //_directedVCam.Priority = cameraMode == CameraMode.Directed ?
            //    GameConfig.MAIN_CAMERA_PRIORITY : GameConfig.INACTIVE_CAMERA_PRIORITY;

            foreach (BattleUnit unit in BattleManager.main.GetBattleUnitList()) 
            {
                if (_directedTargetGroup.FindMember(unit.centerTransform) < 0)
                    _directedTargetGroup.AddMember(unit.centerTransform, 1, 0);
            }

            for(int i = 0; i < _directedTargetGroup.m_Targets.Length; ++i)
            {
                CinemachineTargetGroup.Target target = _directedTargetGroup.m_Targets[i];

                if (target.target == null)
                {
                    _directedTargetGroup.RemoveMember(target.target);
                    if (i > 0)
                        i--;
                }
            }
        }

        void DirectSkillTargetCamera()
        {
            if (!_skillTargetVCam)
                return;

            _skillTargetVCam.Priority = BattleManager.main.battleState == BattleState.PlayerInput ?
                        GameConfig.SKILL_TARGETING_CAMERA_PRIORITY : GameConfig.INACTIVE_CAMERA_PRIORITY;

            _skillTargetVCam.Follow = BattleManager.main.GetCurrentControlledUnit()?.centerTransform;
        }
    }
}