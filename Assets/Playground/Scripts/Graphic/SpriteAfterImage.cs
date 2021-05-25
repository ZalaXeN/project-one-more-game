using System.Collections;
using UnityEngine;

public class SpriteAfterImage : MonoBehaviour
{
    public SpriteRenderer spriteRenderer;

    private Color _startColor;
    private Color _targetColor;

    private float _lifetime;
    private float _lifetimeCounter;

    private bool _actived;

    public void Setup(SpriteRenderer targetSpriteRenderer, float Lifetime, Color startColor)
    {
        spriteRenderer.sprite = targetSpriteRenderer.sprite;
        transform.localScale = targetSpriteRenderer.transform.lossyScale;
        transform.SetPositionAndRotation(targetSpriteRenderer.transform.position, targetSpriteRenderer.transform.rotation);
        spriteRenderer.sortingLayerID = targetSpriteRenderer.sortingLayerID;
        spriteRenderer.sortingOrder = targetSpriteRenderer.sortingOrder - 1;

        _startColor = startColor;
        _targetColor = _startColor;
        _targetColor.a = 0f;

        _lifetime = Lifetime;
        _lifetimeCounter = 0;

        _actived = true;
    }

    private void Update()
    {
        if (!_actived)
            return;

        _lifetimeCounter += Time.deltaTime;
        spriteRenderer.color = Color.Lerp(_startColor, _targetColor, _lifetimeCounter / _lifetime);

        if(_lifetime <= _lifetimeCounter)
        {
            _actived = false;
            gameObject.SetActive(false);
        }
    }
}
