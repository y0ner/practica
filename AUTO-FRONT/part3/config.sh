#!/bin/bash

# Este archivo contiene la lógica para configurar los providers (HttpClient)
# y los estilos (primeicons) necesarios para la autenticación.

configure_auth_providers_and_styles() {
    print_step "Configurando providers y estilos para autenticación"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No se ha seleccionado un proyecto."
        return 1
    fi

    local project_path="$PROJECTS_DIR/$PROJECT_NAME"
    cd "$project_path" || { print_error "No se pudo acceder al directorio del proyecto."; return 1; }

    print_msg "Corrigiendo app.config.ts para incluir provideHttpClient..."

    local THEME_PRESET_NAME=$(grep -oP "(?<=preset: )\w+" src/app/app.config.ts | head -n 1)
    local THEME_IMPORT_PATH=$(grep -oP "(?<=from ')[^']+(?=';)" src/app/app.config.ts | grep 'themes' | head -n 1)

    cat << EOF > src/app/app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { provideHttpClient } from '@angular/common/http';
import { providePrimeNG } from 'primeng/config';
import { ConfirmationService, MessageService } from 'primeng/api';
import ${THEME_PRESET_NAME} from '${THEME_IMPORT_PATH}';

import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideAnimationsAsync(),
    provideHttpClient(),
    providePrimeNG({ theme: { preset: ${THEME_PRESET_NAME}, options: { darkModeSelector: false } } }),
    ConfirmationService,
    MessageService
  ]
};
EOF
    print_success "app.config.ts ha sido corregido."

    print_msg "Instalando primeicons..."
    npm install primeicons

    print_msg "Importando primeicons en src/styles.css"
    if ! grep -q "primeicons.css" src/styles.css; then
        (echo '@import "primeicons/primeicons.css";'; cat src/styles.css) > src/styles.css.tmp && mv src/styles.css.tmp src/styles.css
        print_success "Primeicons importado en styles.css."
    fi

    cd - > /dev/null
}