using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class BillboardSprite : MonoBehaviour
{
    private Camera _camera;

    private void LateUpdate()
    {
        Billboarding();
    }

    private void Billboarding()
    {
        if(_camera == null)
            _camera = Camera.main;

        transform.LookAt(transform.position + _camera.transform.rotation * Vector3.forward,
            _camera.transform.rotation * Vector3.up);

        //transform.forward = _camera.transform.forward;
    }
}
