using UnityEngine;
using UnityEngine.InputSystem;

namespace ProjectOneMore.Battle
{
    [RequireComponent(typeof(PlayerInput))]
    public class BattleController : MonoBehaviour
    {
        private PlayerInput _playerInput;

        private Vector2 _moveInput;

        private void OnEnable()
        {
            _playerInput = GetComponent<PlayerInput>();
        }

        private void Start()
        {
            BattleManager.main?.SetupFocusUnitController(this);
        }

        private void Update()
        {
            SetInputActiveState(BattleManager.main.IsPaused());
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

        public void InputAttack(InputAction.CallbackContext context)
        {
            if (context.performed)
            {
                BattleManager.main.InputAttack();
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