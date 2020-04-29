using System.Collections;
using System.Collections.Generic;
using System.Linq;
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

        //-- Delegate
        public delegate void UnitDeadDelegate(BattleUnit unit);
        public delegate void ColumnUpdatedDelegate(BattleColumn column);

        //-- Event
        public event UnitDeadDelegate UnitDeadEvent;
        public event ColumnUpdatedDelegate ColumnUpdateEvent;

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

        private WaitForSeconds _waitForSpawnEnemyInterval = new WaitForSeconds(0.1f);

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
            InitBattleColumns();
            ReadyBattle();
        }

        private void InitBattleColumns()
        {
            foreach(BattleColumn column in battleColumns)
            {
                column.Initialize();
            }
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

        // Test Spawn
        private IEnumerator SpawnEnemy()
        {
            if (testEnemyPrefab == null)
                yield break;

            for(int i = 0; i < testEnemyNumber; i++)
            {
                int column = i / rowsPerColumn;
                int row = i % rowsPerColumn;

                battleColumns[column].unitNumber = row + 1;
                battleColumns[column].UpdateRows();   
            }
            for (int i = 0; i < testEnemyNumber; i++)
            {
                int column = i / rowsPerColumn;
                int row = i % rowsPerColumn;

                GameObject enemy = Instantiate(testEnemyPrefab);
                enemy.transform.position = GetSpawnPosition();
                BattleUnit enemyUnit = enemy.GetComponent<BattleUnit>();
                enemyUnit.column = column;
                enemyUnit.columnIndex = row;
                enemyUnit.columnDepth = GetBattleColumnDepth(column, row);
                enemyUnit.isMovingToTarget = true;
                enemyUnit.team = BattleTeam.Enemy;
                yield return _waitForSpawnEnemyInterval;
            }
        }

        private Vector3 GetSpawnPosition()
        {
            Vector3 result = battleColumns[battleColumns.Length - 1].transform.position;
            result.x += UnityEngine.Random.Range(3f, 4f);
            result.z += UnityEngine.Random.Range(-1f, 2f);
            return result;
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


        public Vector3 GetBattlePosition(int column, float columnDepth)
        {
            if (battleColumns.Length <= 0)
                return Vector3.zero;

            column = math.clamp(column, 0, battleColumns.Length - 1);

            return battleColumns[column].GetRowPosition(columnDepth);
        }

        public float GetBattleColumnDepth(int column, int columnIndex)
        {
            if (battleColumns.Length <= 0)
                return 0.5f;

            column = math.clamp(column, 0, battleColumns.Length - 1);

            return battleColumns[column].GetColumnDepth(columnIndex);
        }

        public float GetNearestBattleColumnDepth(int column, float columnDepth)
        {
            if (battleColumns.Length <= 0)
                return columnDepth;

            column = math.clamp(column, 0, battleColumns.Length - 1);

            return battleColumns[column].GetNearestColumnDepth(columnDepth);
        }

        public int GetColumnIndex(int column, float columnDepth)
        {
            if (battleColumns.Length <= 0)
                return 0;

            column = math.clamp(column, 0, battleColumns.Length - 1);

            return battleColumns[column].GetColumnIndex(columnDepth);
        }

        public void TriggerUnitDead(BattleUnit unit)
        {
            UnitDeadEvent?.Invoke(unit);
        }

        public void TriggerColumnUpdatedEvent(BattleColumn column)
        {
            ColumnUpdateEvent?.Invoke(column);
        }
    }
}
