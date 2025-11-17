#!/bin/bash

# ==========================================
# 2️⃣0️⃣ Crear Rutas de Proyecto (Inteligentemente)
# Autor: Yoner
# ==========================================

MAIN_SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)
. "$MAIN_SCRIPT_DIR/scripts/utils.sh"

capitalize() {
    echo "$(tr '[:lower:]' '[:upper:]' <<< ${1:0:1})${1:1}"
}

pluralize() {
    local word=$1
    if [[ "$word" =~ [sS]$ ]]; then
        echo "${word}es"
    else
        echo "${word}s"
    fi
}

echo -e "${CYAN}--- Asistente para la Creación de Rutas ---${NC}"

MODEL_DIR="src/models"
CONTROLLER_DIR="src/controllers"
ROUTES_DIR="src/routes"

if [ ! -d "$MODEL_DIR" ]; then
    echo -e "${YELLOW}⚠️  El directorio de modelos '$MODEL_DIR' no existe. Crea primero los modelos (Opción 16).${NC}"
    pause
    exit 1
fi

mkdir -p "$ROUTES_DIR"

MODEL_FILES=$(find "$MODEL_DIR" -maxdepth 1 -type f -name "*.ts" ! -name "User.ts" ! -name "Role.ts")

for model_file in $MODEL_FILES; do
    ModelName=$(basename "$model_file" .ts)

    echo -e "${YELLOW}Generando rutas para el modelo: $ModelName...${NC}"
	
	# Convertir el nombre del modelo a PascalCase sin puntos
	PascalCaseModelName=""
	IFS='.'
	for part in $ModelName; do
		PascalCaseModelName+="$(tr '[:lower:]' '[:upper:]' <<< ${part:0:1})${part:1}"
	done
	unset IFS


    modelName=$(tr '[:upper:]' '[:lower:]' <<< "$ModelName")
    ModelNames=$(pluralize "$ModelName")

    RouteFileContent=$(cat <<EOF
import { Application } from "express";
import { ${ModelName}Controller } from "../controllers/${ModelName}.Controller";
import { authMiddleware } from "../middleware/auth";

export class ${ModelName}Routes {
  public ${modelName}Controller: ${ModelName}Controller = new ${ModelName}Controller();

  public routes(app: Application): void {
    // ================== RUTAS PÚBLICAS (EJEMPLO) ==================
    // Si necesitas rutas que no requieran autenticación, puedes añadirlas aquí
    // app.route("/api/${ModelNames}/public")
    //   .get(this.${modelName}Controller.getAll${ModelName}s);

    // ================== RUTAS CON AUTENTICACIÓN ==================
    app.route("/api/${ModelNames}")
      .get(authMiddleware, this.${modelName}Controller.getAll${ModelName}s)
      .post(authMiddleware, this.${modelName}Controller.create${ModelName});

    app.route("/api/${ModelNames}/:id")
      .get(authMiddleware, this.${modelName}Controller.get${ModelName}ById)
      .patch(authMiddleware, this.${modelName}Controller.update${ModelName});

    app.route("/api/${ModelNames}/:id/logic")
      .delete(authMiddleware, this.${modelName}Controller.delete${ModelName}Adv);
  }
}
EOF
)

    # Nota: El ejemplo original tenía rutas públicas y privadas duplicadas.
    # He generado las rutas privadas por defecto y he dejado las públicas como un ejemplo comentado
    # para que puedas descomentarlas si las necesitas. Esto evita la duplicidad.
    # También he omitido el ".delete" simple ya que el controlador genera un borrado lógico ".deleteAdv".
	
    echo "$RouteFileContent" > "${ROUTES_DIR}/${ModelName}.Routes.ts"
done

echo -e "${GREEN}✅ Proceso completado. Se han generado las rutas en '$ROUTES_DIR'.${NC}"
pause