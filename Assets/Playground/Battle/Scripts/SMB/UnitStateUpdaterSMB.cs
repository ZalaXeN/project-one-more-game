using ProjectOneMore.Battle;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class UnitStateUpdaterSMB : BehaviourLinkedSMB<BattleUnit>
    {
        public BattleUnitState targetState;

        protected override void OnLinkedStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            if (m_MonoBehaviour == null)
                return;

            m_MonoBehaviour.SetState(targetState);
        }

        protected override void OnLinkedStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            if (m_MonoBehaviour == null)
                return;
        }

        protected override void OnLinkedStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            if (m_MonoBehaviour == null)
                return;

            // TODO
            // execute Last update frame - for set bool or something
            // animator.SetBool("", false);
        }
    }
}
