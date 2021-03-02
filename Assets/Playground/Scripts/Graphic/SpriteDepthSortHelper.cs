using UnityEngine;
using System.Collections;

[ExecuteInEditMode()]
[RequireComponent(typeof(Renderer))]
[DisallowMultipleComponent]
public class SpriteDepthSortHelper : MonoBehaviour
{
    private const int SORTING_BASE = 100;
    private const float UPDATE_TIME = 0.1f;

    private float _updateTimer = 0f;
    private Renderer _renderer;

    public Transform target;

    [Tooltip("Use this to offset the object slightly in front or behind the Target object")]
    public int targetOffset = 0;

    private void Reset()
    {
        UpdateTargetWithParent();
        UpdateOffsetWithSortingOrder();
    }

    void LateUpdate()
    {
        UpdateSortingOrder();
    }

    void UpdateTargetWithParent()
    {
        target = transform.root;
    }

    void UpdateOffsetWithSortingOrder()
    {
        if (_renderer == null)
            _renderer = GetComponent<Renderer>();

        targetOffset = _renderer.sortingOrder;
    }

    void UpdateSortingOrder()
    {
        //_updateTimer -= Time.deltaTime;
        //if (_updateTimer > 0f)
        //    return;

        //_updateTimer = UPDATE_TIME;

        if (target == null)
            target = transform;

        if(_renderer == null)
            _renderer = GetComponent<Renderer>();

        _renderer.sortingOrder = -(int)(target.position.z * SORTING_BASE) + targetOffset;
    }
}
