using UnityEngine;

public class ParallaxLayer : MonoBehaviour
{
    [SerializeField] float multiplier = 0.0f;
    [SerializeField] bool horizontalOnly = true;
    [SerializeField][Tooltip("Use for Sky")] float slideSpeed = 0.0f;

    private Transform cameraTransform;

    private Vector3 startCameraPos;
    private Vector3 startPos;
    private float slidePos = 0.0f;

    void Start()
    {
        cameraTransform = Camera.main.transform;
        startCameraPos = cameraTransform.position;
        startPos = transform.position;
    }

    private void Update()
    {
        slidePos += slideSpeed;
    }

    private void LateUpdate()
    {
        var position = startPos;
        if (horizontalOnly)
            position.x += multiplier * (cameraTransform.position.x - startCameraPos.x);
        else
            position += multiplier * (cameraTransform.position - startCameraPos);

        // slide
        if (slideSpeed != 0.0f)
            position.x += slidePos;

        transform.position = position;
    }

}
