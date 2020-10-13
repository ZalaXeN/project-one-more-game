using UnityEngine;
using System.Collections;
using System;
using ProjectOneMore.Battle;

public class BattleProjectile : MonoBehaviour
{
    public Rigidbody rb;
    public Vector3 moveSpeed;
    public Vector3 targetPos;

    public TrajectoryController trajectoryController;

    private Vector3 _startPos;

    [SerializeField]
    private Vector3 _mousePos;

    [SerializeField]
    private Vector3 _pointPos;

    private void Start()
    {
        _startPos = transform.position;
        Hide();
    }

    public void Hide()
    {
        trajectoryController.line.enabled = false;

        transform.position = _startPos;
        transform.position += Vector3.up * 10;

        rb.isKinematic = true;
        rb.useGravity = false;
        rb.rotation = Quaternion.identity;
    }

    public void Reset()
    {
        trajectoryController.line.enabled = true;

        transform.position = _startPos;

        rb.isKinematic = true;
        rb.useGravity = false;
        rb.rotation = Quaternion.identity;
    }

    private void Update()
    {
        if (trajectoryController != null && trajectoryController.line.enabled && BattleManager.main.battleState == BattleState.PlayerInput)
        {
            _mousePos = Input.mousePosition;

            RaycastHit hit;
            Ray ray = Camera.main.ScreenPointToRay(_mousePos);

            if (Physics.Raycast(ray, out hit, Mathf.Infinity, trajectoryController.canHit))
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

            trajectoryController.targetPos = _pointPos;
            trajectoryController.RenderTrajectory();
        }

        if(Input.GetMouseButtonDown(0) && rb.isKinematic && BattleManager.main.battleState == BattleState.PlayerInput)
        {
            if (trajectoryController != null)
            {
                rb.isKinematic = false;
                rb.useGravity = true;

                moveSpeed = trajectoryController.velocity;
                targetPos = trajectoryController.targetPos;

                rb.velocity = moveSpeed;

                trajectoryController.line.enabled = false;

                // Test Only Remove After Test
                BattleManager.main.ExitPlayerInput();
            }
        }

        //if (Vector3.Distance(transform.position, targetPos) < 0.1f)
        //    rb.velocity = Vector3.zero;
    }
}
