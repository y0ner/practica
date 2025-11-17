#!/bin/bash

# --- Colores para la salida ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

# --- Funciones de Utilidad ---
print_msg() {
    echo -e "${BLUE}INFO:${NC} $1"
}

print_success() {
    echo -e "${GREEN}ÉXITO:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}AVISO:${NC} $1"
}

# Alias para print_msg, para mantener la consistencia si se usa en otros scripts.
print_info() {
    print_msg "$1"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

print_step() {
    echo -e "\n${YELLOW}--- PASO: $1 ---${NC}"
}

press_enter_to_continue() {
    read -p "Presiona Enter para continuar..."
}