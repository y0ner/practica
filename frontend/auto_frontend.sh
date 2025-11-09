#!/bin/bash

# --- Colores para la salida ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

PROJECT_NAME="" # Variable global para el nombre del proyecto

# --- Funciones de Utilidad ---
print_msg() {
    echo -e "${BLUE}INFO:${NC} $1"
}

print_success() {
    echo -e "${GREEN}ÉXITO:${NC} $1"
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

clear_console() {
    clear
}

select_existing_project() {
    print_step "Seleccionar un proyecto existente"
    print_msg "Buscando proyectos (directorios) en la ubicación actual..."
    
    # Reemplazamos mapfile (bash-specific) con un bucle while read para compatibilidad con sh.
    projects=()
    while IFS= read -r line; do projects+=("$line"); done < <(find . -maxdepth 1 -mindepth 1 -type d -not -name ".*" -printf "%f\n")

    if [ ${#projects[@]} -eq 0 ]; then
        print_error "No se encontraron directorios de proyectos en la ubicación actual."
        print_msg "Por favor, primero crea un proyecto con la opción del menú."
        return 1
    fi

    echo "Se encontraron los siguientes proyectos:"
    i=0
    for dir in "${projects[@]}"; do
        echo "  $((i+1)). $dir"
        i=$((i+1))
    done

    read -p "Elige el número del proyecto en el que quieres trabajar: " choice
    # Validar que es un número y está en el rango
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#projects[@]} ]; then
        PROJECT_NAME="${projects[$((choice-1))]}"
        print_success "Proyecto activo establecido a: '$PROJECT_NAME'"
    else
        print_error "Selección no válida."
        return 1
    fi
}

# --- Funciones de Instalación (Basadas en tu tutorial) ---

check_prerequisites() {
    print_step "Verificando requisitos"
    command -v node >/dev/null 2>&1 || { print_error "Node.js no está instalado. Por favor, instálalo primero."; exit 1; }
    command -v ng >/dev/null 2>&1 || { print_error "Angular CLI no está instalado. Instálalo con 'npm install -g @angular/cli'."; exit 1; }
    print_success "Node.js y Angular CLI están instalados."
}

create_angular_project() {
    # Preguntar por el nombre del proyecto
    read -p "Introduce el nombre para el nuevo proyecto Angular: " project_name
    if [ -z "$project_name" ]; then
        print_error "El nombre del proyecto no puede estar vacío."
        return 1
    fi

    print_step "Creando proyecto Angular '$project_name'"
    if [ -d "$project_name" ]; then
        print_error "El directorio '$project_name' ya existe. Por favor, elimínalo o cámbiale el nombre."
        return 1
    fi

    # Creamos el proyecto como standalone y con routing
    ng new "$project_name" --routing=true --style=css --standalone=true --skip-install
    if [ $? -ne 0 ]; then
        print_error "Falló la creación del proyecto Angular."
        return 1
    fi
    
    # Establecer el nombre del proyecto globalmente
    PROJECT_NAME="$project_name"
    print_success "Proyecto activo establecido a: '$PROJECT_NAME'"

    cd "$PROJECT_NAME" || exit
    print_success "Proyecto '$project_name' creado. Instalando dependencias..."
    npm install
    print_success "Dependencias de Angular instaladas."
    cd ..
}

install_primeng() {
    print_step "Instalando PrimeNG y seleccionando un Tema (Método de la Guía)"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    cd "$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }

    print_msg "Instalando primeng y @primeuix/themes..."
    npm install primeng @primeuix/themes
    if [ $? -ne 0 ]; then
        print_error "Falló la instalación de PrimeNG."
        cd ..
        return 1
    fi

    # --- INICIO DE LA MODIFICACIÓN: MENÚ DE TEMAS ---
    print_msg "Por favor, elige un tema de PrimeNG para instalar:"
    options=("Aura" "Lara" "Nora" "Cancelar")
    
    # Variables para el tema elegido
    THEME_PRESET_NAME=""
    THEME_IMPORT_PATH=""

    select opt in "${options[@]}"; do
        case $opt in
            "Aura")
                THEME_PRESET_NAME="Aura"
                THEME_IMPORT_PATH="@primeuix/themes/aura"
                break
                ;;
            "Lara")
                THEME_PRESET_NAME="Lara"
                THEME_IMPORT_PATH="@primeuix/themes/lara"
                break
                ;;
            "Nora")
                THEME_PRESET_NAME="Nora"
                THEME_IMPORT_PATH="@primeuix/themes/nora"
                break
                ;;
            "Cancelar")
                print_error "Instalación de tema cancelada por el usuario."
                cd ..
                return 1
                ;;
            *) echo "Opción inválida $REPLY";;
        esac
    done
    # --- FIN DE LA MODIFICACIÓN: MENÚ DE TEMAS ---

    # --- INICIO DE LA NUEVA FUNCIONALIDAD: FORZAR TEMA CLARO ---
    print_msg "El tema '$THEME_PRESET_NAME' ha sido seleccionado."
    read -p "¿Deseas forzar un esquema de color claro para evitar inconsistencias con el modo oscuro del navegador? (s/n): " force_light_scheme

    THEME_CONFIG="theme: { preset: ${THEME_PRESET_NAME} }"
    if [[ "$force_light_scheme" =~ ^[sSyY]$ ]]; then
        print_msg "Forzando esquema de color claro en la configuración de PrimeNG..."
        # Sobrescribimos la configuración para añadir las opciones de darkMode
        THEME_CONFIG=$(cat <<EOC # Quitamos las comillas de 'EOC' para que las variables se expandan
theme: {
            preset: ${THEME_PRESET_NAME},
            options: {
                darkModeSelector: false
            }
        }
EOC
)
        print_success "Esquema de color claro forzado en app.config.ts."
    fi
    # --- FIN DE LA NUEVA FUNCIONALIDAD ---

    print_msg "Configurando PrimeNG en src/app/app.config.ts..."
    # Usamos un delimitador para poder expandir las variables THEME_PRESET_NAME y THEME_CONFIG
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

    cd ..
}

