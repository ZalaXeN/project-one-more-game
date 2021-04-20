using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;

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
        public delegate void ChangeBattleStateDelegate(BattleState battleState);

        //-- Event
        public event ChangeBattleStateDelegate ChangeBattleStateEvent;

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

        [Space]
        [Header("Manager Settings.")]
        public BattleFieldManager fieldManager;
        public BattleLevelManager levelManager;

        [Space]
        [Header("Settings.")]
        public BattleDamageNumberPool battleDamageNumberPool;
        public BattleParticleManager battleParticleManager;
        public BattleCameraManager battleCameraManager;
        public BattleProjectileManager battleProjectileManager;
        public BattleActionIndicatorManager battleActionIndicatorManager;

        [Space]
        [Header("Raycaster Settings.")]
        public PhysicsRaycaster physicsRaycaster;
        public LayerMask playerInputLayerMask;
        public LayerMask normalEventLayerMask;
        public LayerMask groundLayerMask;

        [Space]
        [Header("Test Settings.")]
        public string testLevelId;
        [Range(1, 10)]
        public int rowsPerColumn = 4;

        [Range(0.1f, 0.5f)]
        public float slowTimeFactor = 0.1f;
        [Range(0.1f, 1f)]
        public float slowingLength = 0.3f;

        [SerializeField]
        private BattleActionCard _currentActionCard;
        private BattleActionCard _previousActionCard;
        [SerializeField] private List<BattleUnit> _battleUnitList = new List<BattleUnit>();

        private BattleState _previousBattleState;
        private float _beforePauseTimeScale;
        private float _previousTargetTimeScale;
        private float _targetTimeScale = 1f;

        private BattleController _controller;
        private BattleUnit _controlledUnit;

        [HideInInspector]
        public BattleActionTargetable selectedTarget;

        [HideInInspector]
        public bool isOnActionSelector;

        private Vector3 _lastGroundMousePos;
        private Bounds _castBounds;
        private Vector3 _castBoundsSize;

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

            UpdateData();
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
            SetPhysicsRaycasterEventLayer(battleState);
            StartCoroutine(ReadyBattleCoroutine());
        }

        private IEnumerator ReadyBattleCoroutine()
        {
            Coroutine spawnEnemy = levelManager.SpawnStartMinion();
            yield return spawnEnemy;
            battleState = BattleState.Battle;
            ChangeBattleStateEvent?.Invoke(battleState);
        }
        #endregion

        #region Battle Phase

        public bool CanUpdateTimer()
        {
            return
                battleState == BattleState.Battle ||
                battleState == BattleState.PlayerInput;
        }

        private void InitSpawnTimer()
        {
            levelManager.spawnTimer = 0f;
            battleTime = 0f;
        }

        private void UpdateSpawnTimer()
        {
            if (!CanUpdateTimer())
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

        public bool CheckUnitInBattleField(BattleUnit unit)
        {
            if (Vector3.Distance(fieldManager.battleFieldArea.bounds.ClosestPoint(unit.transform.position), unit.transform.position) < 0.02f)
                return true;

            return false;
        }

        public List<BattleUnit> GetBattleUnitList()
        {
            return _battleUnitList;
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

        public float GetMovespeedStep(int spd, float moveSpeedMultiplier)
        {
            //return spd * moveSpeedMultiplier * Time.deltaTime;
            return moveSpeedMultiplier * Time.deltaTime;
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

        public void InputAttack()
        {
            // Command
            if (_battleState == BattleState.PlayerInput)
            {
                if (_currentActionCard.baseData.skillTargetType == SkillTargetType.Area)
                {
                    SkillData skillData = _currentActionCard.baseData;
                    Vector3 castPoint = _currentActionCard.owner.transform.position + skillData.offset;

                    switch (skillData.targetAreaType)
                    {
                        case SkillData.AreaType.Box:
                            _currentActionCard.targetPosition = GetGroundMousePosition(castPoint, skillData.targetRange);
                            break;
                        case SkillData.AreaType.Circle:
                            _currentActionCard.targetPosition = GetGroundMousePosition(castPoint, skillData.targetRange.x / 2);
                            break;
                    }

                    _currentActionCard.SetTargetsWithActionArea();
                    CurrentActionTakeAction();
                }
            }

            if(_battleState == BattleState.Battle)
            {
                DeselectTarget();

                // Click on UI
                //if (EventSystem.current.IsPointerOverGameObject())
                //{
                //    return;
                //}
            }
        }

        public void EnterPlayerInput(BattleActionCard action)
        {
            if (battleState != BattleState.Battle)
                return;

            if (!action.canUseWithoutOwner && action.owner == null)
                return;

            _currentActionCard = action;
            _controlledUnit = _currentActionCard.owner;
            DeselectTarget();
            battleState = BattleState.PlayerInput;
            ChangeBattleStateEvent?.Invoke(battleState);

            if (_currentActionCard.baseData.skillType != SkillType.Instant &&
               _currentActionCard.baseData.skillType != SkillType.Passive)
                ShowTargeting();
            else
            {
                CurrentActionTakeAction();
            }
        }      

        private void ShowTargeting()
        {
            DoSlowtime();
            SetPhysicsRaycasterEventLayer(battleState);

            _currentActionCard.ShowTargeting();
        }

        public bool CanCurrentActionTarget(BattleActionTargetable target)
        {
            if (_currentActionCard == null)
                return false;

            if (!_currentActionCard.CheckTargetingTeam(target))
                return false;

            if (!_currentActionCard.CheckUnitInTargetRange(target))
                return false;

            if (!_currentActionCard.CheckTargetDamagable(target))
                return false;

            return true;
        }

        public bool IsCurrentActionHasTargetType(SkillTargetType skillTargetType)
        {
            if (_currentActionCard == null)
                return false;

            return _currentActionCard.baseData.skillTargetType == skillTargetType;
        }

        public void SetCurrentActionTarget(BattleActionTargetable target)
        {
            _currentActionCard.SetTarget(target);
        }

        public void SetCurrentActionTarget(Vector3 targetPosition)
        {
            _currentActionCard.targetPosition = targetPosition;
        }

        public void CurrentActionTakeAction(bool triggerTakeActionEvent = true)
        {
            if (_currentActionCard != null)
            {
                _previousActionCard = _currentActionCard;
                _previousActionCard.TakeAction();

                if (triggerTakeActionEvent)
                {
                    //Shuffle Action Card
                    //PlayerTakeActionEvent?.Invoke(_previousActionCard);
                }
            }

            if(triggerTakeActionEvent)
                _currentActionCard = null;

            ExitPlayerInput();
        }

        // Execute after Animation Take Action
        public void CurrentActionExecute()
        {
            if (_previousActionCard != null)
            {
                _previousActionCard.Execute();
            }

            _previousActionCard = null;
            UncontrolledUnit();
        }

        public void ExitPlayerInput()
        {
            if(battleState != BattleState.PlayerInput)
                return;

            ResetTime();
            battleState = BattleState.Battle;
            ChangeBattleStateEvent?.Invoke(battleState);

            SetPhysicsRaycasterEventLayer(battleState);

            battleActionIndicatorManager.HideAreaIndicator();
        }

        private void SetPhysicsRaycasterEventLayer(BattleState state)
        {
            if (state == BattleState.PlayerInput)
            {
                physicsRaycaster.eventMask = playerInputLayerMask;
            }
            else
            {
                physicsRaycaster.eventMask = normalEventLayerMask;
            }
        }

        public void SelectTarget(BattleActionTargetable target)
        {
            DeselectTarget();
            selectedTarget = target;
            selectedTarget.Highlight();
        }

        public void DeselectTarget()
        {
            if (!selectedTarget)
                return;

            selectedTarget.DeHighlight();
            selectedTarget = null;
        }

        #endregion

        #region Event Trigger
        public void TriggerUnitDead(BattleUnit unit)
        {
            _battleUnitList.Remove(unit);
        }
        #endregion

        public BattleUnit GetNearestAttackTarget(BattleUnit unit, bool shouldAlive = true, bool shouldInBattlefield = true)
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

                    if (shouldInBattlefield && !fieldManager.battleFieldArea.bounds.Contains(unitPos))
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

        public void PauseGame()
        {
            _beforePauseTimeScale = _targetTimeScale;
            _targetTimeScale = 0f;

            _previousBattleState = _battleState;
            _battleState = BattleState.Pause;
        }

        public void ResumeGame()
        {
            _targetTimeScale = _beforePauseTimeScale;

            _battleState = _previousBattleState;
        }

        public bool IsPaused()
        {
            return _targetTimeScale == 0f;
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

            if(Time.timeScale != _targetTimeScale)
            {
                Time.timeScale = math.clamp(Time.timeScale, 0f, 10f);
                Time.fixedDeltaTime = Time.timeScale * 0.02f;
            }

            if(Time.timeScale == _targetTimeScale && _targetTimeScale != _previousTargetTimeScale)
            {
                Time.fixedDeltaTime = Time.timeScale * 0.02f;
                _previousTargetTimeScale = _targetTimeScale;
            }
        }
        //--------------

        #endregion

        #region Input Systems

        public void SetupFocusUnitController(BattleController unitController)
        {
            _controller = unitController;
        }

        public BattleController GetFocusedController()
        {
            return _controller;
        }

        public BattleUnit GetCurrentControlledUnit()
        {
            return _controlledUnit;
        }

        public void UncontrolledUnit()
        {
            _controlledUnit = null;
        }
        
        public Vector3 GetGroundMousePosition()
        {
            Vector3 mousePos = Mouse.current.position.ReadValue();
            RaycastHit hit;
            Ray ray = Camera.main.ScreenPointToRay(mousePos);
            LayerMask mask = LayerMask.GetMask("Ground");

            if (Physics.Raycast(ray, out hit, Mathf.Infinity, mask))
            {
                _lastGroundMousePos = hit.point;
            }
            else if(_lastGroundMousePos == null)
            {
                mousePos.z = Camera.main.nearClipPlane - Camera.main.transform.position.z;
                mousePos.y = 0f;

                Vector3 pointPos = Camera.main.ScreenToWorldPoint(mousePos);
                pointPos.y = 0f;
                pointPos.z = transform.position.z;
                return pointPos;
            }

            return _lastGroundMousePos;
        }

        public Vector3 GetGroundMousePosition(Vector3 castPosition, Vector2 castRange)
        {
            GetGroundMousePosition();

            if (_castBounds == null)
                _castBounds = new Bounds();

            _castBounds.center = castPosition;
            _castBoundsSize.x = castRange.x;
            _castBoundsSize.z = castRange.y;
            _castBounds.size = _castBoundsSize;

            if (_castBounds.Contains(_lastGroundMousePos))
            {
                return _lastGroundMousePos;
            }
            else
            {
                _lastGroundMousePos = _castBounds.ClosestPoint(_lastGroundMousePos);
                return _lastGroundMousePos;
            }
        }

        public Vector3 GetGroundMousePosition(Vector3 castPosition, float castRadius)
        {
            GetGroundMousePosition();

            float distance = Vector3.Distance(_lastGroundMousePos, castPosition);

            if (distance < castRadius)
            {
                return _lastGroundMousePos;
            }
            else
            {
                Vector3 direction = _lastGroundMousePos - castPosition;
                _lastGroundMousePos = castPosition + (direction.normalized * castRadius);
                return _lastGroundMousePos;
            }
        }

        #endregion

        #region Data Manage

        private void UpdateData()
        {
            if (!selectedTarget)
            {
                DeselectTarget();
            }
        }

        #endregion
    }
}
