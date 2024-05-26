# FireFlow

FireFlow est une application de simulation dynamique qui modélise la propagation du feu dans diverses conditions. Cette application permet aux utilisateurs d'ajuster des paramètres tels que l'humidité ou la direction du vent et d'observer comment ces changements affectent le comportement du feu. Elle est développée avec Flutter et peut être exécutée sur Windows uniquement pour l'instant.
<!-- TOC -->

- [FireFlow](#fireflow)
  - [Configuration système requise](#configuration-système-requise)
  - [Installation](#installation)
    - [Exécution du fichier exécutable](#exécution-du-fichier-exécutable)
    - [Compilation à partir du code source (optionnel)](#compilation-à-partir-du-code-source-optionnel)
  - [Utilisation](#utilisation)
    - [Démarrage de la simulation](#démarrage-de-la-simulation)
    - [Comprendre la visualisation](#comprendre-la-visualisation)
  - [Contact](#contact)
  - [To-Do List](#to-do-list)

<!-- /TOC -->
<!-- /TOC -->
- **Interface conviviale** : Contrôles simples pour démarrer, arrêter et réinitialiser les simulations.
- **Visualisation** : Différentes couleurs représentent divers états du feu et du terrain.

## Configuration système requise

- Windows 10 ou version ultérieure
- .NET Framework 4.8 ou version ultérieure

## Installation

### Exécution du fichier exécutable

1. **Télécharger le fichier zip** : Téléchargez le fichier `FireFlow.zip` depuis le répertoire `dist`.

2. **Extraire le fichier zip** :
   - Faites un clic droit sur `FireFlow.zip` et sélectionnez "Extraire tout..."
   - Choisissez un dossier de destination et extrayez le contenu.

3. **Exécuter l'application** :
   - Accédez au dossier extrait.
   - Double-cliquez sur `FireFlow.exe` pour démarrer l'application.

### Compilation à partir du code source (optionnel)

Si vous souhaitez compiler l'application à partir du code source, assurez-vous d'avoir les éléments suivants installés sur votre système :

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Outils de développement Windows](https://docs.microsoft.com/fr-fr/windows/apps/get-started/)

1. **Cloner le dépôt** :
    ```sh
    git clone https://github.com/yourusername/FireFlow.git
    cd FireFlow
    ```

2. **Compiler l'application** :
    ```sh
    flutter build windows
    ```


## Utilisation

### Démarrage de la simulation

1. Ouvrez l'application en exécutant `FireFlow.exe`.
2. Utilisez les curseurs pour ajuster les niveaux des conditions environnementales.
3. Cliquez sur "Lancer l'itération" pour démarrer la simulation. Cliquez de nouveau pour simuler d'autres itérations.
4. Cliquez sur "Revenir en arrière" pour revenir à l'itération précédente.
5. Utilisez le bouton "Redémarrer" pour réinitialiser la simulation à l'état initial.


### Comprendre la visualisation

- **Vide** : Marron
- **Fôret/Inflammable** : Vert
- **En Feu** : Orange
- **En Feu Avancé** : Rouge
- **Brûlée** : Noir
- **Éteinte** : Gris
- **Inerte** : Bleu

Ces couleurs représentent l'état de chaque cellule dans la grille de simulation.


## Contact

Pour toute question ou problème, veuillez ouvrir une issue sur le dépôt GitHub.

## To-Do List

- [ ] Ajouter la fonctionnalité de modification d'état (inerte)
- [ ] Utiliser des icônes à la place des cases pour une meilleure visualisation
- [ ] Prévoir un build pour d'autres plateformes

