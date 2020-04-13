using System.Collections;
using UnityEngine;
using Unity.Entities;
using Unity.Transforms;
using Unity.Mathematics;

namespace ProjectOneMore.Battle
{
    public enum BattleState
    {
        Init,
        Ready,
        Battle,
        PlayerInput,
        Event,
        Pause,
        End,
        Result
    }

    public class BattleManager : MonoBehaviour
    {
        public static BattleManager main;

        public GameObject enemyPrefab;

        private BattleState _battleState;
        public BattleState battleState
        {
            private set { _battleState = value; }
            get { return _battleState; }
        }

        public BattleUnit selectedUnit;
        public BattlePlayerActionCard currentAction;

        private void Awake()
        {
            // Singleton
            if (main != null && main != this)
            {
                Destroy(gameObject);
                return;
            }
            main = this;

            battleState = BattleState.Init;
        }

        private void Start()
        {
            ReadyBattle();
        }

        private void ReadyBattle()
        {
            battleState = BattleState.Ready;
            // Ready Battle Event Coroutine
            // StartCouroutine
            SpawnEnemy();

            battleState = BattleState.Battle;
        }

        private void SpawnEnemy()
        {
            // TODO
        }

        public void EnterPlayerInput(BattlePlayerActionCard action)
        {
            if (battleState != BattleState.Battle)
                return;

            currentAction = action;
            battleState = BattleState.PlayerInput;
        }

        public void ExitPlayerInput()
        {
            if(battleState != BattleState.PlayerInput)
                return;

            battleState = BattleState.Battle;
        }

        private void Update()
        {
            PlayerInputPhase();
        }

        private void PlayerInputPhase()
        {
            if (battleState != BattleState.PlayerInput)
                return;

            //currentAction.Target();
        }
    }
}
