import 'dart:math';
import 'package:flutter/material.dart';

String _selectedAlgorithm = 'Minimax Algorithm'; // Default algorithm


class NumSet {
  int value = 0;
  int totalPoints = 0;
  int bankPoints = 0;
  List<int> numbers;

  NumSet(this.numbers, this.totalPoints, this.bankPoints);

  void clone(NumSet original) {
    totalPoints = original.totalPoints;
    bankPoints = original.bankPoints;
    numbers = List<int>.from(original.numbers);
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Game Options',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameOptionsPage(),
    );
  }
}

class GameOptionsPage extends StatefulWidget {
  const GameOptionsPage({super.key});

  @override
  _GameOptionsPageState createState() => _GameOptionsPageState();
}


class _GameOptionsPageState extends State<GameOptionsPage> {
  String _playMode = 'Computer'; // Default play mode
  int _selectedStringLength = 15; // Default string length
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Options'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildOptionTitle('Select First Player'),
            _buildPlayerSelection(),
            const SizedBox(height: 20),
            _buildOptionTitle('Select Length of String'),
            _buildStringLengthSelection(),
            const SizedBox(height: 20),
            _buildOptionTitle('Select Algorithm'),
            _buildAlgorithmSelection(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GamePage(
                      stringLength: _selectedStringLength,
                      playMode: _playMode,
                    ),
                  ),
                );
              },
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPlayerSelection() {
    return DropdownButton<String>(
      value: _playMode,
      onChanged: (String? newValue) {
        setState(() {
          _playMode = newValue!;
        });
      },
      items: <String>['Computer', 'User']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildStringLengthSelection() {
    return DropdownButton<int>(
      value: _selectedStringLength,
      onChanged: (int? newValue) {
        setState(() {
          _selectedStringLength = newValue!;
        });
      },
      items: List.generate(
        11,
        (index) => DropdownMenuItem<int>(
          value: index + 15,
          child: Text('${index + 15}'),
        ),
      ),
    );
  }

  Widget _buildAlgorithmSelection() {
    return DropdownButton<String>(
      value: _selectedAlgorithm,
      onChanged: (String? newValue) {
        setState(() {
          _selectedAlgorithm = newValue!;
        });
      },
      items: <String>['Minimax Algorithm', 'Alpha-beta Algorithm']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class GamePage extends StatefulWidget {
  final int stringLength;
  final String playMode;

  const GamePage({super.key, required this.stringLength, required this.playMode});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final NumSet _gameNumbers = NumSet([], 0, 0);
  int _selectedIndex = 0;
  int _totalScore = 0;
  int _bank = 0;
  String _currentPlayer = 'User';
  final List<String> _previousStrings = [];

  void _startUserGame() {
    setState(() {
      _currentPlayer = 'User';
    });
  }

  @override
  void initState() {
    super.initState();
    _generateRandomNumbers(widget.stringLength);
    _currentPlayer = widget.playMode;
    if (_currentPlayer == 'User') {
      // Adding a delay before the computer starts playing to ensure the user sees the initial state
      _startUserGame();
    } else {
      // If the user is the first player, trigger the computer's move immediately after the user makes a move
      _computerPlay();

    }
  }

  void _generateRandomNumbers(int length) {
    Random random = Random();
    _gameNumbers.numbers = List.generate(length, (index) => random.nextInt(6) + 1);
    _updatePreviousStrings();
    setState(() {});
  }

  void _updatePreviousStrings() {
    _previousStrings.add(_gameNumbers.numbers.join(' '));
  }

  int minimax(NumSet nodeValue, bool isMaximizingPlayer) {
    // Base case: if the depth limit is reached or the game ends
    if (nodeValue.numbers.length == 1) {
      return evaluate(nodeValue);
    }

    if (isMaximizingPlayer) {
      int bestValue = -10; // Initialize with a small value
      // Simulate possible moves for the maximizing player
      for (NumSet move in getPossibleMoves(nodeValue)) {
        int value = minimax(move, false);
        bestValue = value > bestValue ? value : bestValue; // Maximize
      }
      return bestValue;
    } else {
      int bestValue = 10; // Initialize with a large value
      // Simulate possible moves for the minimizing player
      for (NumSet move in getPossibleMoves(nodeValue)) {
        int value = minimax(move, true);
        bestValue = value < bestValue ? value : bestValue; // Minimize
      }
      return bestValue;
    }
  }

  int alphaBeta(NumSet nodeValue, bool isMaximizingPlayer, int alpha, int beta) {
    // Base case: if the depth limit is reached or the game ends
    if (nodeValue.numbers.length == 1) {
      return evaluate(nodeValue);
    }

    if (isMaximizingPlayer) {
      int bestValue = -10; // Initialize with a small value
      // Simulate possible moves for the maximizing player
      for (NumSet move in getPossibleMoves(nodeValue)) {
        int value = alphaBeta(move, false, alpha, beta);
        bestValue = value > bestValue ? value : bestValue; // Maximize
        alpha = alpha > value ? alpha : value; // Maximize
        if(beta<=alpha){
          break;
        }
      }
      return bestValue;
    } else {
      int bestValue = 10; // Initialize with a large value
      // Simulate possible moves for the minimizing player
      for (NumSet move in getPossibleMoves(nodeValue)) {
        int value = alphaBeta(move, true, alpha, beta);
        bestValue = value < bestValue ? value : bestValue; // Minimize
        beta = value < beta ? value : beta; // Minimize
        if(beta<=alpha){
          break;
        }
      }
      return bestValue;
    }
  }

  int evaluate(NumSet nodeValue) {
    if((nodeValue.totalPoints + nodeValue.bankPoints)%2 == 0 && nodeValue.numbers[0]%2 == 0){
      return 1;
    }else if((nodeValue.totalPoints + nodeValue.bankPoints)%2 == 1 && nodeValue.numbers[0]%2 == 1){
      return -1;
    }
    return 0;
  }

  // Implement generating possible moves based on the current game state
  List<NumSet> getPossibleMoves(NumSet nodeValue) {
    List<NumSet> possibleMoves = [];
    if(nodeValue.numbers.length > 1){
      for(int i = 0; i< nodeValue.numbers.length-1; i+=2){
        NumSet temp = NumSet([], 0, 0);
        temp.clone(nodeValue);
        temp.numbers[i] = temp.numbers[i] + temp.numbers[i+1];
        temp.numbers.removeAt(i+1);
        if(temp.numbers[i] > 6){
          temp.numbers[i] = temp.numbers[i] - 6;
          temp.bankPoints++;
        }
        temp.totalPoints++;
        possibleMoves.add(temp);
      }

      if(nodeValue.numbers.length%2 == 1){
        NumSet temp = NumSet([], 0, 0);
        temp.clone(nodeValue);
        temp.numbers.removeLast();
        temp.totalPoints--;
        possibleMoves.add(temp);
      }
    }
    
    return possibleMoves;
  }

  NumSet _bestMove(List<NumSet> possibleMoves, String algo){
    NumSet bestMove = NumSet([], 0, 0);
    int maxVal = 10;
    int val = 0;
    for(NumSet move in possibleMoves){
      if(algo=="Minimax Algorithm"){
        val = minimax(move, true);
      }else if(algo=="Alpha-beta Algorithm"){
        val = alphaBeta(move, true, -10, 10);
      }
      if(val < maxVal){
        maxVal = val;
        bestMove.clone(move);
      }
    }

    return bestMove;
  }

  void _computerPlay() {
    setState(() {
      NumSet oldSet = NumSet([], 0, 0);
      oldSet.clone(_gameNumbers);
      _gameNumbers.clone(_bestMove(getPossibleMoves(_gameNumbers), _selectedAlgorithm));
      _updatePreviousStrings();
      _updateComputerScore(oldSet, _gameNumbers);
      _currentPlayer = 'User';
    });
    _isGameOver();
  }

  void _updateComputerScore(NumSet oldSet, NumSet currentSet){
    if(oldSet.numbers[oldSet.numbers.length-1] != currentSet.numbers[currentSet.numbers.length-1]
      && oldSet.numbers.length%2 != 0){
        _totalScore--;
      }else if(calcSum(oldSet) > calcSum(currentSet)){
        _totalScore++;
        _bank++;
      }else{
        _totalScore++;
      }
  }

  int calcSum(NumSet set){
    int sum = 0;
    for(int i = 0; i < set.numbers.length-1; i++){
      sum+= set.numbers[i];
    }
    return sum;
  }

  void _moveSelectionRight() {
    if (_selectedIndex < _gameNumbers.numbers.length - 1) {
      setState(() {
        _selectedIndex += 2;
      });
    }
  }

  void _moveSelectionLeft() {
    if (_selectedIndex > 0) {
      setState(() {
        _selectedIndex -= 2;
      });
    }
  }

  void _sumNumbers() {
    if (_selectedIndex < _gameNumbers.numbers.length - 1) {
      int sum = _gameNumbers.numbers[_selectedIndex] + _gameNumbers.numbers[_selectedIndex + 1];
      if (sum > 6) {
        sum = {
          7: 1,
          8: 2,
          9: 3,
          10: 4,
          11: 5,
          12: 6,
        }[sum]!;
        setState(() {
          _bank += 1;
        });
      }
      setState(() {
        _totalScore += 1;
        _gameNumbers.numbers[_selectedIndex] = sum;
        _gameNumbers.numbers.removeAt(_selectedIndex + 1);
        _selectedIndex = 0;
        //_previousMoves.add('Summed numbers at index $_selectedIndex');
        _updatePreviousStrings();
      });
      _switchPlayer();
    }
  }

  void _deleteNumbers() {
    if (_gameNumbers.numbers.length % 2 != 0) {
      setState(() {
        _gameNumbers.numbers.removeLast();
        _totalScore -= 1;
        // if (_selectedIndex >= _gameNumbers.numbers.length) {
        //   _selectedIndex = max(0, _gameNumbers.numbers.length - 2);
        // }
        _selectedIndex = 0;
      });
      //_previousMoves.add('Deleted last number');
      _updatePreviousStrings();
      _switchPlayer();
    }
  }

  bool _isGameOver(){
    if (_gameNumbers.numbers.length == 1) {
      // Game over, calculate winner
      int lastNumber = _gameNumbers.numbers.first;
      int grandTotal = _totalScore + _bank;
      String winnerMessage;

      if (lastNumber % 2 == 0 && grandTotal % 2 == 0) {
        winnerMessage = 'Player 1 wins!';
      } else if (lastNumber % 2 != 0 && grandTotal % 2 != 0) {
        winnerMessage = 'Player 2 wins!';
      } else {
        winnerMessage = 'It\'s a draw!';
      }

      // Show winner message with option to play again
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Game Over'),
          content: Text(winnerMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.popUntil(
                    context,
                    ModalRoute.withName(
                        '/')); // Pop until the game options page
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _restartGame(); // Call the restart function
              },
              child: const Text('Restart Game'),
            ),
          ],
        ),
      );
      return true;
    }
    return false;
  }

  void _switchPlayer() {
    if(_isGameOver()){
      return;
    }
    if (_currentPlayer == 'User') {
      _currentPlayer = 'Computer';
      _computerPlay(); // Give some delay before computer plays
    } else {
      _currentPlayer = 'User'; // It's now the user's turn
    }
  }

  void _restartGame() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => GamePage(
              stringLength: widget.stringLength,
              playMode: widget.playMode,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < _gameNumbers.numbers.length; i++)
                  Text(
                    '${_gameNumbers.numbers[i]} ',
                    style: TextStyle(
                      fontSize: 18,
                      color: i == _selectedIndex || i == _selectedIndex + 1
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
                child: ListView(
              children: _previousStrings
                  .map((string) => Text(string))
                  .toList(), // Display previous strings
            )),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _moveSelectionLeft,
                  child: const Text('<'),
                ),
                ElevatedButton(
                  onPressed: _moveSelectionRight,
                  child: const Text('>'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _sumNumbers,
                  child: const Text('Sum'),
                ),
                ElevatedButton(
                  onPressed: _deleteNumbers,
                  child: const Text('Delete'),
                ),
              ],
            ),
            /*SizedBox(height: 20),

            Column(
              children: _previousMoves.map((move) => Text(move)).toList(),
            ),*/
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Total Score: $_totalScore',
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Bank: $_bank', style: const TextStyle(fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
