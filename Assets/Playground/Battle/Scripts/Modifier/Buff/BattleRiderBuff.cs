using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class BattleRiderBuff : IBattleModifier
    {
        BattleUnit appliedUnit;

        public void OnApply(BattleUnit unit)
        {
            appliedUnit = unit;
            appliedUnit.spdMod += 10.5f;
        }

        public void OnDestroy()
        {
            BattleModifierMaster.main.RemoveModifier(this);
            appliedUnit.spdMod -= 10.5f;
            appliedUnit = null;
        }

        public void OnSignal(MessageType type, object sender, object msg)
        {
            if (!BattleManager.main)
                return;

            if (BattleManager.main.battleState != BattleState.Battle && BattleManager.main.battleState != BattleState.PlayerInput)
                return;

            //-- Handle Message
            switch (type)
            {
                case MessageType.DEAD:
                    BattleUnit unit = (BattleUnit)sender;
                    if(appliedUnit == unit)
                        BattleModifierMaster.main.DestroyModifier(this);
                    break;
                default:
                    break;
            }
        }

        public void OnUpdate()
        {
            if(appliedUnit.GetTargetPosition() == Vector3.zero)
                BattleModifierMaster.main.DestroyModifier(this);
        }
    }
}