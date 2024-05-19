import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(ForestFireApp());
}

class ForestFireApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ForestFireHomePage(),
    );
  }
}

class ForestFireHomePage extends StatefulWidget {
  @override
  _ForestFireHomePageState createState() => _ForestFireHomePageState();
}

class _ForestFireHomePageState extends State<ForestFireHomePage> {
  int gridSize = 16;
  int windStrength = 0;
  String windDirection = 'Nord';
  double humidity = 1.0;
  double emptyRatio = 0.1;
  int maxIterations = 50;
  int currentIteration = 0;
  int autoIterations = 0;
  bool simulationStarted = false;
  bool isRunning = false;

  List<List<ForestCell>> grid = [];
  List<List<List<ForestCell>>> iterationHistory = [];

  @override
  void initState() {
    super.initState();
    initializeGrid();
  }

  void initializeGrid() {
    grid = List.generate(
      gridSize,
      (i) => List.generate(gridSize, (j) {
        if (Random().nextDouble() < emptyRatio) {
          return ForestCell(ForestCellState.vide, i, j);
        } else {
          return ForestCell(ForestCellState.inflammable, i, j);
        }
      }),
    );
  }

  void startSimulation() {
    setState(() {
      simulationStarted = true;
      isRunning = true;
      currentIteration = 0;
      iterationHistory.clear();
      iterationHistory.add(deepCopyGrid(grid));
      if (autoIterations > 0) {
        runAutoIterations();
      }
    });
  }

  void runAutoIterations() async {
    for (int i = 0; i < autoIterations; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (isRunning) {
        simulateIteration();
      } else {
        break;
      }
    }
  }

  void restartSimulation() {
    setState(() {
      simulationStarted = false;
      isRunning = false;
      initializeGrid();
      iterationHistory.clear();
      currentIteration = 0;
    });
  }

  void handleCellTap(int row, int col) {
    setState(() {
      if (!simulationStarted && grid[row][col].state != ForestCellState.vide) {
        grid[row][col] = ForestCell(ForestCellState.enFeu, row, col);
      }
    });
  }

