import 'package:flutter/material.dart';
import 'dart:math';

class WordSearch extends StatefulWidget {
  const WordSearch({super.key});

  @override
  State<WordSearch> createState() => _WordSearchState();
}

class _WordSearchState extends State<WordSearch> {
  final List<String> _words = [
    'HAPPY',
    'PEACE',
    'SMILE',
    'LOVE',
    'JOY',
    'CALM',
    'HOPE',
    'DREAM',
    'BRAVE',
    'KIND'
  ];

  late List<List<String>> _grid;
  late List<List<bool>> _selected;
  List<String> _foundWords = [];
  int _gridSize = 10;
  Offset? _startDrag;
  Offset? _currentDrag;
  List<Offset> _selectedCells = [];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _grid = List.generate(_gridSize, (_) => List.filled(_gridSize, ''));
    _selected = List.generate(_gridSize, (_) => List.filled(_gridSize, false));
    _foundWords = [];
    _placeWords();
    _fillEmptyCells();
  }

  void _placeWords() {
    final random = Random();
    for (String word in _words) {
      bool placed = false;
      int attempts = 0;
      while (!placed && attempts < 100) {
        int row = random.nextInt(_gridSize);
        int col = random.nextInt(_gridSize);
        int direction =
            random.nextInt(3); // 0: horizontal, 1: vertical, 2: diagonal

        if (_canPlaceWord(word, row, col, direction)) {
          _placeWord(word, row, col, direction);
          placed = true;
        }
        attempts++;
      }
    }
  }

  bool _canPlaceWord(String word, int row, int col, int direction) {
    if (direction == 0 && col + word.length > _gridSize) return false;
    if (direction == 1 && row + word.length > _gridSize) return false;
    if (direction == 2 &&
        (row + word.length > _gridSize || col + word.length > _gridSize))
      return false;

    for (int i = 0; i < word.length; i++) {
      int currentRow = row + (direction == 1 || direction == 2 ? i : 0);
      int currentCol = col + (direction == 0 || direction == 2 ? i : 0);

      if (_grid[currentRow][currentCol].isNotEmpty &&
          _grid[currentRow][currentCol] != word[i]) {
        return false;
      }
    }
    return true;
  }

  void _placeWord(String word, int row, int col, int direction) {
    for (int i = 0; i < word.length; i++) {
      int currentRow = row + (direction == 1 || direction == 2 ? i : 0);
      int currentCol = col + (direction == 0 || direction == 2 ? i : 0);
      _grid[currentRow][currentCol] = word[i];
    }
  }

  void _fillEmptyCells() {
    final random = Random();
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    for (int i = 0; i < _gridSize; i++) {
      for (int j = 0; j < _gridSize; j++) {
        if (_grid[i][j].isEmpty) {
          _grid[i][j] = letters[random.nextInt(letters.length)];
        }
      }
    }
  }

  void _onPanStart(DragStartDetails details, int row, int col) {
    setState(() {
      _startDrag = Offset(col.toDouble(), row.toDouble());
      _currentDrag = _startDrag;
      _selectedCells = [Offset(col.toDouble(), row.toDouble())];
      _updateSelectedCells();
    });
  }

  void _onPanUpdate(DragUpdateDetails details, int row, int col) {
    setState(() {
      _currentDrag = Offset(col.toDouble(), row.toDouble());
      _selectedCells = _getSelectedCells();
      _updateSelectedCells();
    });
  }

  void _onPanEnd(DragEndDetails details) {
    String selectedWord = '';
    for (var cell in _selectedCells) {
      selectedWord += _grid[cell.dy.toInt()][cell.dx.toInt()];
    }

    if (_words.contains(selectedWord) && !_foundWords.contains(selectedWord)) {
      setState(() {
        _foundWords.add(selectedWord);
        if (_foundWords.length == _words.length) {
          _showWinDialog();
        }
      });
    } else {
      setState(() {
        _selected =
            List.generate(_gridSize, (_) => List.filled(_gridSize, false));
      });
    }

    _startDrag = null;
    _currentDrag = null;
    _selectedCells = [];
  }

  List<Offset> _getSelectedCells() {
    if (_startDrag == null || _currentDrag == null) return [];

    List<Offset> cells = [];
    int dx = (_currentDrag!.dx - _startDrag!.dx).abs().toInt();
    int dy = (_currentDrag!.dy - _startDrag!.dy).abs().toInt();

    if (dx >= dy) {
      // Horizontal selection
      int y = _startDrag!.dy.toInt();
      int startX = min(_startDrag!.dx.toInt(), _currentDrag!.dx.toInt());
      int endX = max(_startDrag!.dx.toInt(), _currentDrag!.dx.toInt());

      for (int x = startX; x <= endX; x++) {
        cells.add(Offset(x.toDouble(), y.toDouble()));
      }
    } else {
      // Vertical selection
      int x = _startDrag!.dx.toInt();
      int startY = min(_startDrag!.dy.toInt(), _currentDrag!.dy.toInt());
      int endY = max(_startDrag!.dy.toInt(), _currentDrag!.dy.toInt());

      for (int y = startY; y <= endY; y++) {
        cells.add(Offset(x.toDouble(), y.toDouble()));
      }
    }

    return cells;
  }

  void _updateSelectedCells() {
    _selected = List.generate(_gridSize, (_) => List.filled(_gridSize, false));

    for (var cell in _selectedCells) {
      _selected[cell.dy.toInt()][cell.dx.toInt()] = true;
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations! 🎉'),
        content: const Text('You found all the words!'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _initializeGame());
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _initializeGame()),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _gridSize,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
              ),
              itemCount: _gridSize * _gridSize,
              itemBuilder: (context, index) {
                final row = index ~/ _gridSize;
                final col = index % _gridSize;
                final isSelected = _selected[row][col];

                return GestureDetector(
                  onPanStart: (details) => _onPanStart(details, row, col),
                  onPanUpdate: (details) => _onPanUpdate(details, row, col),
                  onPanEnd: _onPanEnd,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primaryContainer,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.background,
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _grid[row][col],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find these words:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 3,
                      ),
                      itemCount: _words.length,
                      itemBuilder: (context, index) {
                        final word = _words[index];
                        final found = _foundWords.contains(word);

                        return Text(
                          word,
                          style: TextStyle(
                            decoration:
                                found ? TextDecoration.lineThrough : null,
                            color: found ? Colors.grey : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
