﻿using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Rendering;

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
        public BattleDamageNumberPool battleDamageNumberPool;

        [Header("Test Settings.")]
        public string testLevelId;
        [Range(1, 10)]
        public int rowsPerColumn = 4;
        public Material outlineMaterial;
        public Material noAlphaMaterial;

        public Material outlineFXMaterial;
        public float outlineSampleDistance = 1f;
        public Color outlineColor = Color.red;

        [Range(0.1f, 0.5f)]
        public float slowTimeFactor = 0.2f;
        [Range(0.1f, 1f)]
        public float slowingLength = 0.3f;

        private BattleActionCard _currentActionCard;
        private List<BattleUnit> _battleUnitList = new List<BattleUnit>();

        private float _targetTimeScale = 1f;

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

            UpdateTimeScale();
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
            UpdateBattleColumns(BattleTeam.Enemy, false);
            Coroutine spawnEnemy = levelManager.SpawnStartMinion();
            yield return spawnEnemy;
            battleState = BattleState.Battle;
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

        #region Minion

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

            if (columnManager.HasEmptySlotOnZone(team, unit.attackType, out BattleColumn targetColumn))
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
                scale.x = minionUnit.team == BattleTeam.Enemy ? scale.x : -scale.x;
                minionUnit.transform.localScale = scale;

                _battleUnitList.Add(minionUnit);

                return true;
            }

            return false;
        }

        #endregion

        #region Battle Utility

        public float GetAutoAttackCooldown(int spd)
        {
            return Mathf.Max(5 - (spd / 100f), GameConfig.BATTLE_HIGHEST_AUTO_ATTACK_SPEED);
        }

        public BattleTeam GetOppositeTeam(BattleTeam team)
        {
            return team == BattleTeam.Player ? BattleTeam.Enemy : BattleTeam.Player;
        }

        public BattleUnit GetFrontmostUnit(BattleTeam team, BattleUnitAttackType attackType, bool shouldAlive = true)
        {
            BattleUnit target = null;
            foreach(BattleUnit unit in _battleUnitList)
            {
                if (unit.team != team || unit.isMovingToTarget)
                    continue;

                if (shouldAlive && !unit.IsAlive())
                    continue;

                if (target == null)
                    target = unit;
                else
                {
                    if (target.column > unit.column)
                        target = unit;
                    else if (target.column == unit.column && target.columnIndex > unit.columnIndex)
                        target = unit;
                }
            }

            return target;
        }

        public void ShowDamageNumber(int damage, Vector3 position)
        {
            battleDamageNumberPool.ShowDamageNumber(damage, position);
        }

        #endregion

        private void UpdateBattleColumns(BattleTeam team, bool triggerEvent = true)
        {
            columnManager.UpdateBattleColumns(team, triggerEvent);
        }

        #region Input Phase
        public void EnterPlayerInput(BattleActionCard action)
        {
            if (battleState != BattleState.Battle)
                return;

            _currentActionCard = action;
            battleState = BattleState.PlayerInput;
            DoSlowtime();

            if (_currentActionCard.skillType != SkillType.Instant &&
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
            if (_currentActionCard == null)
                return false;

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
            if(_currentActionCard != null)
                _currentActionCard.Execute();

            ExitPlayerInput();
        }

        public void ExitPlayerInput()
        {
            if(battleState != BattleState.PlayerInput)
                return;

            ResetTime();

            battleState = BattleState.Battle;
        }
        #endregion

        #region Event Trigger
        public void TriggerUnitDead(BattleUnit unit)
        {
            _battleUnitList.Remove(unit);
            UnitDeadEvent?.Invoke(unit);

            //columnManager.RepositionUnitToEmptySlot(unit.team, unit.attackType, 
            //    columnManager.GetBattleColumn(unit.team, unit.columnIndex), true);
        }

        public void TriggerColumnUpdatedEvent(BattleColumn column)
        {
            ColumnUpdateEvent?.Invoke(column);
        }
        #endregion

        // Slow Time
        private void DoSlowtime()
        {
            _targetTimeScale = slowTimeFactor;
        }

        private void ResetTime()
        {
            _targetTimeScale = 1f;
        }

        private void UpdateTimeScale()
        {
            if(Time.timeScale != _targetTimeScale && _targetTimeScale >= 0f)
            {
                if (_targetTimeScale < Time.timeScale)
                {
                    Time.timeScale -= (1f / slowingLength) * Time.unscaledDeltaTime;
                    Time.timeScale = math.clamp(Time.timeScale, _targetTimeScale, 1f);
                }
                else
                {
                    Time.timeScale += (1f / slowingLength) * Time.unscaledDeltaTime;
                    Time.timeScale = math.clamp(Time.timeScale, 0f, _targetTimeScale);
                }
            }

            if(_targetTimeScale != 1.0f)
            {
                Time.timeScale = math.clamp(Time.timeScale, 0f, 1f);
                Time.fixedDeltaTime = Time.timeScale * 0.02f;
            }
        }
        //--------------

        // Test Outline
        public void SetOutlineFXColor()
        {
            outlineFXMaterial.SetFloat("_Distance", outlineSampleDistance);
            outlineFXMaterial.SetColor("_Color", outlineColor);
        }

        public void HideOutlineFXColor()
        {
            outlineFXMaterial.SetFloat("_Distance", 0);
            outlineFXMaterial.SetColor("_Color", Color.clear);
        }
    }
}