install_tailwind() {
    print_step "Instalando Tailwind CSS"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    cd "$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }
    
    npm install tailwindcss @tailwindcss/postcss postcss --force
    if [ $? -ne 0 ]; then
        print_error "Falló la instalación de Tailwind."
        cd ..
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
    
    # 1. Elimina cualquier línea de importación de tailwindcss existente para evitar duplicados
    grep -v "@import \"tailwindcss\";" src/styles.css > src/styles.css.tmp
    # 2. Añade la importación de tailwindcss al principio del archivo limpio
    (echo "@import \"tailwindcss\";"; cat src/styles.css.tmp) > src/styles.css

    print_success "Tailwind CSS instalado y configurado."
    cd ..
}

create_layout_components() {
    print_step "Creando componentes de Layout y actualizando App"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    print_msg "Trabajando en el proyecto: $PROJECT_NAME"
    cd "$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }

    print_msg "Generando componentes Header, Aside, y Footer..."
    ng g c components/layout/header
    ng g c components/layout/aside
    ng g c components/layout/footer
    
    # También creamos los archivos base de los componentes que mencionaste
    # para asegurarnos de que el contenido es exacto al de tu tutorial.
    print_msg "Sobrescribiendo archivos .ts de layout con tu plantilla..."

cat << 'EOF' > src/app/components/layout/aside/aside.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-aside',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './aside.html',
  styleUrl: './aside.css'
})
export class Aside {

}
EOF

cat << 'EOF' > src/app/components/layout/footer/footer.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-footer',
  standalone: true,
  imports: [],
  templateUrl: './footer.html',
  styleUrl: './footer.css'
})
export class Footer {

}
EOF

