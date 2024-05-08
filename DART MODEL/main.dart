import 'dart:math';

// main
void main() {
  // Créer une grille représentant la forêt
  final forest = Forest(5, 5, 5);
  
  // Initialiser la forêt avec des arbres sains et quelques arbres en feu
  // Vous pouvez ajuster cela en fonction de la taille de votre grille
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
  // Initialize all cells to 'i' or 'v' based on the empty ratio
  grid = List.generate(
    rows,
    (i) => List.generate(columns, (j) {
      return Random().nextDouble() < emptyRatio
          ? ForestCell(ForestCellState.vide)
          : ForestCell(ForestCellState.inflammable);
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
        grid[randomRow][randomCol] = ForestCell(ForestCellState.enFeu);
        currentFireCells++;
      }
    }
  }


  void updateCell(int i, int j, List<List<ForestCell>> newGrid) {
    ForestCell currentCell = grid[i][j];

    double extinguishedChance = 0.3;

    if (currentCell.state == ForestCellState.enFeu) {
      // Si la cellule actuelle est en feu, elle passe à l'état enFeuAvance
      newGrid[i][j] = ForestCell(ForestCellState.enFeuAvance);
    } else if (currentCell.state == ForestCellState.enFeuAvance) {
      // Si la cellule est en feu avancé, elle brûle avec une certaine chance dans la méthode spreadFire
      newGrid[i][j] = ForestCell(ForestCellState.brulee); // propagation de feu uniquement sur la cellule actuelle
    } else if (currentCell.state == ForestCellState.brulee) {
      // Si la cellule est brûlée, elle peut être éteinte avec une certaine chance dans la méthode spreadFire
      if(Random().nextDouble() <= extinguishedChance){
        newGrid[i][j] = ForestCell(ForestCellState.eteint);
      } else {
        newGrid[i][j] = ForestCell(ForestCellState.brulee);
      }
    } else {
      newGrid[i][j] = currentCell;
    }
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
        updateCell(i, j, newGrid);
        if(grid[i][j].state == ForestCellState.inflammable){
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

    double fireChance = 0.125 * fireNeighborsCount; // 12.5% * number of fire neighbors

    if (Random().nextDouble() <= fireChance) {
      newGrid[i][j] = ForestCell(ForestCellState.enFeu);
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