  void simulateIteration() {
    if (!simulationStarted) return;

    setState(() {
      List<List<ForestCell>> newGrid = deepCopyGrid(grid);

      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          updateCell(i, j, newGrid);
        }
      }

      grid = newGrid;
      iterationHistory.add(newGrid);
      currentIteration++;

      if (currentIteration >= maxIterations) {
        isRunning = false;
      }
    });
  }

  void updateCell(int i, int j, List<List<ForestCell>> newGrid) {
    ForestCell currentCell = grid[i][j];

    double extinguishedChance = 0.3;

    if (currentCell.state == ForestCellState.enFeu) {
      newGrid[i][j] = ForestCell(ForestCellState.enFeuAvance, i, j);
    } else if (currentCell.state == ForestCellState.enFeuAvance) {
      newGrid[i][j] = ForestCell(ForestCellState.brulee, i, j);
    } else if (currentCell.state == ForestCellState.brulee) {
      if (Random().nextDouble() <= extinguishedChance) {
        newGrid[i][j] = ForestCell(ForestCellState.eteint, i, j);
      } else {
        newGrid[i][j] = ForestCell(ForestCellState.brulee, i, j);
      }
    } else if (currentCell.state == ForestCellState.inflammable) {
      spreadFire(i, j, newGrid);
    } else {
      newGrid[i][j] = currentCell;
    }
  }

  void spreadFire(int i, int j, List<List<ForestCell>> newGrid) {
    List<ForestCell> neighbors = getNeighbors(i, j);
    int fireNeighborsCount = 0;

    for (var neighbor in neighbors) {
      if (neighbor.state == ForestCellState.enFeu ||
          neighbor.state == ForestCellState.enFeuAvance ||
          neighbor.state == ForestCellState.brulee) {
        fireNeighborsCount++;
      }
    }

    double fireChance = applyWindEffect(i, j, neighbors, fireNeighborsCount);


    if (Random().nextDouble() <= fireChance) {
      newGrid[i][j] = ForestCell(ForestCellState.enFeu, i, j);
    }
  }

  double applyWindEffect(
      int i, int j, List<ForestCell> neighbors, int fireNeighborsCount) {
    double newFireChance = (humidity / neighbors.length) * fireNeighborsCount;

    switch (windDirection) {
      case 'Nord':
        List<ForestCell> directionNeighbors =
            getNeighborsInDirection(i, j, 0, neighbors);
        newFireChance =
            adjustFireChanceFromDirection(directionNeighbors, newFireChance);
        break;
      case 'Nord-Est':
        List<ForestCell> directionNeighbors =
            getNeighborsInDirection(i, j, 1, neighbors);
        newFireChance =
            adjustFireChanceFromDirection(directionNeighbors, newFireChance);
        break;
      case 'Est':
        List<ForestCell> directionNeighbors =
            getNeighborsInDirection(i, j, 2, neighbors);
        newFireChance =
            adjustFireChanceFromDirection(directionNeighbors, newFireChance);
        break;
      case 'Sud-Est':
        List<ForestCell> directionNeighbors =
            getNeighborsInDirection(i, j, 3, neighbors);
        newFireChance =
            adjustFireChanceFromDirection(directionNeighbors, newFireChance);
        break;
      case 'Sud':
        List<ForestCell> directionNeighbors =
            getNeighborsInDirection(i, j, 4, neighbors);
        newFireChance =
            adjustFireChanceFromDirection(directionNeighbors, newFireChance);
        break;
      case 'Sud-Ouest':
        List<ForestCell> directionNeighbors =
            getNeighborsInDirection(i, j, 5, neighbors);
        newFireChance =
            adjustFireChanceFromDirection(directionNeighbors, newFireChance);
        break;
      case 'Ouest':
        List<ForestCell> directionNeighbors =
            getNeighborsInDirection(i, j, 6, neighbors);
        newFireChance =
            adjustFireChanceFromDirection(directionNeighbors, newFireChance);
        break;
      case 'Nord-Ouest':
        List<ForestCell> directionNeighbors =
            getNeighborsInDirection(i, j, 7, neighbors);
        newFireChance =
            adjustFireChanceFromDirection(directionNeighbors, newFireChance);
        break;
      default:
        newFireChance = adjustFireChanceFromDirection(neighbors, newFireChance);
        break;
    }

    return newFireChance;
  }

  double adjustFireChanceFromDirection(
      List<ForestCell> directionNeighbors, double fireChance) {
    double newFireChance = fireChance;
    for (var neighbor in directionNeighbors) {
      if (neighbor.state == ForestCellState.enFeu ||
          neighbor.state == ForestCellState.enFeuAvance ||
          neighbor.state == ForestCellState.brulee) {
        // Adjust fireChance if it's less than 0.5
        if (newFireChance < 0.5) {
          newFireChance = 0.5;
        }
        // No need to continue checking if fireChance is already adjusted
        break;
      }
    }
    return newFireChance;
  }

  List<ForestCell> getNeighbors(row, col) {
    List<ForestCell> neighbors = [];
    int maxNeighborsOffset = windStrength + 1;

    for (int i = row - maxNeighborsOffset; i <= row + maxNeighborsOffset; i++) {
      for (int j = col - maxNeighborsOffset;
          j <= col + maxNeighborsOffset;
          j++) {
        // Skip the cell itself
        if (i == row && j == col) {
          continue;
        }
        // Check if the neighboring cell is within the grid bounds
        if (i >= 0 && i < gridSize && j >= 0 && j < gridSize) {
          neighbors.add(grid[i][j]);
        }
      }
    }
    return neighbors;
  }

  List<ForestCell> getNeighborsInDirection(
      int row, int col, int direction, List<ForestCell> neighbors) {
    List<ForestCell> neighborsInDirection = [];

    // Define indices for each direction
    Map<int, List<int>> directionIndices = {
      // North
      0: [-1, 0],
      // Northeast
      1: [-1, 1],
      // East
      2: [0, 1],
      // Southeast
      3: [1, 1],
      // South
      4: [1, 0],
      // Southwest
      5: [1, -1],
      // West
      6: [0, -1],
      // Northwest
      7: [-1, -1],
    };

    // Get the indices for the specified direction
    List<int>? indices = directionIndices[direction];

    if (indices != null) {
      int dx = indices[0];
      int dy = indices[1];
      int directionRow = row + dx;
      int directionCol = col + dy;
      // Iterate over the existing neighbors list
      for (var neighbor in neighbors) {
        int neighborRow = neighbor.row;
        int neighborCol = neighbor.col;

        // Check if the neighbor's position matches the direction
        switch (direction) {
          case 0: // North
            if (neighborRow <= directionRow && neighborCol == directionCol) {
              neighborsInDirection.add(neighbor);
            }
            break;
          case 1: // Northeast
            if (neighborRow <= directionRow && neighborCol >= directionCol) {
              neighborsInDirection.add(neighbor);
            }
            break;
          case 2: // East
            if (neighborRow == directionRow && neighborCol >= directionCol) {
              neighborsInDirection.add(neighbor);
            }
            break;
          case 3: // Southeast
            if (neighborRow >= directionRow && neighborCol >= directionCol) {
              neighborsInDirection.add(neighbor);
            }
            break;
          case 4: // South
            if (neighborRow >= directionRow && neighborCol == directionCol) {
              neighborsInDirection.add(neighbor);
            }
            break;
          case 5: // Southwest
            if (neighborRow >= directionRow && neighborCol <= directionCol) {
              neighborsInDirection.add(neighbor);
            }
            break;
          case 6: // West
            if (neighborRow == directionRow && neighborCol <= directionCol) {
              neighborsInDirection.add(neighbor);
            }
            break;
          case 7: // Northwest
            if (neighborRow <= directionRow && neighborCol <= directionCol) {
              neighborsInDirection.add(neighbor);
            }
            break;
          default:
            neighborsInDirection.add(neighbor);
            break;
        }
      }
    }

    return neighborsInDirection;
  }

  List<List<ForestCell>> deepCopyGrid(List<List<ForestCell>> original) {
    return List.generate(
      original.length,
      (i) => List.generate(
          original[i].length, (j) => ForestCell(original[i][j].state, i, j)),
    );
  }

  void previousIteration() {
    if (currentIteration > 0) {
      setState(() {
        currentIteration--;
        grid = deepCopyGrid(iterationHistory[currentIteration]);
      });
    }
  }

  // Function to update grid size
