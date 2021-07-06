namespace ProjectOneMore.Battle
{
    public interface IBattleModifier
    {
        void OnApply(BattleUnit unit);
        void OnUpdate();
        void OnSignal(MessageType type, object sender, object msg);
        void OnDestroy();
    }
}