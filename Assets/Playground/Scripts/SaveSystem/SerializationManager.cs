using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
using UnityEngine;
using ProjectOneMore;

public class SerializationManager
{
    public static bool Save(string saveName, object saveData)
    {
        BinaryFormatter binaryFormatter = GetBinaryFormatter();

        if(!Directory.Exists(GameConfig.SAVE_PATH))
        {
            Directory.CreateDirectory(GameConfig.SAVE_PATH);
        }
        string savePath = GameConfig.SAVE_PATH + "/" + saveName + GameConfig.SAVE_TYPE;

        FileStream file = File.Create(savePath);
        binaryFormatter.Serialize(file, saveData);
        file.Close();

        return true;
    }

    public static object Load(string loadPath)
    {
        if (!File.Exists(loadPath))
        {
            return null;
        }

        BinaryFormatter binaryFormatter = GetBinaryFormatter();

        FileStream file = File.Open(loadPath, FileMode.Open);

        try
        {
            object saveData = binaryFormatter.Deserialize(file);
            file.Close();
            return saveData;
        }
        catch
        {
            Debug.LogErrorFormat("Failed to load file at {0}.", loadPath);
            file.Close();
            return null;
        }
    }

    public static BinaryFormatter GetBinaryFormatter()
    {
        BinaryFormatter binaryFormatter = new BinaryFormatter();

        SurrogateSelector selector = new SurrogateSelector();

        Vector3SerializationSurrogate vector3Surrogate = new Vector3SerializationSurrogate();

        selector.AddSurrogate(typeof(Vector3), new StreamingContext(StreamingContextStates.All), vector3Surrogate);

        binaryFormatter.SurrogateSelector = selector;

        return binaryFormatter;
    }
}
