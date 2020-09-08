using UnityEngine;
using System.Collections;

[ExecuteInEditMode()]
[RequireComponent(typeof(ParticleSystemRenderer))]
public class ParticleDepthSortHelper : MonoBehaviour
{
    private const int SORTING_BASE = 100;
    private const float UPDATE_TIME = 0.1f;

    private float _updateTimer = 0f;
    private ParticleSystemRenderer _particleRenderer;

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
        if (_particleRenderer == null)
            _particleRenderer = GetComponent<ParticleSystemRenderer>();

        targetOffset = _particleRenderer.sortingOrder;
    }

    void UpdateSortingOrder()
    {
        _updateTimer -= Time.deltaTime;
        if (_updateTimer > 0f)
            return;

        _updateTimer = UPDATE_TIME;

        if (target == null)
            target = transform;

        if (_particleRenderer == null)
            _particleRenderer = GetComponent<ParticleSystemRenderer>();

        _particleRenderer.sortingOrder = -(int)(target.position.z * SORTING_BASE) + targetOffset;
    }
}