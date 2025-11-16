#!/bin/bash

check_prerequisites() {
    print_step "Verificando requisitos"
    command -v node >/dev/null 2>&1 || { print_error "Node.js no está instalado. Por favor, instálalo primero."; exit 1; }
    command -v ng >/dev/null 2>&1 || { print_error "Angular CLI no está instalado. Instálalo con 'npm install -g @angular/cli'."; exit 1; }
    print_success "Node.js y Angular CLI están instalados."
}

install_primeng() {
    print_step "Instalando PrimeNG y seleccionando un Tema"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    cd "$PROJECTS_DIR/$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }

    print_msg "Instalando primeng y @primeuix/themes..."
    npm install primeng @primeuix/themes
    if [ $? -ne 0 ]; then
        print_error "Falló la instalación de PrimeNG."
        return 1
    fi

    print_msg "Por favor, elige un tema de PrimeNG para instalar:"
    options=("Aura" "Lara" "Nora" "Cancelar")
    
    THEME_PRESET_NAME=""
    THEME_IMPORT_PATH=""

    select opt in "${options[@]}"; do
        case $opt in
            "Aura") THEME_PRESET_NAME="Aura"; THEME_IMPORT_PATH="@primeuix/themes/aura"; break ;;
            "Lara") THEME_PRESET_NAME="Lara"; THEME_IMPORT_PATH="@primeuix/themes/lara"; break ;;
            "Nora") THEME_PRESET_NAME="Nora"; THEME_IMPORT_PATH="@primeuix/themes/nora"; break ;;
            "Cancelar") print_error "Instalación de tema cancelada."; return 1 ;;
            *) echo "Opción inválida $REPLY";;
        esac
    done

    print_msg "El tema '$THEME_PRESET_NAME' ha sido seleccionado."
    read -p "¿Deseas forzar un esquema de color claro? (s/n): " force_light_scheme

    THEME_CONFIG="theme: { preset: ${THEME_PRESET_NAME} }"
    if [[ "$force_light_scheme" =~ ^[sSyY]$ ]]; then
        print_msg "Forzando esquema de color claro..."
        THEME_CONFIG=$(cat <<EOC
theme: {
            preset: ${THEME_PRESET_NAME},
            options: { darkModeSelector: false }
        }
EOC
)
    fi

    print_msg "Configurando PrimeNG en src/app/app.config.ts..."
    cat << EOF_CONFIG > src/app/app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { providePrimeNG } from 'primeng/config';
import { ConfirmationService, MessageService } from 'primeng/api';
import ${THEME_PRESET_NAME} from '${THEME_IMPORT_PATH}';

import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideAnimationsAsync(),
    providePrimeNG({ ${THEME_CONFIG} }),
    ConfirmationService,
    MessageService
  ]
};
EOF_CONFIG

    cd - > /dev/null
}

install_tailwind() {
    print_step "Instalando Tailwind CSS"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    cd "$PROJECTS_DIR/$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }
    
    npm install tailwindcss @tailwindcss/postcss postcss --force
    if [ $? -ne 0 ]; then
        print_error "Falló la instalación de Tailwind."
        return 1
    fi

    print_msg "Creando .postcssrc.json"
    cat << 'EOF' > .postcssrc.json
{
  "plugins": {
    "@tailwindcss/postcss": {}
  }
}
EOF

    print_msg "Importando Tailwind en src/styles.css"
    
    grep -v "@import \"tailwindcss\";" src/styles.css > src/styles.css.tmp
    (echo "@import \"tailwindcss\";"; cat src/styles.css.tmp) > src/styles.css
    rm src/styles.css.tmp

    print_success "Tailwind CSS instalado y configurado."

    cd - > /dev/null
}