//import 'package:grid_world/grid_world.dart';
import 'dart:math';
void main() {
  // Créer une grille représentant la forêt
  final forest = Forest(100,100);

  // Initialiser la forêt avec des arbres sains et quelques arbres en feu
  // Vous pouvez ajuster cela en fonction de la taille de votre grille
  forest.initializeForest();

  // Effectuer la simulation pas à pas jusqu'à ce que les conditions d'arrêt soient remplies
  while (!forest.simulationComplete(forest)) {
    // Mettre à jour l'état de la forêt pour une étape de simulation
    forest.updateForest();

    // Afficher la grille mise à jour
    print(forest.grid);
  }
}

// Functions



// Classes



class Forest {
  int rows;
  int columns;
  late List<List<ForestCell>> grid;

  Forest(this.rows, this.columns);

  void initializeForest() {
    grid = List.generate(
      rows,
      (i) => List.generate(columns, (j) {
        // Initialisez chaque cellule de la grille avec un état initial aléatoire (inerte ou inflammable)
        return ForestCell(Random().nextBool() ? ForestCellState.inflammable : ForestCellState.inerte);
      }),
    );
  }

  void updateForest() {
    List<List<ForestCell>> newGrid = List.generate(rows, (index) => List.filled(columns, ForestCell(ForestCellState.inerte)));

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        ForestCell currentCell = grid[i][j];

        if (currentCell.state == ForestCellState.enFeu) {
          // Si la cellule actuelle est en feu, propagez le feu aux cellules adjacentes
          spreadFire(i, j, newGrid);
        } else if (currentCell.state == ForestCellState.inflammable) {
          // Si la cellule actuelle est inflammable, elle peut devenir en feu avec une probabilité de 0.3
          if (Random().nextDouble() <= 0.3) {
            newGrid[i][j] = ForestCell(ForestCellState.enFeu);
          } else {
            // Sinon, la cellule reste inflammable
            newGrid[i][j] = currentCell;
          }
        } else {
          // Si la cellule est inerte, elle ne peut pas devenir en feu
          newGrid[i][j] = currentCell;
        }
      }
    }

    // Remplacez la grille actuelle par la nouvelle grille mise à jour
    grid = newGrid;
  }

  void spreadFire(int i, int j, List<List<ForestCell>> newGrid) {
    // Propagation vers le haut
    if (i > 0) {
      if (grid[i - 1][j].state == ForestCellState.inflammable && Random().nextDouble() <= 0.6) {
        newGrid[i - 1][j] = ForestCell(ForestCellState.enFeu);
      } else if (grid[i - 1][j].state != ForestCellState.brulee) {
        newGrid[i - 1][j] = ForestCell(ForestCellState.brulee);
      }
    }
    // Propagation vers le bas
    if (i < rows - 1) {
      if (grid[i + 1][j].state == ForestCellState.inflammable && Random().nextDouble() <= 0.6) {
        newGrid[i + 1][j] = ForestCell(ForestCellState.enFeu);
      } else if (grid[i + 1][j].state != ForestCellState.brulee) {
        newGrid[i + 1][j] = ForestCell(ForestCellState.brulee);
      }
    }
    // Propagation vers la gauche
    if (j > 0) {
      if (grid[i][j - 1].state == ForestCellState.inflammable && Random().nextDouble() <= 0.6) {
        newGrid[i][j - 1] = ForestCell(ForestCellState.enFeu);
      } else if (grid[i][j - 1].state != ForestCellState.brulee) {
        newGrid[i][j - 1] = ForestCell(ForestCellState.brulee);
      }
    }
    // Propagation vers la droite
    if (j < columns - 1) {
      if (grid[i][j + 1].state == ForestCellState.inflammable && Random().nextDouble() <= 0.6) {
        newGrid[i][j + 1] = ForestCell(ForestCellState.enFeu);
      } else if (grid[i][j + 1].state != ForestCellState.brulee) {
        newGrid[i][j + 1] = ForestCell(ForestCellState.brulee);
      }
    }
  }

  bool simulationComplete() {
    // À implémenter : Déterminer si les conditions d'arrêt de la simulation sont remplies
    return false;
  }
}

enum ForestCellState {
  inflammable,
  enFeu,
  brulee,
  inerte,
}

class ForestCell {
  final ForestCellState state;

  ForestCell(this.state);

  ForestCellState getForestState() {
    return state;
  }
}
