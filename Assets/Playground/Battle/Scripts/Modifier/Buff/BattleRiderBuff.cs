using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class BattleRiderBuff : IBattleModifier
    {
        BattleUnit appliedUnit;
        BattleActionIndicator pinIndicator;

        public void OnApply(BattleUnit unit)
        {
            appliedUnit = unit;
            appliedUnit.spdMod += 10.5f;

            BattleActionIndicator.IndicatorMessage pinMsg;
            pinMsg.position = unit.GetTargetPosition();
            pinMsg.offset = Vector3.zero;
            pinMsg.sizeDelta = Vector3.one;
            pinMsg.showTime = 0;
            pinMsg.isFollowMouse = false;
            pinMsg.isFollowOwner = false;
            pinMsg.ownerTransform = unit.transform;
            pinMsg.hasCastRange = false;
            pinMsg.castRange = Vector2.zero;
            pinMsg.castAreaType = AbilityData.AreaType.Circle;
            pinMsg.targetBattleState = BattleState.Battle | BattleState.PlayerInput;

            pinIndicator = BattleManager.main.battleActionIndicatorManager.ShowAreaIndicator("", pinMsg);
        }

        public void OnDestroy()
        {
            pinIndicator.Hide();
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