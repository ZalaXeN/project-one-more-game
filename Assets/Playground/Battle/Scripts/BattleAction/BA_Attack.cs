using UnityEngine;
using System.Collections;

namespace ProjectOneMore.Battle
{
    [CreateAssetMenu(fileName = "Attack", menuName = "Battle/Action/Attack", order = 1)]
    public class BA_Attack : BattleAction
    {
        public override void Execute(BattlePlayerActionCard card)
        {
            // Test Attack
            string ownerName = card.owner.baseData.keeperName;
            string victimName = card.GetTarget().baseData.keeperName;

            Debug.LogFormat("{0} Attack {1}", ownerName, victimName);
            //Debug.Log("Owner Animate Attack.");
            //Debug.Log("Target Animate Attacked.");
            Debug.LogFormat("{0} received {1} damage", victimName, card.owner.pow.current);
            card.GetTarget().hp.current -= card.owner.pow.current;
            Debug.LogFormat("{0} has {1} HP", victimName, card.GetTarget().hp.current);

            if (card.GetTarget().hp.current <= 0)
            {
                Debug.LogFormat("{0} are Dead.", victimName);
                card.GetTarget().Dead();
            }

            Debug.LogFormat("Dehighlight: {0}", victimName); ;
        }
    }
}
