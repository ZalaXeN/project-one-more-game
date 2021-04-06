using UnityEngine;

namespace ProjectOneMore
{
    public static class GameConfig
    {
        public static readonly string SAVE_PATH = Application.persistentDataPath + "/SaveFiles";
        public static readonly string SAVE_TYPE = ".omgs";
        public static readonly string AUTO_SAVE_PATH = SAVE_PATH + "/" + "auto" + SAVE_TYPE;

        public static readonly float BATTLE_HIGHEST_AUTO_ATTACK_SPEED = 0.2f;

        public static readonly float BATTLE_MOVEMENT_HIT_LOCK_TIME_MAX = 0.5f;
        public static readonly float BATTLE_MOVEMENT_HIT_LOCK_BREAK_TIME = 2f;

        public static readonly int ACTIVE_CAMERA_PRIORITY = 20;
        public static readonly int INACTIVE_CAMERA_PRIORITY = 10;
    }
}