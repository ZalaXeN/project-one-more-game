using UnityEngine;
using System.Collections;
using ProjectOneMore;

[System.Serializable]
public class SaveData
{
    private static SaveData _current;
    public static SaveData current;

    public PlayerData playerData;
}
