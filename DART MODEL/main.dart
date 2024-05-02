import 'dart:math';

// main
void main() {
  // Créer une grille représentant la forêt
  final forest = Forest(3,3, 5);
  
  // Initialiser la forêt avec des arbres sains et quelques arbres en feu
  // Vous pouvez ajuster cela en fonction de la taille de votre grille
  forest.initializeForest(1, 0.9);

  // Effectuer la simulation pas à pas jusqu'à ce que les conditions d'arrêt soient remplies
  while (!forest.simulationComplete()) {
    // Mettre à jour l'état de la forêt pour une étape de simulation
    forest.updateForest();

    // Afficher la grille mise à jour
    print(forest.getString());
  }
}

// Classes
class Forest {
  int rows;
  int columns;
  int maxIterations;
  int currentIteration = 0;
  late List<List<ForestCell>> grid;

  Forest(this.rows, this.columns, this.maxIterations);

  ForestCell getCell(int row, int col) {
    return grid[row][col];
  }

  List<ForestCell> getNeighbors(row, col){
    List<ForestCell> neighbors = [];

    for (int i = row - 1; i <= row + 1; i++) {
        for (int j = col - 1; j <= col + 1; j++) {
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

  void initializeForest(int fireCell, num emptyRatio) {
    int totalCells = rows * columns;
    double fractionFireCell = fireCell / totalCells;

    grid = List.generate(
      rows,
      (i) => List.generate(columns, (j) {
        bool isFlammable = Random().nextDouble() < emptyRatio;
        if (isFlammable){
          if(Random().nextDouble() < fractionFireCell){
            return ForestCell(ForestCellState.enFeu);
          } else {
            return ForestCell(ForestCellState.inflammable);
          }
        } else {
          return ForestCell(ForestCellState.vide);
        }
      }),
    );
  }

  void updateForest() {
    List<List<ForestCell>> newGrid = List.generate(rows, (i) {
      return List.generate(columns, (j) {
        // Create a new ForestCell with the same state as the corresponding cell in the original grid
        return ForestCell(grid[i][j].state);
      });
    });


    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        ForestCell currentCell = grid[i][j];

        if (currentCell.state == ForestCellState.enFeu) {
          // Si la cellule actuelle est en feu, propagez le feu aux cellules adjacentes
          spreadFire4Directions(i, j, newGrid);
        } else {
          // Si la cellule est vide, elle ne peut pas devenir en feu
          newGrid[i][j] = currentCell;
        }
      }
    }

    // Remplacez la grille actuelle par la nouvelle grille mise à jour
    grid = newGrid;
    currentIteration++;
  }

  void spreadFire4Directions(int i, int j, List<List<ForestCell>> newGrid) {
    spreadFire(i, j, newGrid, -1, 0); // Up
    spreadFire(i, j, newGrid, 1, 0); // Down
    spreadFire(i, j, newGrid, 0, -1); // Left
    spreadFire(i, j, newGrid, 0, 1); // Right

  }

  void spreadFire(int i, int j, List<List<ForestCell>> newGrid, int dx, int dy) {
    int newRow = i + dx;
    int newColumn = j + dy;

    if (newRow >= 0 && newRow < rows && newColumn >= 0 && newColumn < columns) {
      ForestCell currentCell = getCell(i, j);
      ForestCellState currentState = currentCell.state;
      List<ForestCell> neighbors = getNeighbors(i, j);

      // Transition probabilities based on the current state
      double fireChance = 0.6;
      double extinguishedChance = 0.005;

      if(currentState != ForestCellState.vide) {
        for (var neighbor in neighbors) {
          ForestCellState neighborState = neighbor.state;
          if(neighborState != ForestCellState.vide) {
            double randomValue = Random().nextDouble();

            // Determine the new state based on the current state and transition probabilities
            ForestCellState newState;
            if (neighborState == ForestCellState.inflammable && randomValue <= fireChance) {
              newState = ForestCellState.enFeu;
            } else if (neighborState == ForestCellState.enFeu && randomValue <= fireChance) {
              newState = ForestCellState.enFeuAvance;
            } else if (neighborState == ForestCellState.enFeuAvance && randomValue <= fireChance) {
              newState = ForestCellState.brulee;
            } else if (neighborState == ForestCellState.brulee && randomValue <= extinguishedChance) {
              newState = ForestCellState.eteint;
            } else {
              // No transition, keep the current state
              newState = neighborState;
            }

            // Update the new grid with the determined state
            newGrid[newRow][newColumn] = ForestCell(newState);
          }
        }
      }
    }
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

  ForestCell(this.state);

  ForestCellState getForestState() {
    return state;
  }

  String getString(){
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
