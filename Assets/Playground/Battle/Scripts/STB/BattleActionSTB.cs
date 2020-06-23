using ProjectOneMore.Battle;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class BattleActionSTB : BehaviourLinkedSMB<BattleUnit>
    {
        public enum OperationMode
        {
            Enter,
            Update,
            Exit
        }

        public OperationMode operationMode;
        public float[] executeTimesForUpdateMode;

        private float _timer;
        private int _counter;

        protected override void OnLinkedStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            _timer = 0f;
            _counter = 0;

            if (operationMode != OperationMode.Enter || m_MonoBehaviour == null)
                return;

            m_MonoBehaviour.ExecuteCurrentBattleAction();
        }

        protected override void OnLinkedStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            if (operationMode != OperationMode.Exit || m_MonoBehaviour == null)
                return;

            m_MonoBehaviour.ExecuteCurrentBattleAction();
        }

        protected override void OnLinkedStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            if (operationMode != OperationMode.Update || m_MonoBehaviour == null)
                return;

            _timer += Time.deltaTime * stateInfo.speed;

            if (_counter < executeTimesForUpdateMode.Length && _timer > executeTimesForUpdateMode[_counter])
            {
                m_MonoBehaviour.ExecuteCurrentBattleAction();
                _counter++;
            }

            if (_timer < stateInfo.length)
                return;

            // TODO
            // execute Last update frame - for set bool or something
            // animator.SetBool("", false);
        }
    }
}
