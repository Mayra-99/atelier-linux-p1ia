#!/bin/bash
# ============================================================
# setup_project.sh
# Atelier Linux - p1IA - Sonatel Academy
# Groupe P3 : Maimouna Diallo, Adama, Fatou, Fallou
#
# Ce script automatise la préparation complète d'un environnement
# Linux pour un projet d'intelligence artificielle :
#   1) Demande le nom du projet
#   2) Crée l'arborescence complète du projet
#   3) Crée un fichier de configuration
#   4) Installe les outils nécessaires
#   5) Télécharge le dataset de travail
#   6) Compresse le projet (sauvegarde)
#   7) Affiche un résumé de l'installation
# ============================================================

# --- Couleurs pour un affichage plus lisible ---
VERT='\033[0;32m'
ROUGE='\033[0;31m'
NC='\033[0m' # pas de couleur

# --- Variables globales (remplies au fil du script) ---
STATUT_ARBO="ECHEC"
STATUT_CONFIG="ECHEC"
STATUT_LOGICIELS="ECHEC"
STATUT_DATASET="ECHEC"
ARCHIVE_PATH=""

# URL du dataset utilisé pour l'atelier (jeu de données Iris)
DATASET_URL="https://raw.githubusercontent.com/mwaskom/seaborn-data/master/iris.csv"

# ------------------------------------------------------------
# Étape 1 : demander le nom du projet
# ------------------------------------------------------------
echo "=========================================="
echo " Préparation d'un environnement Linux pour un projet IA"
echo "=========================================="
read -p "Nom du projet : " PROJET

# Sécurité : si l'utilisateur ne tape rien, on impose un nom par défaut
if [ -z "$PROJET" ]; then
  PROJET="IA_Project"
  echo "Aucun nom saisi : le projet s'appellera '$PROJET' par défaut."
fi

# ------------------------------------------------------------
# Étape 2 : créer l'arborescence complète du projet
# ------------------------------------------------------------
echo ""
echo "--- Création de l'arborescence ---"

mkdir -p "$PROJET/datasets/brut"
mkdir -p "$PROJET/datasets/clean"
mkdir -p "$PROJET/config"
mkdir -p "$PROJET/logs"
mkdir -p "$PROJET/scripts"
mkdir -p "$PROJET/models"
mkdir -p "$PROJET/api"
mkdir -p "$PROJET/backup"
mkdir -p "$PROJET/documentation"
mkdir -p "$PROJET/shared"

# Vérification : le dossier racine existe-t-il bien ?
if [ -d "$PROJET" ]; then
  STATUT_ARBO="OK"
  echo -e "${VERT}Arborescence créée avec succès.${NC}"
else
  echo -e "${ROUGE}Erreur lors de la création de l'arborescence.${NC}"
fi

# ------------------------------------------------------------
# Étape 3 : créer un fichier de configuration
# ------------------------------------------------------------
echo ""
echo "--- Création du fichier de configuration ---"

CONFIG_FILE="$PROJET/config/settings.conf"

cat > "$CONFIG_FILE" << EOF
PROJECT_NAME=$PROJET
DATA_PATH=datasets/brut
MODEL_PATH=models
LOG_LEVEL=INFO
API_PORT=8000
AUTHOR=Groupe_P3
DATE_CREATION=$(date +%Y-%m-%d)
EOF

if [ -f "$CONFIG_FILE" ]; then
  STATUT_CONFIG="OK"
  echo -e "${VERT}Fichier de configuration créé : $CONFIG_FILE${NC}"
else
  echo -e "${ROUGE}Erreur lors de la création du fichier de configuration.${NC}"
fi

# ------------------------------------------------------------
# Étape 4 : installer les outils nécessaires
# ------------------------------------------------------------
echo ""
echo "--- Installation des outils ---"

OUTILS="git curl wget htop tree python3 python3-pip unzip"

sudo apt update -y > /dev/null 2>&1
sudo apt install -y $OUTILS > /dev/null 2>&1

# Vérification : on teste que chaque outil répond bien à --version
ECHEC_INSTALL=0
for outil in git curl wget htop tree python3 pip3 unzip
do
  if ! command -v "$outil" > /dev/null 2>&1; then
    echo -e "${ROUGE}Attention : $outil n'a pas pu être vérifié.${NC}"
    ECHEC_INSTALL=1
  fi
done

if [ $ECHEC_INSTALL -eq 0 ]; then
  STATUT_LOGICIELS="OK"
  echo -e "${VERT}Tous les outils sont installés et disponibles.${NC}"
fi

# ------------------------------------------------------------
# Étape 5 : télécharger le dataset
# ------------------------------------------------------------
echo ""
echo "--- Téléchargement du dataset ---"

DATASET_FILE="$PROJET/datasets/brut/iris.csv"
curl -s -o "$DATASET_FILE" "$DATASET_URL"

if [ -s "$DATASET_FILE" ]; then
  STATUT_DATASET="OK"
  echo -e "${VERT}Dataset téléchargé : $DATASET_FILE${NC}"
else
  echo -e "${ROUGE}Erreur : le dataset n'a pas pu être téléchargé.${NC}"
fi

# ------------------------------------------------------------
# Étape 6 : compresser le projet (sauvegarde)
# ------------------------------------------------------------
echo ""
echo "--- Compression du projet ---"

ARCHIVE_PATH="$PROJET/backup/${PROJET}.tar.gz"
tar -czf "$ARCHIVE_PATH" "$PROJET" 2> /dev/null

if [ -f "$ARCHIVE_PATH" ]; then
  echo -e "${VERT}Archive créée : $ARCHIVE_PATH${NC}"
else
  ARCHIVE_PATH="échec de la création"
  echo -e "${ROUGE}Erreur lors de la compression du projet.${NC}"
fi

# ------------------------------------------------------------
# Étape 7 : afficher un résumé de l'installation
# ------------------------------------------------------------
echo ""
echo "=========================================="
echo " Projet créé"
echo " Nom            : $PROJET"
echo " Arborescence   : $STATUT_ARBO"
echo " Fichier config : $STATUT_CONFIG"
echo " Logiciels      : $STATUT_LOGICIELS"
echo " Dataset        : $STATUT_DATASET"
echo " Archive        : $ARCHIVE_PATH"
echo " Installation terminée."
echo "=========================================="

exit 0
