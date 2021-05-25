using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class SpriteAfterImageCaller : MonoBehaviour
{
    public SpriteAfterImage afterImagePrefab;
    public SpriteRenderer targetSpriteRenderer;
    [Range(0f, 1f)]
    public float spawnRate = 0.1f;
    [Range(0.1f, 1f)]
    public float afterImageLifetime = 0.2f;
    public Color afterImageColor = Color.white;

    private List<GameObject> trailPool = new List<GameObject>();

    void Start()
    {
        InvokeRepeating("SpawnTrailPart", 0, spawnRate);
    }

    void SpawnTrailPart()
    {
        if (!afterImagePrefab || !targetSpriteRenderer)
            return;

        GameObject trailPart = GetTrailPart();

        trailPart.SetActive(true);
        trailPart.GetComponent<SpriteAfterImage>().Setup(targetSpriteRenderer, afterImageLifetime, afterImageColor);

        trailPool.Add(trailPart);
    }

    GameObject GetTrailPart()
    {
        foreach (GameObject go in trailPool)
        {
            if (!go.activeInHierarchy)
                return go;
        }

        return Instantiate(afterImagePrefab.gameObject);
    }

    private void ClearPool()
    {
        for (int i = 0; i < trailPool.Count; i++)
        {
            if (trailPool[i])
                Destroy(trailPool[i].gameObject);
        }
    }

    private void OnDisable()
    {
        ClearPool();
    }

    private void OnDestroy()
    {
        ClearPool();
    }
}
