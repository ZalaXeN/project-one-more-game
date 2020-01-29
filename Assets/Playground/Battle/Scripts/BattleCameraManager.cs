using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class BattleCameraManager : MonoBehaviour
{
    [SerializeField] CinemachineVirtualCamera battlefieldVC = null;
    [SerializeField] CinemachineVirtualCamera focusVC = null;
    [SerializeField] CinemachineVirtualCamera zoominVC = null;
    [SerializeField] CinemachineVirtualCamera battleFocusVC = null;

    [SerializeField] TesterCameraTarget cameraTarget1 = null;
    [SerializeField] TesterCameraTarget cameraTarget2 = null;

    [SerializeField] bool hasFocusFightUnit = false;
    [SerializeField] Color nonFocusUnitColor = new Color(1f, 1f, 1f, 0.35f);

    private float _focusTimer = 0f;

    private void Start()
    {
        BattleManager.AssignBattleCameraManager(this);
    }

    private void Update()
    {
        if(_focusTimer > 0f)
        {
            _focusTimer -= Time.deltaTime;
        }
    }

    public void ShowBattlefield(int priority)
    {
        if (battlefieldVC.Priority >= priority)
            return;

        battlefieldVC.Priority = priority;
    }

    public void ShowFocus(int priority, Transform targetTransform)
    {
        if (focusVC.Priority >= priority)
            return;

        cameraTarget1.SetTarget(targetTransform);
        focusVC.Priority = priority;
    }

    public void ShowZoomin(int priority, Transform targetTransform)
    {
        if (zoominVC.Priority >= priority)
            return;

        cameraTarget1.SetTarget(targetTransform);
        zoominVC.Priority = priority;
    }

    public void ShowBattleFocus(int priority, Transform targetTransform1, Transform targetTransform2, float duration)
    {
        ShowBattleFocus(priority, targetTransform1, targetTransform2);
        CancelInvoke("ResetBattleFocusVC");
        Invoke("ResetBattleFocusVC", duration);
    }

    public void ShowBattleFocus(int priority, Transform targetTransform1, Transform targetTransform2)
    {
        if (battleFocusVC.Priority > priority || _focusTimer > 0f)
            return;

        _focusTimer = BattleGlobalParam.CAMERA_BOUNCE_FOCUS_TIME;
        cameraTarget1.SetTarget(targetTransform1);
        cameraTarget2.SetTarget(targetTransform2);
        battleFocusVC.Priority = priority;

        if(hasFocusFightUnit)
            BattleManager.ShowFocusFightEffect(targetTransform1, targetTransform2, nonFocusUnitColor);
    }

    public void ResetBattlefieldVC()
    {
        battlefieldVC.Priority = BattleGlobalParam.CAMERA_PRIORITY_NORMAL;
    }

    public void ResetFocusVC()
    {
        focusVC.Priority = BattleGlobalParam.CAMERA_PRIORITY_INACTIVE;
    }

    public void ResetZoominVC()
    {
        zoominVC.Priority = BattleGlobalParam.CAMERA_PRIORITY_INACTIVE;
    }

    public void ResetBattleFocusVC()
    {
        battleFocusVC.Priority = BattleGlobalParam.CAMERA_PRIORITY_INACTIVE;

        if(hasFocusFightUnit)
            BattleManager.ResetFocusSprite();
    }
}
