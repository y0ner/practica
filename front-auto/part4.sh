#!/bin/bash

# Este script actúa como un orquestador para la Parte 4.
# Carga los módulos de autenticación desde el directorio 'part3/'.

# Obtener el directorio del script actual para hacer 'source' de forma relativa.
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# --- Carga de Módulos de la Parte 4 (antes Parte 3) ---
# Se cargan los scripts en un orden lógico para asegurar que las dependencias
# (como modelos y servicios) estén disponibles cuando otros scripts los necesiten.
source "$SCRIPT_DIR/part3/models.sh"
source "$SCRIPT_DIR/part3/services.sh"
source "$SCRIPT_DIR/part3/layout.sh"
source "$SCRIPT_DIR/part3/header.sh"
source "$SCRIPT_DIR/part3/config.sh"
source "$SCRIPT_DIR/part3/components.sh"
source "$SCRIPT_DIR/part3/routing.sh"

setup_authentication() {
    print_step "Implementando Autenticación y Autorización (JWT)"
    
    create_auth_model
    create_auth_service
    update_main_layout_for_auth
    update_header_for_auth
    configure_auth_providers_and_styles
    create_and_update_auth_components
    setup_auth_routing_and_guards
    
    print_success "Implementación de Autenticación y Autorización completada."
}