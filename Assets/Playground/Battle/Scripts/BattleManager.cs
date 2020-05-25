using System.Collections;
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
                //Debug.LogFormat("Battle State: {0}", _battleState);
            }
            get { return _battleState; }
        }

        public BattleColumnManager columnManager;

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
            columnManager.Initizialize();
        }

        private void ReadyBattle()
        {
            battleState = BattleState.Ready;

            StartCoroutine(ReadyBattleCoroutine());
        }

        private IEnumerator ReadyBattleCoroutine()
        {
            Coroutine spawnEnemy = StartCoroutine(SpawnStartedEnemy());
            yield return spawnEnemy;
            battleState = BattleState.Battle;
        }

        // Test Spawn
        private IEnumerator SpawnStartedEnemy()
        {
            if (testEnemyPrefab == null)
                yield break;

            BattleTeam team = BattleTeam.Enemy;
            UpdateBattleColumns(team, false);

            for (int i = 0, j = 0; 
                j < testEnemyMeleeNumber + testEnemyRangeNumber;
                i++, j++)
            {
                BattleUnitAttackType unitAttackType = BattleUnitAttackType.Melee;
                if (j < testEnemyMeleeNumber)
                    unitAttackType = BattleUnitAttackType.Melee;
                else if(j < testEnemyMeleeNumber + testEnemyRangeNumber)
                    unitAttackType = BattleUnitAttackType.Range;

                if(columnManager.HasEmptySlotOnZone(team, unitAttackType))
                {
                    SpawnMinion(testEnemyPrefab, unitAttackType, BattleTeam.Enemy);
                    yield return _waitForSpawnEnemyInterval;
                }
                else
                {
                    i--;
                }
            }
        }

        public void SpawnMinion(GameObject minionPrefab, BattleUnitAttackType unitAttackType, BattleTeam team)
        {
            if(columnManager.HasEmptySlotOnZone(team, unitAttackType, out BattleColumn targetColumn))
            {
                columnManager.RepositionUnitToEmptySlot(team, unitAttackType, targetColumn);
            }
            else
            {
                // Can't Spawn
                return;
            }

            // Get Empty after reposition again
            if (columnManager.HasEmptySlotOnZone(team, unitAttackType, out targetColumn))
            {
                GameObject minionGO = Instantiate(minionPrefab);
                minionGO.transform.position = columnManager.GetSpawnPosition(team);
                BattleUnit minionUnit = minionGO.GetComponent<BattleUnit>();

                targetColumn.AssignUnit(minionUnit);
                targetColumn.UpdateRows();

                minionUnit.column = targetColumn.columnNumber;
                minionUnit.columnDepth = targetColumn.GetEmptyCenteredFirstColumnDepth(minionUnit);
                minionUnit.columnIndex = targetColumn.GetColumnIndex(minionUnit.columnDepth);
                minionUnit.isMovingToTarget = true;
                minionUnit.team = team;
                minionUnit.SetAttackType(unitAttackType);

                Vector3 scale = minionUnit.transform.localScale;
                scale.x = minionUnit.team == BattleTeam.Enemy ? scale.x: -scale.x;
                minionUnit.transform.localScale = scale;
            }
        }

        private void UpdateBattleColumns(BattleTeam team, bool triggerEvent = true)
        {
            columnManager.UpdateBattleColumns(team, triggerEvent);
        }

        public void EnterPlayerInput(BattlePlayerActionCard action)
        {
            if (battleState != BattleState.Battle)
                return;

            _currentActionCard = action;
            battleState = BattleState.PlayerInput;

            if(_currentActionCard.skillType != SkillType.Instant &&
               _currentActionCard.skillType != SkillType.Passive)
                ShowTargeting();
            else
            {
                CurrentActionTakeAction();
            }
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

        public void TriggerUnitDead(BattleUnit unit)
        {
            UnitDeadEvent?.Invoke(unit);

            //columnManager.RepositionUnitToEmptySlot(unit.team, unit.attackType, 
            //    columnManager.GetBattleColumn(unit.team, unit.columnIndex), true);
        }

        public void TriggerColumnUpdatedEvent(BattleColumn column)
        {
            ColumnUpdateEvent?.Invoke(column);
        }
    }
}
