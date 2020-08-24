using UnityEngine;
using Unity.Mathematics;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(fileName = "Attack", menuName = "Battle/Action/Attack", order = 1)]
    public class BA_Attack : BattleAction
    {
        [Range(0.1f, 10f)]
        public float powMultiplier = 1f;

        public override void Execute(BattleActionCard card)
        {
            if (card.owner == null || card.GetTarget() == null)
                return;

            // Test Attack
            //string ownerName = card.owner.baseData.keeperName;
            //string victimName = card.GetTarget().baseData.keeperName;
            //Debug.LogFormat("{0} Attack {1}", ownerName, victimName);
            //Debug.Log("Owner Animate Attack.");
            //Debug.Log("Target Animate Attacked.");
            //Debug.LogFormat("{0} received {1} damage", victimName, card.owner.pow.current);
            //card.GetTarget().hp.current -= (int)math.round(card.owner.pow.current * powMultiplier);
            //Debug.LogFormat("{0} has {1} HP", victimName, card.GetTarget().hp.current);

            BattleDamage damage = new BattleDamage(
                card.owner,
                (int)math.round(card.owner.pow.current * powMultiplier),
                BattleDamageType.Physical,
                "slash_hit");

            card.GetTarget().TakeDamage(damage);
        }
    }
}
