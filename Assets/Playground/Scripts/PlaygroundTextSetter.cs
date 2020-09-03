using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class PlaygroundTextSetter : MonoBehaviour
{
    private Text _text;

    public void SetText(float number)
    {
        SetText("" + number);
    }

    public void SetText(string text)
    {
        if (_text == null)
            _text = GetComponent<Text>();

        if (_text == null)
            return;

        _text.text = text;
    }
}
