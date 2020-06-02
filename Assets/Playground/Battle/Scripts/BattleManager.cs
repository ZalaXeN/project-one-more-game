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

        public float spawnTimer
        {
            private set { }
            get { return levelManager.spawnTimer; }
        }

        private float _battleTime;
        public float battleTime
        {
            private set { _battleTime = value; }
            get { return _battleTime; }
        }

        [Header("Data Settings.")]
        public MinionPrefabController minionPrefabController;

        [Header("Manager Settings.")]
        public BattleColumnManager columnManager;
        public BattleLevelManager levelManager;

        [Header("Settings.")]
        // Test
        public string testLevelId;
        [Range(0, 32)]
        public int testEnemyMeleeNumber;
        [Range(0, 32)]
        public int testEnemyRangeNumber;
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
            LoadLevel();
            ReadyBattle();
        }

        private void Update()
        {
            UpdateSpawnTimer();
        }

        #region Ready Phase
        private void InitBattleColumns()
        {
            columnManager.Initizialize();
        }

        private void LoadLevel()
        {
            levelManager.LoadLevel(testLevelId);
        }

        private void ReadyBattle()
        {
            battleState = BattleState.Ready;
            InitSpawnTimer();
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
            if (minionPrefabController == null)
                yield break;

            BattleTeam team = BattleTeam.Enemy;
            UpdateBattleColumns(team, false);

            for (int i = 0, j = 0; 
                j < testEnemyMeleeNumber + testEnemyRangeNumber;
                i++, j++)
            {
                string unitPrefabId = "m01";
                if (j < testEnemyMeleeNumber)
                    unitPrefabId = "m01";
                else if(j < testEnemyMeleeNumber + testEnemyRangeNumber)
                    unitPrefabId = "r01";

                if(SpawnMinion(unitPrefabId, BattleTeam.Enemy))
                {
                    yield return _waitForSpawnEnemyInterval;
                }
                else
                {
                    i--;
                }
            }
        }

        public bool SpawnMinion(string unitPrefabId, BattleTeam team)
        {
            GameObject minionPrefab = minionPrefabController.GetMinionPrefab(unitPrefabId);
            if (minionPrefab == null)
                return false;

            BattleUnit minion = minionPrefab.GetComponent<BattleUnit>();
            return SpawnMinion(minionPrefab, minion, team);
        }

        public bool SpawnMinion(GameObject minionPrefab, BattleUnit unit, BattleTeam team)
        {
            if (minionPrefab == null)
                return false;

            if(columnManager.HasEmptySlotOnZone(team, unit.attackType, out BattleColumn targetColumn))
            {
                columnManager.RepositionUnitToEmptySlot(team, unit.attackType, targetColumn);
            }
            else
            {
                // Can't Spawn
                return false;
            }

            // Get Empty after reposition again
            if (columnManager.HasEmptySlotOnZone(team, unit.attackType, out targetColumn))
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
                minionUnit.DebugShowAttackTypeOutline();

                Vector3 scale = minionUnit.transform.localScale;
                scale.x = minionUnit.team == BattleTeam.Enemy ? scale.x: -scale.x;
                minionUnit.transform.localScale = scale;

                return true;
            }

            return false;
        }
        #endregion

        #region Battle Phase

        private void InitSpawnTimer()
        {
            levelManager.spawnTimer = 0f;
            battleTime = 0f;
        }

        private void UpdateSpawnTimer()
        {
            if (battleState != BattleState.Battle && 
                battleState != BattleState.PlayerInput)
                return;

            battleTime += Time.deltaTime;
            levelManager.UpdateSpawnTime(Time.deltaTime);
        }

        #endregion

        private void UpdateBattleColumns(BattleTeam team, bool triggerEvent = true)
        {
            columnManager.UpdateBattleColumns(team, triggerEvent);
        }

        #region Input Phase
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
        #endregion

        #region Event Trigger
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
        #endregion
    }
}
