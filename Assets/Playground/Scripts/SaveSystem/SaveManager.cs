using UnityEngine;
using System.Collections;
using System.IO;
using ProjectOneMore;

// Sample
public class SaveManager : MonoBehaviour
{
    public void Save()
    {
        SerializationManager.Save("auto", SaveData.current);
    }

    public string[] saveFiles;
    public void GetLoadFiles()
    {
        if (!Directory.Exists(GameConfig.SAVE_PATH + "/"))
        {
            Directory.CreateDirectory(GameConfig.SAVE_PATH + "/");
        }

        saveFiles = Directory.GetFiles(GameConfig.SAVE_PATH + "/");
    }

    void Load()
    {
        SaveData.current = (SaveData)SerializationManager.Load(GameConfig.AUTO_SAVE_PATH);
    }
}
