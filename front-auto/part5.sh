#!/bin/bash

# Este archivo actúa como un orquestador para la Parte 5.
# Carga todas las funciones para el CRUD desde subarchivos modulares.

SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Cargar los sub-módulos en un orden que respete las dependencias.
source "$SCRIPT_DIR/part4/models.sh"
source "$SCRIPT_DIR/part4/services.sh"
source "$SCRIPT_DIR/part4/components.sh"
source "$SCRIPT_DIR/part4/html.sh"
source "$SCRIPT_DIR/part4/create_components.sh"
source "$SCRIPT_DIR/part4/update_components.sh"
source "$SCRIPT_DIR/part4/delete_components.sh"
source "$SCRIPT_DIR/part4/design_improvements.sh"
source "$SCRIPT_DIR/part4/routing.sh"
source "$SCRIPT_DIR/part4/menu.sh"