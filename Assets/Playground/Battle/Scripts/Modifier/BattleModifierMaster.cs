using System.Collections.Generic;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class BattleModifierMaster : MonoBehaviour, IMessageReceiver
    {
        public static BattleModifierMaster main;

        private List<IBattleModifier> _modifierList = new List<IBattleModifier>();

        private System.Action _schedule;

        private void Awake()
        {
            // Singleton
            if (main != null && main != this)
            {
                Destroy(gameObject);
                return;
            }
            main = this;
        }

        private void Update()
        {
            foreach(IBattleModifier modifier in _modifierList)
            {
                modifier.OnUpdate();
            }
        }

        void LateUpdate()
        {
            if (_schedule != null)
            {
                _schedule();
                _schedule = null;
            }
        }

        public void OnReceiveMessage(MessageType type, object sender, object msg)
        {
            //-- Handle Message
            switch (type)
            {
                case MessageType.DEAD:
                    SignalModifier(type, sender, msg);
                    break;
                default:
                    break;
            }
        }

        public void ApplyModifier(IBattleModifier modifier, BattleUnit unit)
        {
            modifier.OnApply(unit);
            _modifierList.Add(modifier);
        }

        private void SignalModifier(MessageType type, object sender, object msg)
        {
            foreach (IBattleModifier modifier in _modifierList)
            {
                modifier.OnSignal(type, sender, msg);
            }
        }

        public void DestroyModifier(IBattleModifier modifier)
        {
            _schedule += modifier.OnDestroy;
        }

        public void RemoveModifier(IBattleModifier modifier)
        {
            _modifierList.Remove(modifier);
        }
    }
}