using UnityEngine;

[RequireComponent(typeof(SpriteRenderer))]
public class SwingEffector : MonoBehaviour
{
    [Range(0,1)]
    public float swingLevel;

    private Material _swingMaterial;

    private void OnEnable()
    {
        if (!_swingMaterial)
        {
            _swingMaterial = GetComponent<SpriteRenderer>().material;
        }
    }

    private void Update()
    {
        _swingMaterial.SetFloat("swing_level", swingLevel);
    }
}
