#!/bin/bash

# Este archivo carga las funciones para el CRUD del cliente desde subarchivos modulares.
# La lógica de cada función se encuentra en la carpeta 'part4'.

# Obtener el directorio del script actual para hacer 'source' de forma relativa.
# Esto asegura que los scripts se encuentren sin importar desde dónde se llame al archivo principal.
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Cargar los sub-módulos en un orden que respete las dependencias.
# Las funciones de creación deben existir antes de que el menú intente llamarlas.
source "$SCRIPT_DIR/part4/models.sh"
source "$SCRIPT_DIR/part4/services.sh"
source "$SCRIPT_DIR/part4/components.sh"
source "$SCRIPT_DIR/part4/html.sh"
source "$SCRIPT_DIR/part4/routing.sh"
source "$SCRIPT_DIR/part4/menu.sh"
