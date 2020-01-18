using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TesterCameraTarget : MonoBehaviour
{
    [SerializeField] Transform targetTransform;

    private void Update()
    {
        transform.position = targetTransform.position;
    }
}
