#!/bin/bash

# Obtener el directorio absoluto del script para que las rutas no se rompan
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Cargar utilidades (colores)
. "$SCRIPT_DIR/utils.sh"

echo -e "${CYAN}=======================================================${NC}"
echo -e "${CYAN}🚀 Paso 21: Actualizando el índice de rutas (src/routes/index.ts)${NC}"
echo -e "${CYAN}=======================================================${NC}"

# Directorio del proyecto (un nivel arriba del SCRIPT_DIR)
# Usar el directorio de trabajo actual como el directorio del proyecto
PROJECT_DIR=$(pwd)
# Ruta al archivo de índice de rutas
ROUTES_INDEX_PATH="$PROJECT_DIR/src/routes/index.ts"
ROUTES_DIR="$PROJECT_DIR/src/routes"

if [ ! -d "$ROUTES_DIR" ]; then
    echo -e "${RED}❌ Error: El directorio de rutas 'src/routes' no existe.${NC}"
    echo -e "${RED}Asegúrate de haber ejecutado los pasos anteriores para crear la estructura de carpetas y las rutas.${NC}"
    exit 1
fi

# --- Generar contenido para las rutas dinámicas ---

DYNAMIC_IMPORTS=""
DYNAMIC_PROPERTIES=""

# Buscar archivos .ts en src/routes, excluyendo index.ts y el directorio authorization
for file in $(find "$ROUTES_DIR" -maxdepth 1 -type f -name "*.ts" ! -name "index.ts"); do
    # Obtener el nombre base sin la extensión .ts (ej: client o Client)
    file_basename=$(basename "$file" .ts)

    # 1. Generar el nombre de la clase (ej: Client.Routes -> ClientRoutes)
    ClassName=$(echo "$file_basename" | sed 's/\.//g')

    # 2. Generar el nombre de la propiedad (ej: ClientRoutes -> clientRoutes)
    propName="$(tr '[:upper:]' '[:lower:]' <<< ${ClassName:0:1})${ClassName:1}"
	
    echo -e "${GREEN}🔎 Ruta encontrada: ${file_basename}.ts. Generando código...${NC}"

    # 3. Generar el import usando el nombre de archivo original
    # ej: import { ClientRoutes } from "./Client.Routes";
    DYNAMIC_IMPORTS+="import { ${ClassName} } from \"./${file_basename}\";\n"

    # 4. Generar la propiedad
    # ej: public clientRoutes: ClientRoutes = new ClientRoutes();
    DYNAMIC_PROPERTIES+="    public ${propName}: ${ClassName} = new ${ClassName}();\n"
done

if [ -z "$DYNAMIC_IMPORTS" ]; then
    echo -e "${YELLOW}⚠️ No se encontraron rutas de proyecto personalizadas en 'src/routes'. El archivo de índice solo contendrá las rutas de autorización.${NC}"
fi

# --- Contenido estático para las rutas de autorización ---

STATIC_CONTENT="
import { UserRoutes } from \"./authorization/user\";
import { RoleRoutes } from \"./authorization/role\";
import { RoleUserRoutes } from \"./authorization/role_user\";
import { RefreshTokenRoutes } from \"./authorization/refresh_token\";
import { ResourceRoutes } from \"./authorization/resource\";
import { ResourceRoleRoutes } from \"./authorization/resourceRole\";
import { AuthRoutes } from \"./authorization/auth\";

export class Routes {
${DYNAMIC_PROPERTIES}
    // --- Authorization Routes ---
    public userRoutes: UserRoutes = new UserRoutes();
    public roleRoutes: RoleRoutes = new RoleRoutes();
    public roleUserRoutes: RoleUserRoutes = new RoleUserRoutes();
    public refreshTokenRoutes: RefreshTokenRoutes = new RefreshTokenRoutes();
    public resourceRoutes: ResourceRoutes = new ResourceRoutes();
    public resourceRoleRoutes: ResourceRoleRoutes = new ResourceRoleRoutes();
    public authRoutes: AuthRoutes = new AuthRoutes();
}
"

# --- Escribir el archivo final ---

echo -e "import { Router } from \"express\";\n${DYNAMIC_IMPORTS}${STATIC_CONTENT}" > "$ROUTES_INDEX_PATH"

echo -e "\n${GREEN}✅ ¡Éxito! El archivo 'src/routes/index.ts' ha sido actualizado correctamente.${NC}"
echo -e "${YELLOW}-------------------------------------------------------${NC}"

