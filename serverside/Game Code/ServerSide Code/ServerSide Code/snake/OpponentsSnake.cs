using System;
using System.Collections;
using PlayerIO.GameLibrary;

namespace ServerSide.snake
{
    public class OpponentsSnake : UserSnake
    {
        public const int BoostLength = 28; //boost lasts for 28 cells (~7 seconds)
        private readonly SnakeGame _snakeGame; //for calling tryPlaceMine() when entered target cell
        private int _boostTokens;
        public int BoostType = 1;
        public DatabaseObject FutureBoost;
        public DatabaseArray FutureTurns;

        public int NoRandomTurnCounter = 0;
        private DatabaseObject _targetMinesCell;

        public OpponentsSnake(int startPositionID, ArrayList fruits, ArrayList minesAlive, GameManager roomClass,
            DatabaseArray turns, SnakeGame snakeGame)
            : base(startPositionID, fruits, minesAlive, roomClass)
        {
            FutureTurns = turns;
            _snakeGame = snakeGame;
        }

        public void MoveWithCheck()
        {
            if (ReabilitationCounter == 0)
            {
                for (var i = 0; i < BoostType; i++)
                {
                    DoMove();
                }
            }
            else ReabilitationCounter--;

            if (BoostType >= 1) //if dude will hit mine during boost, boost will be wasted (!). Very cool 
            {
                _boostTokens--;
                if (_boostTokens == 0)
                {
                    BoostType = 1; //boost finished			
                }
            }
        }

        private void DoMove()
        {
            var previousI = Head.I;
            var previousJ = Head.J;

            if (FutureTurns.Count > 0)
            {
                var nextTurn = FutureTurns[0] as DatabaseObject;
                //Console.WriteLine(nextTurn.GetInt("i") + " j: " + nextTurn.GetInt("j") + " HEAD i: " + head.i + " j: " + head.j);
                if (nextTurn != null && (nextTurn.GetInt("i") == Head.I && nextTurn.GetInt("j") == Head.J))
                {
                    MoveAndTurn(nextTurn.GetInt("i"), nextTurn.GetInt("j"), nextTurn.GetInt("direction"));
                    FutureTurns.RemoveAt(0);
                }
                else MoveForward();
            }
            else
            {
                if (NoRandomTurnCounter > 0) //so snake won't randomly turn before hitting target cell. 
                {
                    MoveForward();
                    NoRandomTurnCounter--;
                }
                else MoveFowardAndTryRandomTurn();
            }

            if (FutureBoost != null)
            {
                CheckForBoost(previousI, previousJ);
            }
            if (_targetMinesCell != null)
            {
                CheckForMines(previousI, previousJ);
            }
        }

        public void PrepareForBoost(int[] targetCellData, bool triple)
        {
            FutureBoost = new DatabaseObject();
            FutureBoost.Set("type", triple ? 3 : 2);
            SetTargetCellProperties(FutureBoost, targetCellData);
        }

        public void PrepareForMines(int[] targetCellData)
        {
            _targetMinesCell = new DatabaseObject();
            SetTargetCellProperties(_targetMinesCell, targetCellData);
        }

        private void CheckForBoost(int previousI, int previousJ)
        {
            //Console.WriteLine("checkForBoost");
            if (AtTargetCell(FutureBoost, previousI, previousJ))
            {
                _boostTokens = BoostLength;
                BoostType = FutureBoost.GetInt("type");
                FutureBoost = null;
            }
        }

        private void CheckForMines(int previousI, int previousJ)
        {
            if (AtTargetCell(_targetMinesCell, previousI, previousJ))
            {
                MinesRequestedCounter = SnakeGame.MinesInSet;
                _targetMinesCell = null;
                _snakeGame.TryPlaceMine(this);
            }
        }

        private bool AtTargetCell(DatabaseObject targetCellObject, int previousI, int previousJ)
        {
            var prevEqual = previousI == targetCellObject.GetInt("preTargetCellI") &&
                             previousJ == targetCellObject.GetInt("preTargetCellJ");
            var currentEqual = Head.I == targetCellObject.GetInt("targetCellI") &&
                                Head.J == targetCellObject.GetInt("targetCellJ");
            Console.WriteLine("prevEqual: " + prevEqual + "currentEqual: " + currentEqual);
            return prevEqual && currentEqual;
        }

        private void MoveFowardAndTryRandomTurn()
        {
            var turnDirection = Head.DirectionID;
            var targetI = Head.I;
            var targetJ = Head.J;
            if (RoomClass.Rand.Next(5) == 1) //1 move of 6 will be the turn (on average)
            {
                for (var i = 0; i < 8; i++) //so there is 2 seconds for client to receive turn data. (prevents async)
                {
                    targetI = SnakePart.GetFutureCellI(turnDirection, targetI);
                    targetJ = SnakePart.GetFutureCellJ(turnDirection, targetJ);
                }

                turnDirection = GetPossibleDirections(turnDirection)[RoomClass.Rand.Next(2)];

                var nextTurn = new DatabaseObject();
                nextTurn.Set("i", targetI);
                nextTurn.Set("j", targetJ);
                nextTurn.Set("direction", turnDirection);
                FutureTurns.Add(nextTurn);
                RoomClass.Creator.Send("ft", targetI, targetJ, turnDirection);
            }
            MoveForward();
        }

        private static int[] GetPossibleDirections(int currentDirection)
        {
            var possibleTurns = new int[2]; //0 - right, 1 - down, 2 - left, 3 - up
            switch (currentDirection)
            {
                case 0:
                    possibleTurns = new[] {1, 3};
                    break;
                case 1:
                    possibleTurns = new[] {0, 2};
                    break;
                case 2:
                    possibleTurns = new[] {1, 3};
                    break;
                case 3:
                    possibleTurns = new[] {0, 2};
                    break;
            }
            return possibleTurns;
        }

        private static void SetTargetCellProperties(DatabaseObject obj, int[] targetCellData)
        {
            obj.Set("preTargetCellI", targetCellData[0]);
            obj.Set("preTargetCellJ", targetCellData[1]);
            obj.Set("targetCellI", targetCellData[2]);
            obj.Set("targetCellJ", targetCellData[3]);
        }
    }
}