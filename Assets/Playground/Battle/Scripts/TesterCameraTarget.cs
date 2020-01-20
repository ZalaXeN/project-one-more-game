using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TesterCameraTarget : MonoBehaviour
{
    [SerializeField] Transform targetTransform;

    public void SetTarget(Transform target)
    {
        targetTransform = target;
    }

    private void Update()
    {
        if (targetTransform == null)
            return;

        transform.position = targetTransform.position;
    }
}
