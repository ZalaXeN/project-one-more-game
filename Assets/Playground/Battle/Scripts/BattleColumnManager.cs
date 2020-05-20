using UnityEngine;

namespace ProjectOneMore.Battle
{
    public class BattleColumnManager : MonoBehaviour
    {
        public int rowsPerColumn = 4;
        public BattleColumn[] battleColumns;
        public Collider enemySpawnArea;
        public Collider playerSpawnArea;

        public void Initizialize()
        {
            foreach (BattleColumn column in battleColumns)
            {
                column.Initialize();
            }
        }

        public void RepositionUnitToEmptySlot(BattleTeam team, BattleUnitAttackType unitAttackType, BattleColumn targetColumn, bool onRemove = false)
        {
            //if (!onRemove)
            //{
            //    RepositionZoneFromNearToFar(team, unitAttackType, targetColumn);
            //}
            //else
            //{
            //    // Remove Range unit on melee zone
            //    if (unitAttackType == BattleUnitAttackType.Range && targetColumn.zone != unitAttackType)
            //    {
            //        RepositionZoneFromNearToFar(team, BattleUnitAttackType.Melee, targetColumn);
            //    }
            //    else
            //    {
            //        RepositionZoneFromNearToFar(team, unitAttackType, targetColumn);
            //    }
            //}

            RepositionZoneFromNearToFar(team, unitAttackType, targetColumn);
            UpdateBattleColumns(team);
        }

        private void RepositionZoneFromNearToFar(BattleTeam team, BattleUnitAttackType unitAttackType, BattleColumn targetColumn)
        {
            BattleColumn nextColumn = GetNextBattleColumn(team, unitAttackType, targetColumn.columnNumber);
            if (nextColumn == null)
                return;

            RepositionUnitFromColumn(unitAttackType, targetColumn, nextColumn);

            // Repositioning from left to right recursive
            // Column full
            if (targetColumn.GetUnitNumber() >= rowsPerColumn || targetColumn.zone != unitAttackType)
                RepositionZoneFromNearToFar(team, unitAttackType, nextColumn);
            else
                RepositionZoneFromNearToFar(team, unitAttackType, targetColumn);
        }

        private void RepositionZoneFromFarToNear(BattleTeam team, BattleUnitAttackType unitAttackType, BattleColumn targetColumn)
        {
            BattleColumn previousColumn = GetPreviousBattleColumn(team, unitAttackType, targetColumn.columnNumber);
            if (previousColumn == null)
                return;

            RepositionUnitFromColumn(unitAttackType, targetColumn, previousColumn);

            // Repositioning from right to left recursive
            // Column full
            if (targetColumn.GetUnitNumber() >= rowsPerColumn)
                RepositionZoneFromFarToNear(team, unitAttackType, previousColumn);
            else
                RepositionZoneFromFarToNear(team, unitAttackType, targetColumn);
        }

        private void RepositionUnitFromColumn(BattleUnitAttackType unitAttackType, BattleColumn targetColumn, BattleColumn nextColumn)
        {
            if (targetColumn == null || nextColumn == null || targetColumn.GetUnitNumber() >= rowsPerColumn)
                return;

            float targetDepth = targetColumn.GetEmptyCenteredFirstColumnDepth();

            BattleUnit popUnit = nextColumn.PopUnit(unitAttackType, targetDepth);
            targetColumn.AssignUnit(popUnit);
            //targetColumn.UpdateRows();
            //nextColumn.UpdateRows();

            popUnit.column = targetColumn.columnNumber;
            popUnit.columnDepth = targetColumn.GetEmptyCenteredFirstColumnDepth(popUnit);
            popUnit.columnIndex = targetColumn.GetColumnIndex(popUnit.columnDepth);
            popUnit.isMovingToTarget = true;
        }

        public void UpdateBattleColumns(BattleTeam team, bool triggerEvent = true)
        {
            foreach (BattleColumn column in battleColumns)
            {
                if(column.team == team)
                    column.UpdateRows(triggerEvent);
            }
        }

