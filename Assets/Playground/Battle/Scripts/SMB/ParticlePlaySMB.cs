using ProjectOneMore.Battle;
using UnityEngine;

namespace ProjectOneMore.Battle
{
    // Use Particle Player on Animation Event Instead
    public class ParticlePlaySMB : BehaviourLinkedSMB<BattleUnit>
    {
        public enum OperationMode
        {
            Enter,
            Update,
            Exit
        }

        public OperationMode operationMode;
        public float[] executeTimesForUpdateMode;
        public string[] particlesOnEachTime;
        public Vector3[] playPositionOffsetOnEachTime;

        private float _timer;
        private int _counter;

        protected override void OnLinkedStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            _timer = 0f;
            _counter = 0;

            if (operationMode != OperationMode.Enter || m_MonoBehaviour == null)
                return;

            PlayParticle(particlesOnEachTime[0], playPositionOffsetOnEachTime[0]);
        }

        protected override void OnLinkedStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            if (operationMode != OperationMode.Exit || m_MonoBehaviour == null)
                return;

            PlayParticle(particlesOnEachTime[0], playPositionOffsetOnEachTime[0]);
        }

        protected override void OnLinkedStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            if (operationMode != OperationMode.Update || m_MonoBehaviour == null)
                return;

            _timer += Time.deltaTime * stateInfo.speed;

            if (_counter < executeTimesForUpdateMode.Length && _timer > executeTimesForUpdateMode[_counter])
            {
                PlayParticle(particlesOnEachTime[_counter], playPositionOffsetOnEachTime[_counter]);
                _counter++;
            }

            if (_timer < stateInfo.length)
                return;

            // TODO
            // execute Last update frame - for set bool or something
            // animator.SetBool("", false);
        }

        private void PlayParticle(string particleId, Vector3 positionOffset)
        {
            if (BattleManager.main == null)
                return;

            // Adjust Scale and flip position
            bool isFlip = m_MonoBehaviour.transform.localScale.x < 0;
            positionOffset.x *= isFlip ? -1f : 1f;

            BattleManager.main.battleParticleManager.ShowParticle(
                particleId, 
                m_MonoBehaviour.transform.position + positionOffset,
                isFlip);
        }
    }
}
