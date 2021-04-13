using UnityEngine;
using UnityEngine.Rendering;

namespace ProjectOneMore
{
    [ExecuteInEditMode()]
    [RequireComponent(typeof(SortingGroup))]
    [DisallowMultipleComponent]
    public class SpriteSortingGroupHelper : MonoBehaviour
    {
        private const int SORTING_BASE = 100;
        //private const float UPDATE_TIME = 0.1f;

        //private float _updateTimer = 0f;
        private SortingGroup _sortingGroup;

        public Transform target;

        [Tooltip("Use this to offset the object slightly in front or behind the Target object")]
        public int targetOffset = 0;

        private void Reset()
        {
            UpdateTargetWithParent();
            UpdateOffsetWithSortingOrder();
        }

        void LateUpdate()
        {
            UpdateSortingOrder();
        }

        void UpdateTargetWithParent()
        {
            target = transform.root;
        }

        void UpdateOffsetWithSortingOrder()
        {
            if (_sortingGroup == null)
                _sortingGroup = GetComponent<SortingGroup>();

            targetOffset = _sortingGroup.sortingOrder;
        }

        void UpdateSortingOrder()
        {
            //_updateTimer -= Time.deltaTime;
            //if (_updateTimer > 0f)
            //    return;

            //_updateTimer = UPDATE_TIME;

            if (target == null)
                target = transform;

            if (_sortingGroup == null)
                _sortingGroup = GetComponent<SortingGroup>();

            _sortingGroup.sortingOrder = -(int)(target.position.z * SORTING_BASE) + targetOffset;
        }
    }
}