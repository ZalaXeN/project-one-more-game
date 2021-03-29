using System.Collections;
using UnityEngine;

namespace ProjectOneMore
{
    public class RandomizerSMB : StateMachineBehaviour
    {
        public int maxRandom = 1;

        // Parameters
        public static readonly int m_HashRandATK = Animator.StringToHash("rand_atk");

        public override void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            int rand = Random.Range(0, maxRandom + 1);
            animator.SetInteger(m_HashRandATK, rand);
        }
    }
}