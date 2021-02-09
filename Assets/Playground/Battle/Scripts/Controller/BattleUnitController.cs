using System.Collections;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;

namespace ProjectOneMore.Battle
{
    [RequireComponent(typeof(BattleUnit), typeof(PlayerInput))]
    public class BattleUnitController : MonoBehaviour
    {
        private PlayerInput _playerInput;

        private BattleUnit _battleUnit;

        private Vector2 _moveInput;

        private void OnEnable()
        {
            _playerInput = GetComponent<PlayerInput>();
            _battleUnit = GetComponent<BattleUnit>();

            if (_battleUnit)
            {
                _battleUnit.SetController(this);
            }
        }

        private void OnDisable()
        {
            if (_battleUnit)
            {
                _battleUnit.RemoveController();

                BattleManager.main.ChangeBattleStateEvent -= AddNormalActionOnBattleState;
            }
        }

        private void Start()
        {
            BattleManager.main?.SetupFocusUnitController(this);

            BattleManager.main.ChangeBattleStateEvent += AddNormalActionOnBattleState;
            BattleManager.main.SetNormalActionCard(_battleUnit.normalActionCard);
        }

        private void Update()
        {
            SetInputActiveState(BattleManager.main.IsPaused());

            Move(_moveInput);
        }

        private void AddNormalActionOnBattleState(BattleState battleState)
        {
            if (battleState != BattleState.Battle || _battleUnit == null || _battleUnit.normalActionCard == null)
                return;

            BattleManager.main.SetNormalActionCard(_battleUnit.normalActionCard);
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
            _moveInput = context.ReadValue<Vector2>();
        }

        public bool HasMoveInput()
        {
            return _moveInput.sqrMagnitude >= 0.01;
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
                BattleManager.main.InputAttack(_battleUnit.normalActionCard);
            }
        }

        public void ToggleActionCardSelector(InputAction.CallbackContext context)
        {
            if (context.performed)
            {
                BattleManager.main.isOnActionSelector = !BattleManager.main.isOnActionSelector;
            }
        }
    }
}