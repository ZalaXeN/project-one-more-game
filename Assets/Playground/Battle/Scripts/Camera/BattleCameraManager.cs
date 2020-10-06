using Cinemachine;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class BattleCameraManager : MonoBehaviour
    {
        [SerializeField]
        private CinemachineVirtualCamera[] virtualCameras;

        public void SetCameraActive(int id)
        {
            if (id >= virtualCameras.Length)
                return;

            for (int i = 0; i < virtualCameras.Length; i++)
            {
                if (i == id)
                    virtualCameras[i].Priority = GameConfig.ACTIVE_CAMERA_PRIORITY;
                else
                    virtualCameras[i].Priority = GameConfig.INACTIVE_CAMERA_PRIORITY;
            }
        }
    }
}