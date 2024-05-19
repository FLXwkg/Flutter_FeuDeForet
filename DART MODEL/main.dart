import 'dart:math';

// main
void main() {
  // Créer une grille représentant la forêt(size, iterations, force du vent, direction du vent, humidite du sol)
  final forest = Forest(8, 5, 1, 'W', 0.9); // Minimum size is 16, here it should be at least 16x16
  
  // Initialiser la forêt avec des arbres sains et quelques arbres en feu(nb cases en feu, % de vide)
  forest.initializeForest(1, 0.1);
  print('Etat initial:\n');
  print(forest.getString());

  int idEtat = 1; 
  // Effectuer la simulation pas à pas jusqu'à ce que les conditions d'arrêt soient remplies
  while (!forest.simulationComplete()) {
    // Mettre à jour l'état de la forêt pour une étape de simulation
    forest.updateForest();

    // Afficher la grille mise à jour
    print('Etat ' + idEtat.toString());
    print(forest.getString());
    idEtat++;
  }
}

// Classes
class Forest {
  late int size;
  late int windStrength;
  late String windDirection;
  late double humidity;
  int maxIterations;
  int currentIteration = 0;
  late List<List<ForestCell>> grid;

  Forest(int size, this.maxIterations, int windStrength, String windDirection, double humidity) {
    this.size = size < 16 ? 16 : size;
    this.windStrength = [0, 1, 2, 3].contains(windStrength) ? windStrength : 0;
    this.windDirection = ['N','NE','E','SE','S','SW','W','NW'].contains(windDirection) ? windDirection : 'Aucune';
    this.humidity = [0.9, 0.6, 0.3, 0.1].contains(humidity) ? humidity : 0.9;
  }

  int get rows => size;
  int get columns => size;

  ForestCell getCell(int row, int col) {
    return grid[row][col];
  }

  List<ForestCell> getNeighbors(row, col) {
    List<ForestCell> neighbors = [];
    int maxNeighborsOffset = windStrength + 1;

    for (int i = row - maxNeighborsOffset; i <= row + maxNeighborsOffset; i++) {
      for (int j = col - maxNeighborsOffset; j <= col + maxNeighborsOffset; j++) {
        // Skip the cell itself
        if (i == row && j == col) {
          continue;
        }
        // Check if the neighboring cell is within the grid bounds
        if (i >= 0 && i < rows && j >= 0 && j < columns) {
          neighbors.add(getCell(i, j));
        }
      }
    }
    return neighbors;
  }

  void initializeForest(int fireCell, double emptyRatio) {
    // Initialize all cells to 'i' or 'v' based on the empty ratio
    grid = List.generate(
      rows,
      (i) => List.generate(columns, (j) {
        return Random().nextDouble() < emptyRatio
            ? ForestCell(ForestCellState.vide, i, j)
            : ForestCell(ForestCellState.inflammable, i, j);
      }),
    );

    // Get the desired number of 'e' cells
    int desiredFireCells = fireCell;
    int currentFireCells = 0;

    // Randomly select cells to change to 'e' until the desired number is reached
    while (currentFireCells < desiredFireCells) {
      int randomRow = Random().nextInt(rows);
      int randomCol = Random().nextInt(columns);

      // If the randomly selected cell is 'i', change it to 'e'
      if (grid[randomRow][randomCol].state == ForestCellState.inflammable) {
        grid[randomRow][randomCol] = ForestCell(ForestCellState.enFeu, randomRow, randomCol);
        currentFireCells++;
      }
    }
  }

  void updateCell(int i, int j, List<List<ForestCell>> newGrid) {
    ForestCell currentCell = grid[i][j];

    double extinguishedChance = 0.3;

    if (currentCell.state == ForestCellState.enFeu) {
      // Si la cellule actuelle est en feu, elle passe à l'état enFeuAvance
      newGrid[i][j] = ForestCell(ForestCellState.enFeuAvance, i, j);
    } else if (currentCell.state == ForestCellState.enFeuAvance) {
      // Si la cellule est en feu avancé, elle brûle avec une certaine chance dans la méthode spreadFire
      newGrid[i][j] = ForestCell(ForestCellState.brulee, i, j); // propagation de feu uniquement sur la cellule actuelle
    } else if (currentCell.state == ForestCellState.brulee) {
      // Si la cellule est brûlée, elle peut être éteinte avec une certaine chance dans la méthode spreadFire
      if (Random().nextDouble() <= extinguishedChance) {
        newGrid[i][j] = ForestCell(ForestCellState.eteint, i, j);
      } else {
        newGrid[i][j] = ForestCell(ForestCellState.brulee, i, j);
      }
    } else {
      newGrid[i][j] = currentCell;
    }
  }

