using UnityEngine;
using System.Collections;

public class MousePointer : MonoBehaviour
{
    private Vector3 _mousePos;

    private void Update()
    {
        _mousePos = Input.mousePosition;
        _mousePos.z = Camera.main.nearClipPlane - Camera.main.transform.position.z;

        transform.position = Camera.main.ScreenToWorldPoint(_mousePos);
    }
}
