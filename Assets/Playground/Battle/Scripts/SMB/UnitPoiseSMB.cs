using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class UnitPoiseSMB : BehaviourLinkedSMB<BattleUnit>
    {
        public float poiseMotion;

        protected override void OnLinkedStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            if (m_MonoBehaviour == null)
                return;

            m_MonoBehaviour.SetPoise(poiseMotion);
        }
    }
}