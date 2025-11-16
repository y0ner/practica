#!/bin/bash

# ==========================================
# 1️⃣6️⃣ Crear Modelos de Sequelize (Interactivo)
# Autor: Yoner
# ==========================================

# Obtener el directorio absoluto del script principal
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

# --- Declaración de arrays asociativos para almacenar la estructura ---
declare -A tables
declare -A attributes # Formato: TableName_AttrName="Type;allowNull"
declare -A table_attribute_order # Formato: TableName="attr1 attr2 attr3"
declare -A relationships

# --- Inicio del Proceso Interactivo ---

echo -e "${CYAN}--- Asistente para la Creación de Modelos Sequelize ---${NC}"

# 1. Preguntar cuántas tablas crear
read -p "Número de tablas a crear: " num_tables

if ! [[ "$num_tables" =~ ^[0-9]+$ ]] || [ "$num_tables" -le 0 ]; then
    echo -e "${YELLOW}Número inválido. Saliendo.${NC}"
    exit 1
fi

# 2. Definir cada tabla y sus atributos
table_names=()
for (( i=1; i<=num_tables; i++ )); do
    echo -e "${YELLOW}--- Definiendo Tabla $i/$num_tables ---${NC}"
    read -p "Nombre de la tabla (en singular, ej: Client): " table_name
    table_name=$(capitalize "$table_name")
    table_attribute_order["$table_name"]=""
    table_names+=("$table_name")

    read -p "¿Cuántos atributos tiene '$table_name' (excluyendo id y status)? " attr_count

    for (( j=1; j<=attr_count; j++ )); do
        echo -e "${CYAN}  --- Atributo $j/$attr_count ---${NC}"
        read -p "  Nombre del atributo (ej: name, sale_date): " attr_name
        
        echo "  Tipos de datos disponibles:"
        echo "  1) STRING   2) TEXT     3) INTEGER"
        echo "  4) BIGINT   5) FLOAT    6) DATE"
        echo "  7) BOOLEAN  8) ENUM"
        read -p "  Selecciona el tipo de dato: " type_choice
        read -p "  ¿Puede ser nulo (allowNull: true)? (s/n): " nullable_choice

        case $type_choice in
            1) attr_type="STRING";;
            2) attr_type="TEXT";;
            3) attr_type="INTEGER";;
            4) attr_type="BIGINT";;
            5) attr_type="FLOAT";;
            6) attr_type="DATE";;
            7) attr_type="BOOLEAN";;
            8) attr_type="ENUM(\"ACTIVE\", \"INACTIVE\")";; # Ejemplo
            *) attr_type="STRING";;
        esac

        if [[ "$nullable_choice" == "s" || "$nullable_choice" == "S" ]]; then
            allow_null="true"
        else
            allow_null="false"
        fi

        # Guardar atributo: "TableName_AttrName=Type;allowNull"
        attributes["${table_name}_${attr_name}"]="${attr_type};${allow_null}"
        table_attribute_order["$table_name"]+="${attr_name} "
    done
done

echo -e "${GREEN}✅ Todas las tablas y atributos han sido definidos.${NC}"

# 3. Definir relaciones
for table_name in "${table_names[@]}"; do
    read -p "¿La tabla '$table_name' es PADRE en alguna relación? (s/n): " has_relation
    if [[ "$has_relation" == "s" || "$has_relation" == "S" ]]; then
        echo "  Tipos de relación:"
        echo "  1) One-to-Many (1:N) (ej: Client -> Sale)"
        echo "  2) Many-to-Many (N:M) (ej: Post -> Tag a través de una tabla pivote)"
        read -p "  Selecciona el tipo de relación: " rel_type

        other_tables=("${table_names[@]}")
        # Eliminar la tabla actual de la lista de opciones
        other_tables=(${other_tables[@]/$table_name}) 

        echo "  Selecciona la tabla HIJA (o la otra tabla principal en N:M):"
        select other_table in "${other_tables[@]}"; do
            if [ -n "$other_table" ]; then
                break
            fi
        done

        if [[ "$rel_type" == "1" ]]; then # One-to-Many
            # Guardar relación: "ParentTable_ChildTable=1:N"
            relationships["${table_name}_${other_table}"]="1:N"
            # Añadir el campo de clave foránea al modelo hijo
            fk_name="$(tr '[:upper:]' '[:lower:]' <<< "$table_name")_id"
            attributes["${other_table}_${fk_name}"]="INTEGER;false" # FKs no suelen ser nulas
            table_attribute_order["$other_table"]+="${fk_name} "

        elif [[ "$rel_type" == "2" ]]; then # Many-to-Many
            read -p "  Nombre de la tabla PIVOTE (ej: ProductSale): " pivot_table
            pivot_table=$(capitalize "$pivot_table")
            # Guardar relación: "Table1_Table2=N:M_PivotTable"
            relationships["${table_name}_${other_table}"]="N:M_${pivot_table}"
        fi
    fi
