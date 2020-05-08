﻿using System.Collections;
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
        [Range(0, 32)]
        public int testEnemyMeleeNumber;
        [Range(0, 32)]
        public int testEnemyRangeNumber;
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
            Coroutine spawnEnemy = StartCoroutine("SpawnStartedEnemy");
            yield return spawnEnemy;
            battleState = BattleState.Battle;
        }

        // Test Spawn
        private IEnumerator SpawnStartedEnemy()
        {
            if (testEnemyPrefab == null)
                yield break;

            UpdateBattleColumns(false);

            for (int i = 0, j = 0; 
                j < testEnemyMeleeNumber + testEnemyRangeNumber;
                i++, j++)
            {
                BattleUnitAttackType unitAttackType = BattleUnitAttackType.Melee;
                if (j < testEnemyMeleeNumber)
                    unitAttackType = BattleUnitAttackType.Melee;
                else if(j < testEnemyMeleeNumber + testEnemyRangeNumber)
                    unitAttackType = BattleUnitAttackType.Range;

                BattleColumn targetColumn;
                if(HasEmptySlotOnZone(unitAttackType, out targetColumn))
                {
                    if(unitAttackType == targetColumn.zone)
                        SpawnEnemy(unitAttackType);
                    else
                    {
                        RepositionUnitToEmptySlot(unitAttackType, targetColumn);
                        SpawnEnemy(unitAttackType);
                    }

                    yield return _waitForSpawnEnemyInterval;
                }
                else
                {
                    i--;
                }
            }
        }

        private void SpawnEnemy(BattleUnitAttackType unitAttackType)
        {
            BattleColumn targetColumn;
            if (HasEmptySlotOnZone(unitAttackType, out targetColumn))
            {
                GameObject enemy = Instantiate(testEnemyPrefab);
                enemy.transform.position = GetSpawnPosition();
                BattleUnit enemyUnit = enemy.GetComponent<BattleUnit>();

                targetColumn.AssignUnit(enemyUnit);
                targetColumn.UpdateRows();

                enemyUnit.column = targetColumn.columnNumber;
                enemyUnit.columnDepth = targetColumn.GetEmptyCenteredFirstColumnDepth(enemyUnit);
                enemyUnit.columnIndex = targetColumn.GetColumnIndex(enemyUnit.columnDepth);
                enemyUnit.isMovingToTarget = true;
                enemyUnit.team = BattleTeam.Enemy;
                enemyUnit.SetAttackType(unitAttackType);
            }
        }

        private void RepositionUnitToEmptySlot(BattleUnitAttackType unitAttackType, BattleColumn targetColumn)
        {
            BattleColumn nextColumn = GetNextBattleColumn(unitAttackType, targetColumn.columnNumber);
            if (nextColumn == null)
                return;

            BattleUnit popUnit = nextColumn.PopUnit();
            targetColumn.AssignUnit(popUnit);
            targetColumn.UpdateRows();
            nextColumn.UpdateRows();

            popUnit.column = targetColumn.columnNumber;
            popUnit.columnDepth = targetColumn.GetEmptyCenteredFirstColumnDepth(popUnit);
            popUnit.columnIndex = targetColumn.GetColumnIndex(popUnit.columnDepth);
            popUnit.isMovingToTarget = true;

            if(targetColumn.GetUnitNumber() >= rowsPerColumn || targetColumn.zone != unitAttackType)
                RepositionUnitToEmptySlot(unitAttackType, nextColumn);
            else
                RepositionUnitToEmptySlot(unitAttackType, targetColumn);
        }

        private void UpdateBattleColumns(bool triggerEvent = true)
        {
            foreach (BattleColumn column in battleColumns)
            {
                column.UpdateRows(triggerEvent);
            }
        }

        private BattleColumn GetNextBattleColumn(BattleUnitAttackType unitAttackType, int columnNumber)
        {
            foreach (BattleColumn column in battleColumns)
            {
                if (column.columnNumber > columnNumber && column.HasUnit(unitAttackType))
                    return column;
            }
            return null;
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

        public int GetLastestColumnIndex(int column)
        {
            if (battleColumns.Length <= 0)
                return 0;

            column = math.clamp(column, 0, battleColumns.Length - 1);

            return battleColumns[column].GetUnitNumber();
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

        public float GetNearestBattleColumnDepth(int column, float columnDepth, BattleUnit unit)
        {
            if (battleColumns.Length <= 0)
                return columnDepth;

            column = math.clamp(column, 0, battleColumns.Length - 1);

            return battleColumns[column].GetNearestColumnDepth(columnDepth, unit);
        }

        public int GetColumnIndex(int column, float columnDepth)
        {
            if (battleColumns.Length <= 0)
                return 0;

            column = math.clamp(column, 0, battleColumns.Length - 1);

            return battleColumns[column].GetColumnIndex(columnDepth);
        }

        public BattleUnitAttackType GetColumnZoneType(int column)
        {
            if (battleColumns.Length <= 0)
                return BattleUnitAttackType.Melee;

            column = math.clamp(column, 0, battleColumns.Length - 1);
            return battleColumns[column].zone;
        }

        public bool HasEmptySlotOnZone(BattleUnitAttackType zone, out BattleColumn resultColumn)
        {
            resultColumn = null;
            BattleColumn emptyMeleeColumn = null;

            foreach(BattleColumn column in battleColumns)
            {
                if (column.GetUnitNumber() < rowsPerColumn)
                {
                    if (column.zone == zone)
                    {
                        resultColumn = column;
                        return true;
                    }
                    else if(column.zone == BattleUnitAttackType.Melee) 
                    {
                        emptyMeleeColumn = column;
                    }
                }
            }

            // Return lastest empty melee for Range Unit if no empty range zone
            if(zone == BattleUnitAttackType.Range && emptyMeleeColumn != null)
            {
                resultColumn = emptyMeleeColumn;
                return true;
            }

            return false;
        }

        public void TriggerUnitDead(BattleUnit unit)
        {
            UnitDeadEvent?.Invoke(unit);
            RepositionUnitToEmptySlot(unit.attackType, battleColumns[unit.column]);
        }

        public void TriggerColumnUpdatedEvent(BattleColumn column)
        {
            ColumnUpdateEvent?.Invoke(column);
        }
    }
}
