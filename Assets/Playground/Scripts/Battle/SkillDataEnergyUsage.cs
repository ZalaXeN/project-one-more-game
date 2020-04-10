using UnityEngine;
using System.Collections;

[System.Serializable]
public class SkillDataEnergyUsage<T>
{
    private T _value;
    public T value
    {
        get { return _value; }
        set { _value = value; }
    }

    public bool isPercentage;
}
