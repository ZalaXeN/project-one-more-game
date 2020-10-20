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

        //-- Delegate
        public delegate void UnitDeadDelegate(BattleUnit unit);

        //-- Event
        public event UnitDeadDelegate UnitDeadEvent;

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
        public BattleFieldManager fieldManager;
        public BattleLevelManager levelManager;

        [Header("Settings.")]
        public BattleDamageNumberPool battleDamageNumberPool;
        public BattleParticleManager battleParticleManager;
        public BattleCameraManager battleCameraManager;
        public BattleProjectileManager battleProjectileManager;

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
        [SerializeField] private List<BattleUnit> _battleUnitList = new List<BattleUnit>();

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
            LoadLevel();
            ReadyBattle();
        }

        private void Update()
        {
            UpdateSpawnTimer();

            UpdateTimeScale();

            UpdateBattlePosition();
        }

        #region Ready Phase

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

            bool spawnSuccess = SpawnMinion(minionPrefab, team);
            if(spawnSuccess) { UpdateBattlePosition(); }

            return spawnSuccess;
        }

        #endregion

        #region Field

        public void AddUnitIfNeed(BattleUnit unit)
        {
            if (_battleUnitList.Contains(unit))
                return;

            _battleUnitList.Add(unit);
        }

        private void UpdateBattlePosition()
        {
            fieldManager.UpdateBattlePosition(_battleUnitList);
        }

        private bool SpawnMinion(GameObject minionPrefab, BattleTeam team)
        {
            GameObject minionGO = Instantiate(minionPrefab);
            minionGO.transform.position = fieldManager.GetSpawnPosition(team);
            BattleUnit minionUnit = minionGO.GetComponent<BattleUnit>();

            minionUnit.team = team;

            Vector3 scale = minionUnit.transform.localScale;
            scale.x = minionUnit.team == BattleTeam.Enemy ? scale.x : -scale.x;
            minionUnit.transform.localScale = scale;

            _battleUnitList.Add(minionUnit);
            return true;
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

        public void ShowDamageNumber(int damage, Vector3 position)
        {
            battleDamageNumberPool.ShowDamageNumber(damage, position);
        }

        #endregion

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
            Debug.Log("Targeting");

            // TODO
            // Make Targeting for all type of action
            _currentActionCard.ShowTargeting();
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
            HideOutlineFXColor();
            battleState = BattleState.Battle;
        }
        #endregion

        #region Event Trigger
        public void TriggerUnitDead(BattleUnit unit)
        {
            _battleUnitList.Remove(unit);
            UnitDeadEvent?.Invoke(unit);
        }
        #endregion

        public BattleUnit GetNearestAttackTarget(BattleUnit unit, bool shouldAlive = true)
        {
            BattleUnit target = null;
            Vector3 unitPos;
            foreach (BattleUnit u in _battleUnitList)
            {
                if (u && !u.IsAlive() && shouldAlive)
                    continue;

                if (u && u.team != unit.team)
                {
                    unitPos = u.transform.position;
                    unitPos.y = fieldManager.battleFieldArea.transform.position.y;

                    if (!fieldManager.battleFieldArea.bounds.Contains(unitPos))
                        continue;

                    if (target == null)
                        target = u;
                    else if (
                        Vector3.Distance(unit.transform.position, u.transform.position) <
                        Vector3.Distance(unit.transform.position, target.transform.position))
                        target = u;
                }
            }

            return target;
        }

        #region Time Manage
        // Slow Time
        public void SetTimeScaleForTest(float target)
        {
            _targetTimeScale = target;
        }

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
                if (_targetTimeScale == 0)
                {
                    Time.timeScale = 0;
                }
                else if (_targetTimeScale < Time.timeScale)
                {
                    Time.timeScale -= (1f / slowingLength) * Time.unscaledDeltaTime;
                    Time.timeScale = math.clamp(Time.timeScale, _targetTimeScale, 10f);
                }
                else
                {
                    Time.timeScale += (1f / slowingLength) * Time.unscaledDeltaTime;
                    Time.timeScale = math.clamp(Time.timeScale, 0f, _targetTimeScale);
                }
            }

            if(_targetTimeScale != 1.0f)
            {
                Time.timeScale = math.clamp(Time.timeScale, 0f, 10f);
                Time.fixedDeltaTime = Time.timeScale * 0.02f;
            }
        }
        //--------------

        #endregion

        #region Sprite Outline
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
        #endregion
    }
}
