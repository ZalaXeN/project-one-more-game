using ProjectOneMore.Battle;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class RiseSMB : BehaviourLinkedSMB<BattleUnit>
    {
        protected override void OnLinkedStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
        }

        protected override void OnLinkedStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            if (m_MonoBehaviour == null)
                return;

            m_MonoBehaviour.Rise();
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
