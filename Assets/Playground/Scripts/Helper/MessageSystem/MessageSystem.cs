using UnityEngine;

namespace ProjectOneMore
{
    public enum MessageType
    {
        BEFORE_DAMAGE,
        DAMAGED,
        DEAD,
        RESPAWN,
        //Add your user defined message type after
    }

    public interface IMessageReceiver
    {
        void OnReceiveMessage(MessageType type, object sender, object msg);
    }
}