# Preguntar si quiere ver el archivo
read -p "¿Deseas ver el contenido del archivo 'src/routes/index.ts' actualizado? (s/n): " view_file
if [[ "$view_file" == "s" || "$view_file" == "S" ]]; then
    echo -e "${YELLOW}--- Contenido de src/routes/index.ts ---${NC}"
    cat "$ROUTES_INDEX_PATH"
    echo -e "${YELLOW}----------------------------------------${NC}"
fi
    IFS='.'
    for part in $base_name; do
        class_name+="$(tr '[:lower:]' '[:upper:]' <<< ${part:0:1})${part:1}"
		prop_name+="$(tr '[:upper:]' '[:lower:]' <<< ${part:0:1})${part:1}"
    done
    unset IFS
    # Convertir a camelCase para la propiedad y el path (ej: client)
    prop_name=""
    class_name=""
    IFS='.'
    for part in $base_name; do
        prop_name+="$(tr '[:upper:]' '[:lower:]' <<< ${part:0:1})${part:1}"
		class_name+="$(tr '[:lower:]' '[:upper:]' <<< ${part:0:1})${part:1}"
    done
    unset IFS

    # Convertir a PascalCase para el nombre de la clase (ej: Client)
    #class_name="$(tr '[:lower:]' '[:upper:]' <<< ${base_name:0:1})${base_name:1}"
	
    echo -e "${GREEN}🔎 Ruta encontrada: ${base_name}.ts. Generando código...${NC}"

    # Generar import: import { ClientRoutes } from "./client"; (o el nombre original si es en minúsculas)
    DYNAMIC_IMPORTS+="import { ${class_name}Routes } from \"./${prop_name}\";\n"

    # Generar propiedad: public clientRoutes: ClientRoutes = new ClientRoutes();
    DYNAMIC_PROPERTIES+="    public ${prop_name}Routes: ${class_name}Routes = new ${class_name}Routes();\n"
done

if [ -z "$DYNAMIC_IMPORTS" ]; then
    echo -e "${YELLOW}⚠️ No se encontraron rutas de proyecto personalizadas en 'src/routes'. El archivo de índice solo contendrá las rutas de autorización.${NC}"
fi

# --- Contenido estático para las rutas de autorización ---

STATIC_CONTENT="
import { UserRoutes } from \"./authorization/user\";
import { RoleRoutes } from \"./authorization/role\";
import { RoleUserRoutes } from \"./authorization/role_user\";
import { RefreshTokenRoutes } from \"./authorization/refresh_token\";
import { ResourceRoutes } from \"./authorization/resource\";
import { ResourceRoleRoutes } from \"./authorization/resourceRole\";
import { AuthRoutes } from \"./authorization/auth\";

export class Routes {
${DYNAMIC_PROPERTIES}
    // --- Authorization Routes ---
    public userRoutes: UserRoutes = new UserRoutes();
    public roleRoutes: RoleRoutes = new RoleRoutes();
    public roleUserRoutes: RoleUserRoutes = new RoleUserRoutes();
    public refreshTokenRoutes: RefreshTokenRoutes = new RefreshTokenRoutes();
    public resourceRoutes: ResourceRoutes = new ResourceRoutes();
    public resourceRoleRoutes: ResourceRoleRoutes = new ResourceRoleRoutes();
    public authRoutes: AuthRoutes = new AuthRoutes();
}
"

# --- Escribir el archivo final ---

echo -e "import { Router } from \"express\";\n${DYNAMIC_IMPORTS}${STATIC_CONTENT}" > "$ROUTES_INDEX_PATH"

echo -e "\n${GREEN}✅ ¡Éxito! El archivo 'src/routes/index.ts' ha sido actualizado correctamente.${NC}"
echo -e "${YELLOW}-------------------------------------------------------${NC}"

# Preguntar si quiere ver el archivo
read -p "¿Deseas ver el contenido del archivo 'src/routes/index.ts' actualizado? (s/n): " view_file
if [[ "$view_file" == "s" || "$view_file" == "S" ]]; then
    echo -e "${YELLOW}--- Contenido de src/routes/index.ts ---${NC}"
    cat "$ROUTES_INDEX_PATH"
    echo -e "${YELLOW}----------------------------------------${NC}"
fi