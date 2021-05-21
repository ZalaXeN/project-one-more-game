using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class SpriteAfterImage : MonoBehaviour
{
    public Material _targetMaterial;

    private List<GameObject> trailParts = new List<GameObject>();

    void Start()
    {
        InvokeRepeating("SpawnTrailPart", 0, 0.1f); // replace 0.2f with needed repeatRate
    }

    void SpawnTrailPart()
    {
        GameObject trailPart = new GameObject();
        SpriteRenderer trailPartRenderer = trailPart.AddComponent<SpriteRenderer>();
        SpriteRenderer baseRenderer = GetComponent<SpriteRenderer>();

        trailPartRenderer.sprite = baseRenderer.sprite;
        trailPartRenderer.material = _targetMaterial;
        trailPart.transform.localScale = transform.lossyScale;
        trailPart.transform.SetPositionAndRotation(transform.position, transform.rotation);
        trailPartRenderer.sortingLayerID = baseRenderer.sortingLayerID;
        trailPartRenderer.sortingOrder = baseRenderer.sortingOrder + 1;

        trailParts.Add(trailPart);

        StartCoroutine(FadeTrailPart(trailPartRenderer));
        Destroy(trailPart, 0.2f); // replace 0.5f with needed lifeTime
    }

    IEnumerator FadeTrailPart(SpriteRenderer trailPartRenderer)
    {
        Color color = trailPartRenderer.color;
        color.a -= 0.4f; // replace 0.5f with needed alpha decrement
        trailPartRenderer.color = color;

        yield return new WaitForEndOfFrame();
    }
}
