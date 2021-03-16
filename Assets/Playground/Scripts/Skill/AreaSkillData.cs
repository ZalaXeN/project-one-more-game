using System.Collections;
using UnityEngine;

namespace ProjectOneMore
{
    [CreateAssetMenu(fileName = "SkillData", menuName = "Data/Skill/Area", order = 0)]
    public class AreaSkillData : SkillData
    {
        public float targetRange;
        public Vector3 offset;
        public Vector2 sizeDelta;
    }
}