        private BattleColumn GetNextBattleColumn(BattleTeam team, BattleUnitAttackType unitAttackType, int columnNumber)
        {
            foreach (BattleColumn column in battleColumns)
            {
                if (column.team != team)
                    continue;

                if (column.columnNumber > columnNumber && column.HasUnit(unitAttackType))
                    return column;
            }
            return null;
        }

        private BattleColumn GetPreviousBattleColumn(BattleTeam team, BattleUnitAttackType unitAttackType, int columnNumber)
        {
            foreach (BattleColumn column in battleColumns)
            {
                if (column.team != team)
                    continue;

                if (column.columnNumber < columnNumber && column.HasUnit(unitAttackType))
                    return column;
            }
            return null;
        }

        private bool HasRangeOnMeleeZone(BattleTeam team)
        {
            foreach (BattleColumn column in battleColumns)
            {
                if (column.team != team)
                    continue;

                if (column.HasUnit(BattleUnitAttackType.Range) && column.zone == BattleUnitAttackType.Melee)
                    return true;
            }
            return false;
        }

        public Vector3 GetSpawnPosition(BattleTeam team)
        {
            Bounds bound = team == BattleTeam.Player ? playerSpawnArea.bounds : enemySpawnArea.bounds;
            Vector3 result = new Vector3(
                Random.Range(bound.min.x, bound.max.x),
                Random.Range(bound.min.y, bound.max.y),
                Random.Range(bound.min.z, bound.max.z));
            return result;
        }

        public BattleColumn GetBattleColumn(BattleTeam team, int column)
        {
            foreach (BattleColumn battleColumn in battleColumns)
            {
                if (battleColumn.team != team)
                    continue;

                if (battleColumn.columnNumber == column)
                    return battleColumn;
            }
            return null;
        }

        public Vector3 GetBattlePosition(BattleTeam team, int column, float columnDepth)
        {
            BattleColumn battleColumn = GetBattleColumn(team, column);
            if (battleColumn == null)
                return Vector3.zero;

            return battleColumn.GetRowPosition(columnDepth);
        }

        public float GetBattleColumnDepth(BattleTeam team, int column, int columnIndex)
        {
            BattleColumn battleColumn = GetBattleColumn(team, column);
            if (battleColumn == null)
                return 0.5f;

            return battleColumn.GetColumnDepth(columnIndex);
        }

        public float GetNearestBattleColumnDepth(BattleTeam team, int column, float columnDepth, BattleUnit unit)
        {
            BattleColumn battleColumn = GetBattleColumn(team, column);
            if (battleColumn == null)
                return columnDepth;

            return battleColumn.GetNearestColumnDepth(columnDepth, unit);
        }

        public int GetColumnIndex(BattleTeam team, int column, float columnDepth)
        {
            BattleColumn battleColumn = GetBattleColumn(team, column);
            if (battleColumn == null)
                return 0;

            return battleColumn.GetColumnIndex(columnDepth);
        }

        public BattleUnitAttackType GetColumnZoneType(BattleTeam team, int column)
        {
            BattleColumn battleColumn = GetBattleColumn(team, column);
            if (battleColumn == null)
                return BattleUnitAttackType.Melee;

            return battleColumn.zone;
        }

        public bool HasEmptySlotOnZone(BattleTeam team, BattleUnitAttackType zone)
        {
            BattleColumn result;
            return HasEmptySlotOnZone(team, zone, out result);
        }

        public bool HasEmptySlotOnZone(BattleTeam team, BattleUnitAttackType zone, out BattleColumn resultColumn)
        {
            resultColumn = null;
            BattleColumn emptyMeleeColumn = null;

            foreach (BattleColumn column in battleColumns)
            {
                if (column.team != team)
                    continue;

                if (column.GetUnitNumber() < rowsPerColumn)
                {
                    if (column.zone == zone)
                    {
                        resultColumn = column;
                        return true;
                    }
                    else if (column.zone == BattleUnitAttackType.Melee)
                    {
                        emptyMeleeColumn = column;
                    }
                }
            }

            // Return lastest empty melee for Range Unit if no empty range zone
            if (zone == BattleUnitAttackType.Range && emptyMeleeColumn != null)
            {
                resultColumn = emptyMeleeColumn;
                return true;
            }

            return false;
        }

    }
}
