#!/bin/bash

# Este script actúa como un orquestador para la Parte 3.
# Carga los módulos necesarios desde el directorio 'part3/'.

# Obtener el directorio del script actual para hacer 'source' de forma relativa.
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# --- Carga de Módulos de la Parte 3 (antes Parte 2) ---
source "$SCRIPT_DIR/part2/routing.sh" # La ruta interna sigue siendo part2