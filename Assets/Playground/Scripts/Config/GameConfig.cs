using UnityEngine;

namespace ProjectOneMore
{
    public static class GameConfig
    {
        public static readonly string SAVE_PATH = Application.persistentDataPath + "/SaveFiles";
        public static readonly string SAVE_TYPE = ".omgs";
        public static readonly string AUTO_SAVE_PATH = SAVE_PATH + "/" + "auto" + SAVE_TYPE;
    }
}