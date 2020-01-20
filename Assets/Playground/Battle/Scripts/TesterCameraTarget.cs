using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TesterCameraTarget : MonoBehaviour
{
    [SerializeField] Transform targetTransform;

    private void Update()
    {
        if (targetTransform == null)
            return;

        transform.position = targetTransform.position;
    }
}
