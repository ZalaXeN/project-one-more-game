using UnityEngine;
using System.Collections;
using System;

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
    }

    private void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            transform.position = _startPos;

            rb.isKinematic = true;
            rb.useGravity = false;
            rb.rotation = Quaternion.identity;
        }

        if(Input.GetMouseButton(0))
        {
            if (trajectoryController != null)
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
        }

        if(Input.GetMouseButtonUp(0) && rb.isKinematic)
        {
            if (trajectoryController != null)
            {
                rb.isKinematic = false;
                rb.useGravity = true;

                moveSpeed = trajectoryController.velocity;
                targetPos = trajectoryController.targetPos;

                rb.velocity = moveSpeed;
            }
        }

        //if (Vector3.Distance(transform.position, targetPos) < 0.1f)
        //    rb.velocity = Vector3.zero;
    }
}
