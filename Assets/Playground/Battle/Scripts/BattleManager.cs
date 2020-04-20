using System.Collections;
using System.Collections.Generic;
using UnityEngine;

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
            private set {
                _battleState = value;
                Debug.LogFormat("Battle State: {0}", _battleState);
            }
            get { return _battleState; }
        }

        public BattlePlayerActionCard currentActionCard;

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

            currentActionCard = action;
            battleState = BattleState.PlayerInput;

            if(currentActionCard.skillType != SkillType.Instant ||
               currentActionCard.skillType != SkillType.Passive)
                ShowTargeting();
        }

        private void ShowTargeting()
        {
            // TODO
        }

        private bool CanCurrentActionTargetAlly()
        {
            if (currentActionCard.skillEffectTarget == SkillEffectTarget.Ally ||
                currentActionCard.skillEffectTarget == SkillEffectTarget.Allies ||
                currentActionCard.skillEffectTarget == SkillEffectTarget.All)
                return true;

            return false;
        }

        private bool CanCurrentActionTargetEnemy()
        {
            if (currentActionCard.skillEffectTarget == SkillEffectTarget.Enemy ||
                currentActionCard.skillEffectTarget == SkillEffectTarget.Enemies ||
                currentActionCard.skillEffectTarget == SkillEffectTarget.All)
                return true;

            return false;
        }

        public bool CanCurrentActionTarget(BattleUnit unit)
        {
            if (CanCurrentActionTargetAlly() && unit.team == currentActionCard.owner.team)
                return true;

            if (CanCurrentActionTargetEnemy() && unit.team != currentActionCard.owner.team)
                return true;

            return false;
        }

        public void SetCurrentActionTarget(BattleUnit unit)
        {
            currentActionCard.SetTarget(unit);
        }

        // Mock Up
        public void CurrentActionTakeAction()
        {
            currentActionCard.Execute();
            ExitPlayerInput();
        }

        public void ExitPlayerInput()
        {
            if(battleState != BattleState.PlayerInput)
                return;

            battleState = BattleState.Battle;
        }
    }
}
