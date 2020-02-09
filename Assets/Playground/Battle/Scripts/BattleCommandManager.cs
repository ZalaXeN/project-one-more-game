using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BattleCommandManager
{
    private Queue<IBattleCommand> executingCommandQueue = new Queue<IBattleCommand>();
    private Stack<IBattleCommand> executedCommandStack = new Stack<IBattleCommand>();

    public void AddCommand(IBattleCommand command)
    {
        executingCommandQueue.Enqueue(command);
    }

    public void ClearCommand()
    {
        executingCommandQueue.Clear();
        executedCommandStack.Clear();
    }

    public void Next()
    {
        if (executingCommandQueue.Count <= 0)
            return;

        IBattleCommand currentCommand = executingCommandQueue.Dequeue();
        currentCommand.Execute();
        executedCommandStack.Push(currentCommand);
    }

    public void Back()
    {
        if (executedCommandStack.Count <= 0)
            return;

        IBattleCommand currentCommand = executedCommandStack.Pop();
        currentCommand.Undo();
        executingCommandQueue.Enqueue(currentCommand);
    }

    public void LoadCommandQueue(Queue<IBattleCommand> commandQueue)
    {
        ClearCommand();
    }
}