cat << 'EOF' > src/app/components/layout/header/header.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [],
  templateUrl: './header.html',
  styleUrl: './header.css'
})
export class Header {

}
EOF

    # AHORA CORREGIMOS EL APP PRINCIPAL
    print_msg "Actualizando src/app/app.ts"
    # Modificamos el app.ts para importar los componentes de layout (la guía usa app.ts, las nuevas versiones de CLI usan app.component.ts)
    cat << 'EOF' > src/app/app.ts
import { Component, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { Header } from './components/layout/header/header';
import { Footer } from './components/layout/footer/footer';
import { Aside } from './components/layout/aside/aside';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, Header, Footer, Aside],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  protected readonly title = signal('frontend');
}
EOF

    print_msg "Actualizando src/app/app.html"
    # Sobrescribimos el app.html con tu layout
    cat << 'EOF' > src/app/app.html
<main class="min-h-screen flex flex-col border-4 border-red-500">
  <header class="h-16 bg-white border-2 border-blue-500 flex items-center justify-center font-bold text-blue-600">
    <app-header></app-header>
  </header>

  <div class="flex flex-1">
    <aside class="w-64 bg-white border-2 border-blue-500 flex items-start justify-start font-bold text-blue-400">
      <app-aside></app-aside>
    </aside>

    <section class="flex-1 bg-white border-2 border-blue-500 flex items-center justify-center font-bold text-blue-600">
      <router-outlet />
    </section>
  </div>

  <footer class="h-16 bg-white border-2 border-blue-500 flex items-center justify-center font-bold text-blue-600 mt-auto">
    <app-footer></app-footer>
  </footer>
</main>
EOF

    print_success "Componentes de Layout creados y App actualizada (con nombres de archivo v20)."
    cd ..
}

implement_panel_menu() {
    print_step "Implementando PanelMenu de PrimeNG en Aside"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    print_msg "Trabajando en el proyecto: $PROJECT_NAME"
    cd "$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }

    # --- INICIO DE LA MODIFICACIÓN: MENÚ DINÁMICO ---
    read -p "Introduce el número de elementos de menú (tablas) que deseas crear: " num_tables
    if ! [[ "$num_tables" =~ ^[1-9][0-9]*$ ]]; then
        print_error "Por favor, introduce un número entero positivo."
        cd ..
        return 1
    fi

    declare -a table_names=()
    declare -a menu_items_array=()
    for (( i=1; i<=num_tables; i++ )); do
        read -p "Introduce el nombre para el elemento de menú #${i}: " table_name
        if [ -z "$table_name" ]; then
            print_error "El nombre no puede estar vacío."
            ((i--))
            continue
        fi

        table_names+=("$table_name")

        label="$(echo ${table_name:0:1} | tr '[:lower:]' '[:upper:]')${table_name:1}"
        
        # Construir el objeto JSON para el menú y añadirlo a un array
        menu_items_array+=( $(cat <<ITEM
{
    label: '${label}',
    icon: 'pi pi-fw pi-box'
}
ITEM
))
    done
    # --- FIN DE LA MODIFICACIÓN ---

    # Unir los items del menú con comas
    menu_items_str=$(IFS=,; echo "${menu_items_array[*]}")

    # --- INICIO DE LA CORRECCIÓN: Guardar nombres de tablas ---
    print_msg "Guardando nombres de las tablas en .table_names para uso futuro..."
    printf "%s\n" "${table_names[@]}" > .table_names
    # --- FIN DE LA CORRECCIÓN ---

    print_msg "Actualizando src/app/components/layout/aside/aside.html"
    cat << 'EOF' > src/app/components/layout/aside/aside.html
<div class="card flex justify-center">
    <p-panelmenu [model]="items" class="w-full md:w-80"></p-panelmenu>
</div>
EOF

    print_msg "Actualizando src/app/components/layout/aside/aside.ts con ${num_tables} elementos"
    # Usamos un delimitador para expandir la variable con los items del menú
    cat << END_OF_TS > src/app/components/layout/aside/aside.ts
import { Component, OnInit } from '@angular/core';
import { MenuItem } from 'primeng/api'; // Asegúrate de que PanelMenuModule esté importado si usas p-panelmenu
import { PanelMenuModule } from 'primeng/panelmenu';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-aside',
  standalone: true,
  imports: [CommonModule, PanelMenuModule],
  templateUrl: './aside.html',
  styleUrl: './aside.css'
})
export class Aside implements OnInit {
items: MenuItem[] | undefined;
ngOnInit() {
        this.items = [
            ${menu_items_str}
        ];
    }
}
END_OF_TS

    print_success "PanelMenu implementado en Aside (con nombres de archivo v20)."
    cd ..
}

