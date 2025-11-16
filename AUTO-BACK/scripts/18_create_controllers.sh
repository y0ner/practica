#!/bin/bash

# ==========================================
# 1️⃣8️⃣ Crear Controladores de Proyecto
# Autor: Yoner
# ==========================================

MAIN_SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)
. "$MAIN_SCRIPT_DIR/scripts/utils.sh"

# --- Funciones para capitalizar y pluralizar ---
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

echo -e "${CYAN}--- Asistente para la Creación de Controladores ---${NC}"

MODEL_DIR="src/models"
CONTROLLER_DIR="src/controllers"

if [ ! -d "$MODEL_DIR" ]; then
    echo -e "${YELLOW}⚠️  El directorio de modelos '$MODEL_DIR' no existe. Crea primero los modelos (Opción 16).${NC}"
    pause
    exit 1
fi

mkdir -p "$CONTROLLER_DIR"

# Encuentra todos los archivos de modelo en el directorio raíz de models (ignora subdirectorios como 'authorization')
MODEL_FILES=$(find "$MODEL_DIR" -maxdepth 1 -type f -name "*.ts")

for model_file in $MODEL_FILES; do
    ModelName=$(basename "$model_file" .ts)

    echo -e "${YELLOW}Generando controlador para el modelo: $ModelName...${NC}"

    # Derivados del nombre
    modelName=$(tr '[:upper:]' '[:lower:]' <<< "$ModelName")
    modelNames=$(pluralize "$modelName")

    # Extraer la lista de atributos de la interfaz del modelo
    AttributeList=$(awk '/export interface .*I {/,/}/ {if (!/export|{|}|id|status/) {gsub(/:.*/, ""); print $1}}' "$model_file" | tr '\n' ',' | sed 's/,$//')

    # Lista completa para desestructurar req.body
    FullAttributeList="id,${AttributeList},status"

    # Plantilla del controlador
    read -r -d '' CONTROLLER_TEMPLATE <<EOF
import { Request, Response } from "express";
import { __ModelName__, __ModelName__I } from "../models/__ModelName__";

export class __ModelName__Controller {

  public async getAll__ModelName__s(req: Request, res: Response) {
    try {
      const __modelNames__: __ModelName__I[] = await __ModelName__.findAll({ where: { status: 'ACTIVE' } });
      res.status(200).json(__modelNames__);
    } catch (error) {
      res.status(500).json({ error: "Error fetching __modelName__s" });
    }
  }

  public async get__ModelName__ById(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;
      const __modelName__ = await __ModelName__.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (__modelName__) {
        res.status(200).json({__modelName__});
      } else {
        res.status(404).json({ error: "__ModelName__ not found or inactive" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error fetching __modelName__" });
    }
  }

  public async create__ModelName__(req: Request, res: Response) {
    const { __FullAttributeList__ } = req.body;
    try {
      let body: __ModelName__I = { __AttributeList__, status };
      const new__ModelName__ = await __ModelName__.create({ ...body });
      res.status(201).json(new__ModelName__);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async update__ModelName__(req: Request, res: Response) {
    const { id: pk } = req.params;
    const { __FullAttributeList__ } = req.body;
    try {
      let body: __ModelName__I = { __AttributeList__, status };
      const __modelName__Exist = await __ModelName__.findOne({ where: { id: pk, status: 'ACTIVE' } });

      if (__modelName__Exist) {
        await __modelName__Exist.update(body, { where: { id: pk } });
        res.status(200).json(__modelName__Exist);
      } else {
        res.status(404).json({ error: "__ModelName__ not found or inactive" });
      }
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async delete__ModelName__Adv(req: Request, res: Response) {
    const { id: pk } = req.params;
    try {
      const __modelName__ToUpdate = await __ModelName__.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (__modelName__ToUpdate) {
        await __modelName__ToUpdate.update({ status: 'INACTIVE' });
        res.status(200).json({ message: "__ModelName__ marked as inactive" });
      } else {
        res.status(404).json({ error: "__ModelName__ not found" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error marking __modelName__ as inactive" });
    }
  }
}
EOF

    # Reemplazar placeholders y guardar el archivo
    ControllerContent=$(echo "$CONTROLLER_TEMPLATE" | sed "s/__FullAttributeList__/$FullAttributeList/g" | sed "s/__AttributeList__/$AttributeList/g" | sed "s/getAll__ModelName__s/getAll${ModelName}s/g" | sed "s/get__ModelName__ById/get${ModelName}ById/g" | sed "s/create__ModelName__/create${ModelName}/g" | sed "s/update__ModelName__/update${ModelName}/g" | sed "s/delete__ModelName__Adv/delete${ModelName}Adv/g" | sed "s/__ModelName__/$ModelName/g" | sed "s/__modelName__/$modelName/g" | sed "s/__modelNames__/$modelNames/g")
    echo "$ControllerContent" > "${CONTROLLER_DIR}/${ModelName}.Controller.ts"
done

echo -e "${GREEN}✅ Proceso completado. Se han generado los controladores en '$CONTROLLER_DIR'.${NC}"
pause