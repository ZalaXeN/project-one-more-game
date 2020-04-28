using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
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

        private BattleState _battleState;
        public BattleState battleState
        {
            private set {
                _battleState = value;
                Debug.LogFormat("Battle State: {0}", _battleState);
            }
            get { return _battleState; }
        }

        public BattleColumn[] battleColumns;

        // Test
        [Range(0,32)]
        public int testEnemyNumber;
        public GameObject testEnemyPrefab;
        [Range(1, 10)]
        public int rowsPerColumn = 4;

        private WaitForSeconds _waitForSpawnEnemyInterval = new WaitForSeconds(0.3f);

        private BattlePlayerActionCard _currentActionCard;

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

            StartCoroutine("ReadyBattleCoroutine");
        }

        private IEnumerator ReadyBattleCoroutine()
        {
            Coroutine spawnEnemy = StartCoroutine("SpawnEnemy");
            yield return spawnEnemy;
            battleState = BattleState.Battle;
        }

        private IEnumerator SpawnEnemy()
        {
            // Test
            if (testEnemyPrefab == null)
                yield break;

            for(int i = 0; i < testEnemyNumber; i++)
            {
                int column = i / rowsPerColumn;
                int row = i % rowsPerColumn;

                battleColumns[column].unitNumber = row + 1;
                battleColumns[column].UpdateRows();

                GameObject enemy = Instantiate(testEnemyPrefab);
                enemy.GetComponent<BattleUnit>().column = column;
                enemy.GetComponent<BattleUnit>().row = row;
                enemy.GetComponent<BattleUnit>().isMovingToTarget = true;
                yield return _waitForSpawnEnemyInterval;
            }
        }

        public void EnterPlayerInput(BattlePlayerActionCard action)
        {
            if (battleState != BattleState.Battle)
                return;

            _currentActionCard = action;
            battleState = BattleState.PlayerInput;

            if(_currentActionCard.skillType != SkillType.Instant ||
               _currentActionCard.skillType != SkillType.Passive)
                ShowTargeting();
        }

        private void ShowTargeting()
        {
            // TODO
        }

        private bool CanCurrentActionTargetAlly()
        {
            if (_currentActionCard.skillEffectTarget == SkillEffectTarget.Ally ||
                _currentActionCard.skillEffectTarget == SkillEffectTarget.Allies ||
                _currentActionCard.skillEffectTarget == SkillEffectTarget.All)
                return true;

            return false;
        }

        private bool CanCurrentActionTargetEnemy()
        {
            if (_currentActionCard.skillEffectTarget == SkillEffectTarget.Enemy ||
                _currentActionCard.skillEffectTarget == SkillEffectTarget.Enemies ||
                _currentActionCard.skillEffectTarget == SkillEffectTarget.All)
                return true;

            return false;
        }

        public bool CanCurrentActionTarget(BattleUnit unit)
        {
            if (CanCurrentActionTargetAlly() && unit.team == _currentActionCard.owner.team)
                return true;

            if (CanCurrentActionTargetEnemy() && unit.team != _currentActionCard.owner.team)
                return true;

            return false;
        }

        public void SetCurrentActionTarget(BattleUnit unit)
        {
            _currentActionCard.SetTarget(unit);
        }

        public void CurrentActionTakeAction()
        {
            _currentActionCard.Execute();
            ExitPlayerInput();
        }

        public void ExitPlayerInput()
        {
            if(battleState != BattleState.PlayerInput)
                return;

            battleState = BattleState.Battle;
        }

        public Vector3 GetBattlePosition(int column, int row)
        {
            if (battleColumns.Length <= 0)
                return Vector3.zero;

            column = math.clamp(column, 0, battleColumns.Length - 1);

            return battleColumns[column].GetRowPosition(row);
        }
    }
}