create_crud_apis() {
    print_step "Generando componentes CRUD y rutas para las APIs"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    cd "$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }

    # Verificar si el archivo con los nombres de las tablas existe
    if [ ! -f ".table_names" ]; then
        print_error "No se encontró el archivo '.table_names'. Por favor, ejecuta primero el paso 'Implementar PanelMenu en Aside' (Opción 6 del menú anterior)."
        cd ..
        return 1
    fi

    # Leer los nombres de las tablas desde el archivo
    mapfile -t table_names < .table_names

    print_msg "Se generarán APIs para las siguientes tablas: ${table_names[*]}"

    declare -a all_imports_array=()
    declare -a all_routes_array=()
    declare -a menu_items_array=()

    # Generar componentes, rutas e imports para cada tabla
    for table_name in "${table_names[@]}"; do
        local lower_name="$table_name"
        local capitalized_name="$(echo ${lower_name:0:1} | tr '[:lower:]' '[:upper:]')${lower_name:1}"
        
        print_msg "Generando componentes CRUD para '$capitalized_name'..."
        ng g c "components/${lower_name}/getall"
        ng g c "components/${lower_name}/create"
        ng g c "components/${lower_name}/update"
        ng g c "components/${lower_name}/delete"

        # Acumular imports para app.routes.ts
        all_imports_array+=( "import { Getall as ${capitalized_name}Getall } from './components/${lower_name}/getall/getall.component';" )
        all_imports_array+=( "import { Create as ${capitalized_name}Create } from './components/${lower_name}/create/create.component';" )
        all_imports_array+=( "import { Update as ${capitalized_name}Update } from './components/${lower_name}/update/update.component';" )
        all_imports_array+=( "import { Delete as ${capitalized_name}Delete } from './components/${lower_name}/delete/delete.component';" )

        # Acumular rutas para app.routes.ts (usando el nombre en plural para la ruta)
        all_routes_array+=( "{ path: \"${lower_name}s\", component: ${capitalized_name}Getall }" )
        all_routes_array+=( "{ path: \"${lower_name}s/new\", component: ${capitalized_name}Create }" )
        all_routes_array+=( "{ path: \"${lower_name}s/edit/:id\", component: ${capitalized_name}Update }" )
        all_routes_array+=( "{ path: \"${lower_name}s/delete/:id\", component: ${capitalized_name}Delete }" )

        # Acumular items para el menú en aside.ts
        menu_items_array+=( $(cat <<ITEM
{
    label: '${capitalized_name}s',
    icon: 'pi pi-fw pi-box',
    routerLink: '/${lower_name}s'
}
ITEM
))
    done

    # Unir los elementos de los arrays con los separadores correctos
    local all_imports=$(printf "%s\n" "${all_imports_array[@]}")
    local all_routes=$(printf "    %s,\n" "${all_routes_array[@]}")
    # Quitar la última coma de las rutas
    all_routes=$(echo "${all_routes}" | sed 's/,$//')
    local menu_items_str=$(IFS=,; echo "${menu_items_array[*]}")

    print_msg "Actualizando src/app/app.routes.ts..."
    cat << EOF > src/app/app.routes.ts
import { Routes } from '@angular/router';

// Imports para todos los componentes CRUD
${all_imports}

export const routes: Routes = [
    { 
        path: '', 
        redirectTo: '/', 
        pathMatch: 'full' 
    },
${all_routes}
];
EOF

    print_msg "Actualizando el menú en src/app/components/layout/aside/aside.ts..."
    cat << EOF > src/app/components/layout/aside/aside.ts
import { Component, OnInit } from '@angular/core';
import { MenuItem } from 'primeng/api';
import { PanelMenuModule } from 'primeng/panelmenu';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-aside',
  standalone: true,
  imports: [CommonModule, PanelMenuModule, RouterLink],
  templateUrl: './aside.html',
  styleUrl: './aside.css'
})
export class Aside implements OnInit {
    items: MenuItem[] | undefined;
    ngOnInit() {
        this.items = [
${menu_items_str}
        ];
    }
}
EOF

    print_success "Componentes CRUD, rutas y menú actualizados correctamente."
    cd ..
}