  void updateForest() {
    List<List<ForestCell>> newGrid = List.generate(rows, (i) {
      return List.generate(columns, (j) {
        // Create a new ForestCell with the same state as the corresponding cell in the original grid
        return ForestCell(grid[i][j].state, i, j);
      });
    });

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        updateCell(i, j, newGrid);
        if (grid[i][j].state == ForestCellState.inflammable) {
          spreadFire8Directions(i, j, newGrid);
        }
      }
    }

    // Remplacez la grille actuelle par la nouvelle grille mise à jour
    grid = newGrid;
    currentIteration++;
  }

  void spreadFire8Directions(int i, int j, List<List<ForestCell>> newGrid) {
    List<ForestCell> neighbors = getNeighbors(i, j);
    int fireNeighborsCount = 0;

    for (var neighbor in neighbors) {
      if (neighbor.state == ForestCellState.enFeu ||
          neighbor.state == ForestCellState.enFeuAvance ||
          neighbor.state == ForestCellState.brulee) {
        fireNeighborsCount++;
      }
    }
    
    double fireChance = 0; // 12.5% * number of fire neighbors

    if (windStrength > 0 && windDirection != 'Aucune') {
      fireChance = applyWindEffect(i, j, neighbors, fireNeighborsCount);
    }

    if (Random().nextDouble() <= fireChance) {
      newGrid[i][j] = ForestCell(ForestCellState.enFeu, i, j);
    }
  }

  double applyWindEffect(int i, int j, List<ForestCell> neighbors, int fireNeighborsCount) {
    double newFireChance = (humidity/neighbors.length) * fireNeighborsCount;

    switch (windDirection) {
      case 'N':
        List<ForestCell> directionNeighbors = getNeighborsInDirection(i, j, 0, neighbors);
        newFireChance = adjustFireChanceFromDirection(directionNeighbors, newFireChance);
        break;
      case 'NE':
        List<ForestCell> directionNeighbors = getNeighborsInDirection(i, j, 1, neighbors);
        newFireChance = adjustFireChanceFromDirection(directionNeighbors, newFireChance);
        break;
      case 'E':
        List<ForestCell> directionNeighbors = getNeighborsInDirection(i, j, 2, neighbors);
        newFireChance = adjustFireChanceFromDirection(directionNeighbors, newFireChance);
        break;
      case 'SE':
        List<ForestCell> directionNeighbors = getNeighborsInDirection(i, j, 3, neighbors);
        newFireChance = adjustFireChanceFromDirection(directionNeighbors, newFireChance);
        break;
      case 'S':
        List<ForestCell> directionNeighbors = getNeighborsInDirection(i, j, 4, neighbors);
        newFireChance = adjustFireChanceFromDirection(directionNeighbors, newFireChance);
        break;
      case 'SW':
        List<ForestCell> directionNeighbors = getNeighborsInDirection(i, j, 5, neighbors);
        newFireChance = adjustFireChanceFromDirection(directionNeighbors, newFireChance);
        break;
      case 'W':
        List<ForestCell> directionNeighbors = getNeighborsInDirection(i, j, 6, neighbors);
        newFireChance = adjustFireChanceFromDirection(directionNeighbors, newFireChance);
        break;
      case 'NW':
        List<ForestCell> directionNeighbors = getNeighborsInDirection(i, j, 7, neighbors);
        newFireChance = adjustFireChanceFromDirection(directionNeighbors, newFireChance);
        break;
      default:
        break;
    }

    return newFireChance;
  }

  double adjustFireChanceFromDirection(List<ForestCell> directionNeighbors, double fireChance) {
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


  List<ForestCell> getNeighborsInDirection(int row, int col, int direction, List<ForestCell> neighbors) {
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
        }
      }
    }

    return neighborsInDirection;
  }


  bool simulationComplete() {
    return currentIteration >= maxIterations;
  }

  String getString() {
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        buffer.write(grid[i][j].getString());
      }
      buffer.writeln(); // Saut de ligne à la fin de chaque ligne
    }
    return buffer.toString();
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

  ForestCellState getForestState() {
    return state;
  }

  String getString() {
    switch (state) {
      case ForestCellState.vide:
        return 'v';
      case ForestCellState.inflammable:
        return 'i';
      case ForestCellState.enFeu:
        return 'e';
      case ForestCellState.enFeuAvance:
        return 'a';
      case ForestCellState.brulee:
        return 'b';
      case ForestCellState.eteint:
        return 'z';
      case ForestCellState.inerte:
        return 'n';
    }
  }
}
