using UnityEngine;
using System.Collections;

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
                _mousePos.z = Camera.main.nearClipPlane - Camera.main.transform.position.z;
                _pointPos = Camera.main.ScreenToWorldPoint(_mousePos);

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