run_all_steps() {
    print_step "EJECUTANDO TODOS LOS PASOS"
    check_prerequisites || return 1
    create_angular_project || return 1
    install_tailwind || return 1
    install_primeng || return 1
    create_layout_components || return 1
    implement_panel_menu || return 1

    print_success "¡Configuración completa del Frontend Básico terminada!"
    print_msg "Puedes iniciar el servidor con: cd ${PROJECT_NAME} && ng serve --open"
}

start_server() {
    print_step "Iniciando servidor de desarrollo"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    cd "$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }
    print_msg "Ejecutando 'ng serve --open'. Presiona CTRL+C para detener."
    ng serve --open
    cd ..
}

# --- Menú Principal ---
show_part1_menu() {
    while true; do
        
        echo -e "\n${YELLOW}===== SECCIÓN 1: Parte Básica con PrimeNG =====${NC}"
        echo "1. Verificar requisitos (Node, Angular CLI)"
        echo "2. Crear proyecto Angular (te pedirá un nombre)"
        echo "3. Instalar Tailwind CSS"
        echo "4. Instalar PrimeNG y Tema Aura"
        echo "5. Crear componentes de Layout (Header, Aside, Footer)"
        echo "6. Implementar PanelMenu en Aside"
        echo "7. ${GREEN}Ejecutar TODOS los pasos (1-6) de esta sección${NC}"
        echo "8. Iniciar servidor (ng s)"
        echo "9. Volver al Menú Principal"
        read -p "Elige una opción: " sub_choice

        case $sub_choice in
            1) check_prerequisites ;;
            2) create_angular_project ;;
            3) install_tailwind ;;
            4) install_primeng ;;
            5) create_layout_components ;;
            6) implement_panel_menu ;;
            7) run_all_steps ;;
            8) start_server ;;
            9) break ;;
            *) print_error "Opción no válida." ;;
        esac
        [ "$sub_choice" != "9" ] && [ "$sub_choice" != "8" ] && press_enter_to_continue
    done
}

main_menu() {
    while true; do
        
        echo -e "\n${BLUE}========== MENÚ DE AUTOMATIZACIÓN ==========${NC}"
        echo -e "Este script creará un directorio para tu proyecto en la"
        echo -e "ubicación actual (${YELLOW}$(pwd)${NC})."
        if [ -n "$PROJECT_NAME" ]; then
            echo -e "Proyecto activo: ${GREEN}$PROJECT_NAME${NC}"
        fi
        echo ""
        echo "1. Seleccionar un proyecto existente"
        echo "2. Parte Básica con PrimeNG (Crear y configurar proyecto)"
        echo "3. Generar APIs y Rutas CRUD (Frontend)"
        echo "4. Autenticación y Autorización (No implementado)"
        echo "5. CRUD Modelo Client (No implementado)"
        echo "6. Salir"
        read -p "Elige una sección: " choice

        case $choice in
            1) select_existing_project; press_enter_to_continue ;;
            2) show_part1_menu ;;
            3) create_crud_apis; press_enter_to_continue ;;
            4) print_msg "Sección 4 no implementada."; press_enter_to_continue ;;
            5) print_msg "Sección 5 no implementada."; press_enter_to_continue ;;
            6) echo "Saliendo..."; exit 0 ;;
            *) print_error "Opción no válida." ;;
        esac
    done
}

# --- Iniciar el script ---
main_menu
