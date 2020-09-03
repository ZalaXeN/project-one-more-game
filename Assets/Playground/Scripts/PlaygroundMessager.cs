using UnityEngine;
using System.Collections;
using ProjectOneMore.Battle;

public class PlaygroundMessager : MonoBehaviour
{
    private Vector3 _mousePos;
    private string _particleTargetName;
    private bool _particleModeActive;

    private BattleParticleManager _battleParticleManager;
    private BattleUnit[] _battleUnitList;

    private void LoadAllBattleUnit()
    {
        if(_battleUnitList == null)
        {
            _battleUnitList = FindObjectsOfType<BattleUnit>();
        }
    }

    private void LoadParticleManager()
    {
        if (_battleParticleManager == null)
        {
            _battleParticleManager = FindObjectOfType<BattleParticleManager>();
        }
    }

    private void Update()
    {
        ShowTestParticle();
    }

    #region Test Animation

    public void BoardcastTriggerTestAnimation(string name)
    {
        LoadAllBattleUnit();

        foreach (BattleUnit unit in _battleUnitList)
        {
            unit.gameObject.SendMessage("TriggerTestAnimation", name);
        }
    }

    public void BoardcastToggleAnimatorBool(string name)
    {
        LoadAllBattleUnit();

        foreach (BattleUnit unit in _battleUnitList)
        {
            unit.gameObject.SendMessage("ToggleAnimatorBool", name);
        }
    }

    public void BoardcastToggleTestMoving()
    {
        LoadAllBattleUnit();

        foreach (BattleUnit unit in _battleUnitList)
        {
            unit.gameObject.SendMessage("ToggleTestMoving");
        }
    }

    public void BoardcastToggleIdle()
    {
        LoadAllBattleUnit();

        foreach (BattleUnit unit in _battleUnitList)
        {
            unit.gameObject.SendMessage("ToggleIdle");
        }
    }

    #endregion

    #region Test Particle

    public void SelectParticle(string name)
    {
        _particleTargetName = name;
    }

    public void SetSelectedParticleActive(bool value)
    {
        _particleModeActive = value;
        LoadParticleManager();
    }

    public void ShowTestParticle()
    {
        if (!_particleModeActive || _battleParticleManager == null)
            return;

        if (Input.GetMouseButtonDown(0))
        {
            _mousePos = Input.mousePosition;
            _mousePos.z = Camera.main.nearClipPlane - Camera.main.transform.position.z;
            _mousePos = Camera.main.ScreenToWorldPoint(_mousePos);

            _battleParticleManager.ShowParticle(_particleTargetName, _mousePos);
        }
    }

    #endregion
}
