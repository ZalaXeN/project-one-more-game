using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode()]
public class TrajectoryController : MonoBehaviour
{
    [Header("Line Renderer Variables")]
    public LineRenderer line;
    [Range(2, 30)]
    public int resolution = 15;

    [Header("Formula Variables")]
    public Vector3 velocity;
    public float yLimit; //for later
    private float g;

    [Header("Linecast Variables")]
    [Range(2, 30)]
    public int linecastResolution = 2;
    public LayerMask canHit;

    [Header("Target Position")]
    public Vector3 targetPos;
    public float travelTime = 1f;

    private void Start()
    {
        g = Mathf.Abs(Physics.gravity.y);
        CalcVerocityFromTarget();
        StartCoroutine(RenderArc());
    }

    private void Update()
    {
        //StartCoroutine(RenderArc());
    }

    private IEnumerator RenderArc()
    {
        line.positionCount = resolution + 1;
        line.SetPositions(CalculateLineArray());
        yield return null;
    }

    private Vector3[] CalculateLineArray()
    {
        Vector3[] lineArray = new Vector3[resolution + 1];

        var lowestTimeValue = MaxTimeX() / resolution;

        for (int i = 0; i < lineArray.Length; i++)
        {
            var t = lowestTimeValue * i;
            lineArray[i] = CalculateLinePoint(t);
        }

        return lineArray;
    }

    private Vector3 HitPosition()
    {
        var lowestTimeValue = MaxTimeY() / linecastResolution;

        for (int i = 0; i < linecastResolution + 1; i++)
        {
            var t = lowestTimeValue * i;
            var tt = lowestTimeValue * (i + 1);

            RaycastHit hitInfo;

            var hit = Physics.Linecast(CalculateLinePoint(t), CalculateLinePoint(tt), out hitInfo, canHit);

            if (hit)
                return hitInfo.point;
        }

        return CalculateLinePoint(MaxTimeY());
    }

    private Vector3 CalculateLinePoint(float t)
    {
        float x = velocity.x * t;
        float y = (velocity.y * t) - (g * Mathf.Pow(t, 2) / 2);
        return new Vector3(x + transform.position.x, y + transform.position.y, transform.position.z);
    }

    private float MaxTimeY()
    {
        var v = velocity.y;
        var vv = v * v;

        var t = (v + Mathf.Sqrt(vv + 2 * g * (transform.position.y - yLimit))) / g;
        return t;
    }

    private float MaxTimeX()
    {
        var x = velocity.x;
        if (x == 0)
        {
            velocity.x = 000.1f;
            x = velocity.x;
        }

        var t = (HitPosition().x - transform.position.x) / x;
        return t;
    }

    //[ContextMenu("Calculate Verocity to Target Position")]
    public void CalcVerocityFromTarget()
    {
        if (travelTime <= 0)
            travelTime = 0.1f;

        velocity.x = (targetPos.x - transform.position.x) / travelTime;
        velocity.y = ((targetPos.y - transform.position.y) + ((g * (travelTime * travelTime)) / 2)) / travelTime;
    }

    [ContextMenu("Render Trajectory")]
    public void RenderTrajectory()
    {
        CalcVerocityFromTarget();
        StartCoroutine(RenderArc());
    }
}