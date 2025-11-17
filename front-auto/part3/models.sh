#!/bin/bash

# Este archivo contiene la lógica para crear los modelos (interfaces) de autenticación.

create_auth_model() {
    print_step "Creando modelo en src/app/models/auth.ts"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No se ha seleccionado un proyecto."
        return 1
    fi
    
    local project_path="$PROJECTS_DIR/$PROJECT_NAME"
    mkdir -p "$project_path/src/app/models"

    cat << 'EOF' > "$project_path/src/app/models/auth.ts"
export interface LoginI {
  email: string;
  password: string;
}

export interface LoginResponseI {
  token: string;
  user: UserI;
}

export interface RegisterI {
  username: string;  
  email: string;
  password: string;
}

export interface RegisterResponseI {
  token: string;
  user: UserI;
}

export interface UserI {
  id: number;
  username:string;
  email: string;
  password: string;
  is_active: "ACTIVE" | "INACTIVE";
  avatar: string;
}
EOF

    print_success "Modelo 'auth.ts' creado correctamente."
}