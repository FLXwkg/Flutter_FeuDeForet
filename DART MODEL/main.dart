//import 'package:grid_world/grid_world.dart';

void main() {
  // Créer une grille représentant la forêt
  final forest = Forest(100,100);

  // Initialiser la forêt avec des arbres sains et quelques arbres en feu
  // Vous pouvez ajuster cela en fonction de la taille de votre grille
  initializeForest(forest);

  // Effectuer la simulation pas à pas jusqu'à ce que les conditions d'arrêt soient remplies
  while (!simulationComplete(forest)) {
    // Mettre à jour l'état de la forêt pour une étape de simulation
    updateForest(forest);

    // Afficher la grille mise à jour
    print(forest);
  }
}

// Functions

void initializeForest(Forest forest) {
  // À implémenter : Remplir la grille
}

void updateForest(Forest forest) {
  // À implémenter : Mettre à jour l'état de la forêt pour une étape de simulation
}

bool simulationComplete(Forest forest) {
  // À implémenter : Déterminer si les conditions d'arrêt de la simulation sont remplies
  return false;
}

// Classes

class Forest {
  int rows;
  int columns;
  Forest(this.rows, this.columns);
}

class ForestTile {
  ForestTile();
}
