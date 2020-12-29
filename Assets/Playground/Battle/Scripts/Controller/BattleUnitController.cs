using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;

namespace ProjectOneMore.Battle
{
    [RequireComponent(typeof(BattleUnit), typeof(PlayerInput))]
    public class BattleUnitController : MonoBehaviour
    {
        private PlayerInput _playerInput;

        private BattleUnit _battleUnit;

        private Vector2 m_MoveInput;

        private void OnEnable()
        {
            _playerInput = GetComponent<PlayerInput>();
            _battleUnit = GetComponent<BattleUnit>();

            if (_battleUnit)
                _battleUnit.SetController(this);
        }

        private void OnDisable()
        {
            if (_battleUnit)
                _battleUnit.RemoveController();
        }

        private void Start()
        {
            BattleManager.main?.SetupFocusUnitController(this);
        }

        private void Update()
        {
            SetInputActiveState(BattleManager.main.IsPaused());

            Move(m_MoveInput);
        }

        public PlayerInput GetPlayerInput()
        {
            return _playerInput;
        }

        public void SetInputActiveState(bool gameIsPaused)
        {
            switch (gameIsPaused)
            {
                case true:
                    _playerInput.DeactivateInput();
                    break;

                case false:
                    _playerInput.ActivateInput();
                    break;
            }
        }

        public void InputMove(InputAction.CallbackContext context)
        {
            m_MoveInput = context.ReadValue<Vector2>();
        }

        public bool HasMoveInput()
        {
            return m_MoveInput.sqrMagnitude >= 0.01;
        }

        private void Move(Vector2 moveDirection)
        {
            if (!_battleUnit || moveDirection.sqrMagnitude < 0.01 || !_battleUnit.InBattlefield())
                return;

            var direction = new Vector3(moveDirection.x, 0, moveDirection.y);
            _battleUnit.Move(_battleUnit.transform.position + direction);
        }

        public void InputAttack(InputAction.CallbackContext context)
        {
            if (context.performed)
            {
                BattleManager.main.SetNormalAction(_battleUnit.normalActionCard);
            }
        }
    }
}