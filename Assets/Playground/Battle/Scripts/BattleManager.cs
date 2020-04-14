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
            private set {
                _battleState = value;
                Debug.LogFormat("Battle State: {0}", _battleState);
            }
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

            if(currentAction.skillType != SkillType.Instant ||
               currentAction.skillType != SkillType.Passive)
                ShowTargeting();
        }

        private void ShowTargeting()
        {
            // TODO
        }

        private bool CanCurrentActionTargetAlly()
        {
            if (currentAction.skillEffectTarget == SkillEffectTarget.Ally ||
                currentAction.skillEffectTarget == SkillEffectTarget.Allies ||
                currentAction.skillEffectTarget == SkillEffectTarget.All)
                return true;

            return false;
        }

        private bool CanCurrentActionTargetEnemy()
        {
            if (currentAction.skillEffectTarget == SkillEffectTarget.Enemy ||
                currentAction.skillEffectTarget == SkillEffectTarget.Enemies ||
                currentAction.skillEffectTarget == SkillEffectTarget.All)
                return true;

            return false;
        }

        public bool CanCurrentActionTarget(BattleUnit unit)
        {
            if (CanCurrentActionTargetAlly() && unit.team == currentAction.owner.team)
                return true;

            if (CanCurrentActionTargetEnemy() && unit.team != currentAction.owner.team)
                return true;

            return false;
        }

        public void SetCurrentActionTarget(BattleUnit unit)
        {
            currentAction.SetTarget(unit);
        }

        // Mock Up
        public void CurrentActionTakeAction()
        {
            if(currentAction.skillName == "Attack")
            {
                string ownerName = currentAction.owner.baseData.keeperName;
                string victimName = currentAction.GetTarget().baseData.keeperName;

                Debug.LogFormat("{0} Attack {1}", ownerName, victimName);
                //Debug.Log("Owner Animate Attack.");
                //Debug.Log("Target Animate Attacked.");
                Debug.LogFormat("{0} received {1} damage", victimName, currentAction.owner.pow.current);
                currentAction.GetTarget().hp.current -= currentAction.owner.pow.current;
                Debug.LogFormat("{0} has {1} HP", victimName, currentAction.GetTarget().hp.current);

                if (currentAction.GetTarget().hp.current <= 0)
                {
                    Debug.LogFormat("{0} are Dead.", victimName);
                    currentAction.GetTarget().Dead();
                }

                Debug.LogFormat("Dehighlight: {0}", victimName);
            }

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