void updateGridSize(int newSize) {
  setState(() {
    gridSize = newSize;
    initializeGrid(); // Reinitialize grid with the new size
  });
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Simulation d\'Incendie de Forêt',
        style: TextStyle(
            fontFamily: 'RobotoMono',
            fontWeight: FontWeight.bold,
            fontSize: 24),
      ),
      centerTitle: true,
    ),
    body: Row(
      children: [
        // Grid
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), // Disable scrolling
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                childAspectRatio: MediaQuery.of(context).size.width /
                  (MediaQuery.of(context).size.height * 1.25),
                mainAxisSpacing: 2.0,
                crossAxisSpacing: 2.0,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (context, index) {
                final row = index ~/ gridSize;
                final col = index % gridSize;
                return GestureDetector(
                  onTap: () => handleCellTap(row, col),
                  child: GridTile(
                    child: Container(
                      margin: const EdgeInsets.all(1.0),
                      color: getColorForState(grid[row][col].state),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Controls
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grid Size Input
                const Text(
                  'Taille de la Grille:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: gridSize.toDouble(),
                  min: 16,
                  max: 64, // Adjust maximum size as needed
                  divisions: 64-16, // Adjust divisions based on maximum size
                  label: gridSize.toString(),
                  onChanged: (double value) {
                    updateGridSize(value.toInt());
                  },
                ),
                // Wind Strength Input
                const Row(
                  children: [
                    Icon(Icons.air),
                    SizedBox(width: 8),
                    Text('Force du Vent:'),
                  ],
                ),
                Slider(
                  value: windStrength.toDouble(),
                  min: 0,
                  max: 3,
                  divisions: 3,
                  label: windStrength.toString(),
                  onChanged: (double value) {
                    setState(() {
                      windStrength = value.toInt();
                      initializeGrid();
                    });
                  },
                ),
                // Wind Direction Input
                Row(
                  children: [
                    const Icon(Icons.explore),
                    const SizedBox(width: 8),
                    const Text('Direction du Vent:'),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: windDirection,
                      onChanged: (String? newValue) {
                        setState(() {
                          windDirection = newValue!;
                          initializeGrid();
                        });
                      },
                      items: [
                        'Nord',
                        'Nord-Est',
                        'Est',
                        'Sud-Est',
                        'Sud',
                        'Sud-Ouest',
                        'Ouest',
                        'Nord-Ouest'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Icon(Icons.water_drop),
                    SizedBox(width: 8),
                    Text('Humidité:'),
                  ],
                ),
                Slider(
                  value: humidity,
                  min: 1,
                  max: 3,
                  divisions: 2,
                  label: humidity.toString(),
                  onChanged: (double value) {
                    setState(() {
                      humidity = value;
                      initializeGrid();
                    });
                  },
                ),
                // Automatic Iterations Input
                const Row(
                  children: [
                    Icon(Icons.av_timer),
                    SizedBox(width: 8),
                    Text('Itérations Automatiques:'),
                  ],
                ),
                Slider(
                  value: autoIterations.toDouble(),
                  min: 0,
                  max: 50,
                  divisions: 50,
                  label: autoIterations.toString(),
                  onChanged: (double value) {
                    setState(() {
                      autoIterations = value.toInt();
                      initializeGrid();
                    });
                  },
                ),
                // Progress Bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(
                    value: currentIteration / maxIterations,
                  ),
                ),
                // Iteration Counter
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Iteration: $currentIteration'),
                ),
                // Start Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align children at the start
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align children at the start
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // Align children at the start
                            children: [
                              Row(
                                children: [
                                  Container(
                                      width: 20, height: 20, color: Colors.brown),
                                  SizedBox(width: 8),
                                  Text('Vide'),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                      width: 20, height: 20, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Inflammable'),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                      width: 20, height: 20, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text('En Feu'),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(width: 20, height: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('En Feu Avancé'),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                      width: 20, height: 20, color: Colors.black),
                                  SizedBox(width: 8),
                                  Text('Brûlée'),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                      width: 20, height: 20, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text('Éteinte'),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                      width: 20, height: 20, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Inerte'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align children at the start
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (!simulationStarted) {
                                startSimulation();
                              } else {
                                simulateIteration();
                              }
                            },
                            icon: Icon(Icons.play_arrow),
                            label: Text('Lancer l\'itération'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                            onPressed: restartSimulation,
                            icon: Icon(Icons.restart_alt),
                            label: Text('Redémarrer'),
                          ),
                        ),
                        // Previous Iteration Button
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                            onPressed: previousIteration,
                            icon: Icon(Icons.undo),
                            label: Text('Revenir en arrière'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Color getColorForState(ForestCellState state) {
    switch (state) {
      case ForestCellState.vide:
        return Colors.brown;
      case ForestCellState.inflammable:
        return Colors.green;
      case ForestCellState.enFeu:
        return Colors.orange;
      case ForestCellState.enFeuAvance:
        return Colors.red;
      case ForestCellState.brulee:
        return Colors.black;
      case ForestCellState.eteint:
        return Colors.grey;
      case ForestCellState.inerte:
        return Colors.blue;
      default:
        return Colors.white;
    }
  }
}

enum ForestCellState {
  vide,
  inflammable,
  enFeu,
  enFeuAvance,
  brulee,
  eteint,
  inerte,
}

class ForestCell {
  final ForestCellState state;
  final int row;
  final int col;

  ForestCell(this.state, this.row, this.col);
}
