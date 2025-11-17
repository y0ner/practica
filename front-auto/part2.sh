#!/bin/bash

# Este script actúa como un orquestador para la Parte 2.
# Carga todas las funciones necesarias desde los scripts modulares
# ubicados en el directorio 'part1/'.

# Obtener el directorio del script actual para hacer 'source' de forma relativa.
# Esto asegura que los scripts se encuentren sin importar desde dónde se llame al archivo principal.
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# --- Carga de Módulos de la Parte 2 (antes Parte 1) ---
# Se cargan los scripts en un orden lógico para asegurar que las dependencias
# (como las funciones de utilidad) estén disponibles cuando se necesiten.

source "$SCRIPT_DIR/part1/install.sh"
source "$SCRIPT_DIR/part1/layout.sh"
source "$SCRIPT_DIR/part1/menu.sh"
source "$SCRIPT_DIR/part1/orchestration.sh"