done

echo -e "${GREEN}✅ Todas las relaciones han sido definidas.${NC}"

# 4. Generar los archivos de modelo
echo -e "${CYAN}--- Generando archivos de modelo en src/models/ ---${NC}"
mkdir -p src/models

for table_name in "${table_names[@]}"; do
    model_file="src/models/${table_name}.ts"
    echo "Generando $model_file..."

    # Obtener la lista ordenada de atributos para la tabla actual
    ordered_attrs=(${table_attribute_order["$table_name"]})

    # --- Construir los imports ---
    imports_for_relations=""
    for rel_key in "${!relationships[@]}"; do
        parent=${rel_key%_*}
        child=${rel_key#*_}
        if [[ "$parent" == "$table_name" || "$child" == "$table_name" ]]; then
            # Importar el otro modelo de la relación
            other_model=$([[ "$parent" == "$table_name" ]] && echo "$child" || echo "$parent")
            imports_for_relations+="import { ${other_model} } from \"./${other_model}\";\n"
        fi
    done

    # --- Construir el contenido del archivo ---
    file_content="import { DataTypes, Model } from \"sequelize\";\n"
    file_content+="import { sequelize } from \"../database/db\";\n"
    file_content+="${imports_for_relations}\n"

    # Interfaz
    interface_content="export interface ${table_name}I {\n  id?: number;\n"
    for attr_name in "${ordered_attrs[@]}"; do
        key="${table_name}_${attr_name}"
        attr_info=${attributes[$key]}
        attr_type=${attr_info%;*}
        ts_type="string"
        if [[ "$attr_type" == "INTEGER" || "$attr_type" == "BIGINT" || "$attr_type" == "FLOAT" ]]; then
            ts_type="number"
        elif [[ "$attr_type" == "DATE" ]]; then
            ts_type="Date"
        elif [[ "$attr_type" == "BOOLEAN" ]]; then
            ts_type="boolean"
        fi
        interface_content+="  ${attr_name}: ${ts_type};\n"
    done
    interface_content+="  status: \"ACTIVE\" | \"INACTIVE\";\n}\n\n"
    file_content+=$interface_content

    # Clase
    class_content="export class ${table_name} extends Model<${table_name}I> implements ${table_name}I {\n"
    for attr_name in "${ordered_attrs[@]}"; do
        key="${table_name}_${attr_name}"
        attr_info=${attributes[$key]}
        attr_type=${attr_info%;*}
        ts_type="string"
        if [[ "$attr_type" == "INTEGER" || "$attr_type" == "BIGINT" || "$attr_type" == "FLOAT" ]]; then
            ts_type="number"
        elif [[ "$attr_type" == "DATE" ]]; then
            ts_type="Date"
        elif [[ "$attr_type" == "BOOLEAN" ]]; then
            ts_type="boolean"
        fi
        class_content+="  public ${attr_name}!: ${ts_type};\n"
    done
    class_content+="  public status!: \"ACTIVE\" | \"INACTIVE\";\n}\n\n"
    file_content+=$class_content

    # Init
    init_content="${table_name}.init(\n  {\n"
    for attr_name in "${ordered_attrs[@]}"; do
        key="${table_name}_${attr_name}"
        attr_info=${attributes[$key]}
        attr_type=${attr_info%;*}
        allow_null=${attr_info#*;}
        init_content+="    ${attr_name}: {\n      type: DataTypes.${attr_type},\n      allowNull: ${allow_null}\n    },\n"
    done
    init_content+="    status: {\n      type: DataTypes.ENUM(\"ACTIVE\", \"INACTIVE\"),\n      defaultValue: \"ACTIVE\",\n    },\n"
    init_content+="  },\n"
    
    table_name_lower=$(pluralize "$(tr '[:upper:]' '[:lower:]' <<< "$table_name")")
    init_content+="  {\n    sequelize,\n    modelName: \"${table_name}\",\n    tableName: \"${table_name_lower}\",\n    timestamps: false,\n  }\n);\n\n"
    file_content+=$init_content

    # Relaciones
    relation_content=""
    for rel_key in "${!relationships[@]}"; do
        parent=${rel_key%_*}
        child=${rel_key#*_}
        rel_type=${relationships[$rel_key]}

        # Si la tabla actual es el PADRE de una relación 1:N, se generan ambas asociaciones aquí.
        if [[ "$parent" == "$table_name" && "$rel_type" == "1:N" ]]; then
            fk_name="$(tr '[:upper:]' '[:lower:]' <<< "$parent")_id"
            relation_content+="${parent}.hasMany(${child}, {\n  foreignKey: \"${fk_name}\",\n  sourceKey: \"id\",\n});\n"
            relation_content+="${child}.belongsTo(${parent}, {\n  foreignKey: \"${fk_name}\",\n  targetKey: \"id\",\n});\n\n"
        fi

        # Si la tabla actual es parte de una relación N:M
        if [[ "$rel_type" == "N:M_"* ]]; then
            pivot_table=${rel_type#*N:M_}
            if [[ "$parent" == "$table_name" ]]; then
                relation_content+="${parent}.belongsToMany(${child}, { through: \"${pivot_table}\" });\n"
            elif [[ "$child" == "$table_name" ]]; then
                relation_content+="${child}.belongsToMany(${parent}, { through: \"${pivot_table}\" });\n"
            fi
        fi
    done

    file_content+=$relation_content

    # Escribir el archivo
    echo -e "$file_content" > "$model_file"
done

echo -e "${GREEN}✅ Proceso completado. Se han generado los modelos en 'src/models/'.${NC}"
pause
            ts_type="string"
            if [[ "$attr_type" == "INTEGER" || "$attr_type" == "BIGINT" || "$attr_type" == "FLOAT" ]]; then
                ts_type="number"
            elif [[ "$attr_type" == "DATE" ]]; then
                ts_type="Date"
            elif [[ "$attr_type" == "BOOLEAN" ]]; then
                ts_type="boolean"
            fi
            interface_content+="  ${attr_name}: ${ts_type};\n"
        fi
    done
    interface_content+="  status: \"ACTIVE\" | \"INACTIVE\";\n}\n\n"
    file_content+=$interface_content

    # Clase
    class_content="export class ${table_name} extends Model<${table_name}I> implements ${table_name}I {\n"
    for key in "${!attributes[@]}"; do
        if [[ $key == "${table_name}_"* ]]; then
            attr_name=${key#*_}
            attr_type=${attributes[$key]}
            ts_type="string"
            if [[ "$attr_type" == "INTEGER" || "$attr_type" == "BIGINT" || "$attr_type" == "FLOAT" ]]; then
                ts_type="number"
            elif [[ "$attr_type" == "DATE" ]]; then
                ts_type="Date"
            elif [[ "$attr_type" == "BOOLEAN" ]]; then
                ts_type="boolean"
            fi
            class_content+="  public ${attr_name}!: ${ts_type};\n"
        fi
    done
    class_content+="  public status!: \"ACTIVE\" | \"INACTIVE\";\n}\n\n"
    file_content+=$class_content

    # Init
    init_content="${table_name}.init(\n  {\n"
    for key in "${!attributes[@]}"; do
        if [[ $key == "${table_name}_"* ]]; then
            attr_name=${key#*_}
            attr_type=${attributes[$key]}
            init_content+="    ${attr_name}: {\n      type: DataTypes.${attr_type},\n      allowNull: false\n    },\n"
        fi
    done
    init_content+="    status: {\n      type: DataTypes.ENUM(\"ACTIVE\", \"INACTIVE\"),\n      defaultValue: \"ACTIVE\",\n    },\n"
    init_content+="  },\n"
    
    table_name_lower=$(pluralize "$(tr '[:upper:]' '[:lower:]' <<< "$table_name")")
    init_content+="  {\n    sequelize,\n    modelName: \"${table_name}\",\n    tableName: \"${table_name_lower}\",\n    timestamps: false,\n  }\n);\n\n"
    file_content+=$init_content

    # Relaciones
    relation_content=""
    imports_for_relations=""
    for rel_key in "${!relationships[@]}"; do
        parent=${rel_key%_*}
        child=${rel_key#*_}
        rel_type=${relationships[$rel_key]}

        if [[ "$parent" == "$table_name" ]]; then
            if [[ "$rel_type" == "1:N" ]]; then
                imports_for_relations+="import { ${child} } from \"./${child}\";\n"
                fk_name="$(tr '[:upper:]' '[:lower:]' <<< "$parent")_id"
                relation_content+="${parent}.hasMany(${child}, {\n  foreignKey: \"${fk_name}\",\n  sourceKey: \"id\",\n});\n"
                relation_content+="${child}.belongsTo(${parent}, {\n  foreignKey: \"${fk_name}\",\n  targetKey: \"id\",\n});\n\n"
            
            elif [[ "$rel_type" == "N:M_"* ]]; then
                pivot_table=${rel_type#*N:M_}
                imports_for_relations+="import { ${child} } from \"./${child}\";\n"
                imports_for_relations+="import { ${pivot_table} } from \"./${pivot_table}\";\n"
                relation_content+="${parent}.belongsToMany(${child}, { through: ${pivot_table} });\n"
                relation_content+="${child}.belongsToMany(${parent}, { through: ${pivot_table} });\n\n"
            fi
        fi
    done

    # Añadir imports de relaciones al principio y el contenido de relaciones al final
    file_content="${file_content/import { sequelize }/import { sequelize }\n${imports_for_relations}}"
    file_content+=$relation_content

    # Escribir el archivo
    echo -e "$file_content" > "$model_file"
done

echo -e "${GREEN}✅ Proceso completado. Se han generado los modelos en 'src/models/'.${NC}"
pause