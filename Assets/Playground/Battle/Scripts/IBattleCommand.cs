public interface IBattleCommand
{
    void Execute();
    void Undo();
    float GetExecuteTime();
}
