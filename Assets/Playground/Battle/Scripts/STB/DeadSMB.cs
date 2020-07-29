using ProjectOneMore.Battle;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class DeadSMB : BehaviourLinkedSMB<BattleUnit>
    {
        public bool IsDestroyOnDead = true;

        protected override void OnLinkedStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
        }

        protected override void OnLinkedStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            if (m_MonoBehaviour == null || !IsDestroyOnDead)
                return;

            m_MonoBehaviour.DestroyUnit();
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
