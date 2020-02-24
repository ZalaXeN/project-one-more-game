using UnityEngine;

public class TesterMoveController : MonoBehaviour
{
    [SerializeField] float moveSpeed = 0.02f;

    Vector3 targetPos;

    void Update()
    {
        targetPos = transform.position;

        targetPos.x += Input.GetAxis("Horizontal") * moveSpeed;
        targetPos.y += Input.GetAxis("Vertical") * moveSpeed;

        transform.position = targetPos;
    }
}
