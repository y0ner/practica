#!/bin/bash

# Este archivo contendrá las funciones para el CRUD del modelo Client.

create_dynamic_models() {
    print_step "Creación dinámica de Modelos (Interfaces)"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    cd "$PROJECTS_DIR/$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }

    # Verificar si el archivo con los nombres de las tablas existe
    if [ ! -f ".table_names" ]; then
        print_error "No se encontró el archivo '.table_names'. Por favor, ejecuta primero el paso 'Implementar PanelMenu en Aside' (Opción 6, Sección 1)."
        return 1
    fi

    # Leer los nombres de las tablas
    mapfile -t table_names < .table_names
    print_msg "Se crearán modelos para las siguientes tablas: ${table_names[*]}"

    # Limpiar/crear el archivo de mapeo de modelos al inicio
    > .model_map

    mkdir -p src/app/models

    for table_name in "${table_names[@]}"; do
        print_step "Configurando modelo para la tabla: '$table_name'"

        # 1. Preguntar por el nombre del modelo en singular y capitalizado
        local model_name
        while true; do
            read -p "Introduce el nombre para el modelo en singular y capitalizado (ej. Client, Product): " model_name
            if [[ "$model_name" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
                break
            else
                print_error "El nombre debe empezar con mayúscula y solo contener caracteres alfanuméricos."
            fi
        done

        # Guardar el mapeo en el archivo
        echo "${table_name}:${model_name}" >> .model_map

        # 2. Preguntar por el número de atributos
        local num_attributes
        while true; do
            read -p "Introduce el número de atributos para '${model_name}' (excluyendo 'id' y 'status'): " num_attributes
            if [[ "$num_attributes" =~ ^[1-9][0-9]*$ ]]; then
                break
            else
                print_error "Por favor, introduce un número entero positivo."
            fi
        done

        local interface_body=""
        local response_interface_body=""

        # 3. Bucle para cada atributo
        for (( i=1; i<=num_attributes; i++ )); do
            echo -e "${YELLOW}--- Atributo #${i} ---${NC}"
            
            local attr_name
            read -p "Nombre del atributo: " attr_name

            # Preguntar por el tipo de dato
            local attr_type
            echo "Elige el tipo de dato para '${attr_name}':"
            select type_option in "string" "number" "boolean" "Date"; do
                case $type_option in
                    "string"|"number"|"boolean"|"Date")
                        attr_type=$type_option
                        break
                        ;;
                    *) echo "Opción no válida." ;;
                esac
            done

            # Construir la línea para la interfaz principal
            interface_body+="  ${attr_name}: ${attr_type};\n"

            # Preguntar si se incluye en la interfaz de respuesta
            local include_in_response
            read -p "¿Incluir '${attr_name}' en la interfaz de respuesta (ResponseI)? (s/n): " include_in_response
            if [[ "$include_in_response" =~ ^[sSyY]$ ]]; then
                response_interface_body+="  ${attr_name}: ${attr_type};\n"
            fi
        done

        # 4. Construir el contenido completo del archivo del modelo
        local model_file_content
        model_file_content=$(cat <<EOF
export interface ${model_name}I {
  id?: number;
${interface_body}  status: "ACTIVE" | "INACTIVE";
}


export interface ${model_name}ResponseI {
  id?: number;
${response_interface_body}}
EOF
)

        # 5. Escribir el archivo
        local model_filename="src/app/models/${table_name}.ts"
        echo -e "$model_file_content" > "$model_filename"
        print_success "Modelo creado exitosamente en: $model_filename"
    done

    print_success "Todos los modelos han sido creados."

    # Volvemos al directorio original del script
    local script_dir; script_dir=$(dirname "$(realpath "$0")")
    cd "$script_dir" || return
}


link_getall_components() {
    print_step "Enlazando Componentes 'getall' con Servicios y Modelos"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    cd "$PROJECTS_DIR/$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }

    if [ ! -f ".table_names" ]; then
        print_error "No se encontró el archivo '.table_names'. Por favor, ejecuta primero la creación de modelos y servicios."
        return 1
    fi

    mapfile -t table_names < .table_names

    for table_name in "${table_names[@]}"; do
        print_step "Configurando componente 'getall' para la entidad: '$table_name'"

        # Intentar obtener el nombre del modelo desde el archivo de mapeo
        local model_name=$(grep "^${table_name}:" .model_map | cut -d':' -f2)

        if [ -z "$model_name" ]; then
            print_warning "No se encontró un modelo para '${table_name}'. Por favor, introdúcelo manualmente."
            while true; do
                read -p "Introduce el nombre del MODELO en singular y capitalizado (ej. Client, Product): " model_name
                if [[ "$model_name" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
                    break
                else
                    print_error "El nombre debe empezar con mayúscula y solo contener caracteres alfanuméricos."
                fi
            done
        else
            print_info "Modelo encontrado para '${table_name}': '${model_name}'"
        done

        # Generar el contenido del archivo TypeScript
        local ts_file_content
        ts_file_content=$(cat <<EOF
import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { TableModule } from 'primeng/table';
import { ButtonModule } from 'primeng/button';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { ToastModule } from 'primeng/toast';
import { TooltipModule } from 'primeng/tooltip';
import { ConfirmationService, MessageService } from 'primeng/api';
import { Subscription } from 'rxjs';
import { ${model_name}Service } from '../../../services/${table_name}.service';
import { ${model_name}ResponseI } from '../../../models/${table_name}';

@Component({
  selector: 'app-${table_name}-getall',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TableModule,
    ButtonModule,
    ConfirmDialogModule,
    ToastModule,
    TooltipModule
  ],
  providers: [ConfirmationService, MessageService],
  templateUrl: './getall.html',
  styleUrl: './getall.css'
})
export class Getall implements OnInit, OnDestroy {
  ${table_name}: ${model_name}ResponseI[] = [];
  loading = false;
  private subscription = new Subscription();

  constructor(
    private ${table_name}Service: ${model_name}Service,
    private confirmationService: ConfirmationService,
    private messageService: MessageService
  ) {}

  ngOnInit(): void {
    this.loadData();

    this.subscription.add(
      this.${table_name}Service.${table_name}\$.subscribe(data => {
        this.${table_name} = data;
      })
    );
  }

  ngOnDestroy(): void {
    this.subscription.unsubscribe();
  }

  loadData(): void {
    this.loading = true;
    this.subscription.add(
      this.${table_name}Service.getAll().subscribe({
        next: () => {
          this.loading = false;
        },
        error: (error) => {
          this.messageService.add({
            severity: 'error',
            summary: 'Error',
            detail: 'No se pudieron cargar los datos'
          });
          this.loading = false;
        }
      })
    );
  }

  confirmDelete(item: ${model_name}ResponseI): void {
    this.confirmationService.confirm({
      message: \`¿Está seguro de que desea eliminar este registro?\`,
      header: 'Confirmar Eliminación',
      icon: 'pi pi-exclamation-triangle',
      acceptLabel: 'Sí, eliminar',
      rejectLabel: 'Cancelar',
      acceptButtonStyleClass: 'p-button-danger',
      accept: () => {
        this.deleteItem(item.id!);
      }
    });
  }

  deleteItem(id: number): void {
    this.subscription.add(
      this.${table_name}Service.delete(id).subscribe({
        next: () => {
          this.messageService.add({
            severity: 'success',
            summary: 'Éxito',
            detail: 'Registro eliminado correctamente'
          });
        },
        error: (error) => {
          this.messageService.add({
            severity: 'error',
            summary: 'Error',
            detail: 'No se pudo eliminar el registro'
          });
        }
      })
    );
  }
}
EOF
)
        local ts_filename="src/app/components/${table_name}/getall/getall.ts"
        echo -e "$ts_file_content" > "$ts_filename"
        print_success "Componente TS actualizado en: $ts_filename"

    done

    print_success "Todos los componentes 'getall' han sido enlazados."
    cd - > /dev/null
}

create_dynamic_services() {
    print_step "Creación dinámica de Servicios CRUD"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    cd "$PROJECTS_DIR/$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }

    if [ ! -f ".table_names" ]; then
        print_error "No se encontró el archivo '.table_names'. Por favor, ejecuta primero la creación de modelos."
        return 1
    fi

    mapfile -t table_names < .table_names
    print_msg "Se crearán servicios para las siguientes entidades: ${table_names[*]}"

    mkdir -p src/app/services

    for table_name in "${table_names[@]}"; do
        print_step "Configurando servicio para la entidad: '$table_name'"

        # Intentar obtener el nombre del modelo desde el archivo de mapeo
        local model_name=$(grep "^${table_name}:" .model_map | cut -d':' -f2)

        if [ -z "$model_name" ]; then
            print_warning "No se encontró un modelo para '${table_name}'. Por favor, introdúcelo manualmente."
            while true; do
                read -p "Introduce el nombre del MODELO en singular y capitalizado (ej. Client, Product): " model_name
                if [[ "$model_name" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
                    break
                else
                    print_error "El nombre debe empezar con mayúscula y solo contener caracteres alfanuméricos."
                fi
            done
        else
            print_info "Modelo encontrado para '${table_name}': '${model_name}'"
        done

        local capitalized_plural_name="$(tr '[:lower:]' '[:upper:]' <<< ${table_name:0:1})${table_name:1}"

        local service_file_content
        service_file_content=$(cat <<EOF
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject, tap, catchError, throwError } from 'rxjs';
import { map } from 'rxjs/operators';
import { ${model_name}I, ${model_name}ResponseI } from '../models/${table_name}';

// Interfaz para la respuesta paginada de Django
interface PaginatedResponse<T> {
  count: number;
  next: string | null;
  previous: string | null;
  results: T[];
}

@Injectable({
  providedIn: 'root'
})
export class ${model_name}Service {
  private baseUrl = 'http://localhost:8000/api/${table_name}';
  private ${table_name}Subject = new BehaviorSubject<${model_name}ResponseI[]>([]);
  public ${table_name}\$ = this.${table_name}Subject.asObservable();

  constructor(private http: HttpClient) {}

  getAll(): Observable<${model_name}ResponseI[]> {
    return this.http.get<PaginatedResponse<${model_name}ResponseI>>(\`\${this.baseUrl}/\`)
      .pipe(
        map(response => response.results), // Extraer solo el array de results
        tap(${table_name} => {
          this.${table_name}Subject.next(${table_name});
        }),
        catchError(error => {
          console.error('Error fetching ${table_name}:', error);
          return throwError(() => error);
        })
      );
  }

  getById(id: number): Observable<${model_name}ResponseI> {
    return this.http.get<${model_name}ResponseI>(\`\${this.baseUrl}/\${id}/\`)
      .pipe(
        catchError(error => {
          console.error('Error fetching ${model_name}:', error);
          return throwError(() => error);
        })
      );
  }

  create(data: ${model_name}I): Observable<${model_name}ResponseI> {
    return this.http.post<${model_name}ResponseI>(\`\${this.baseUrl}/\`, data)
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error creating ${model_name}:', error);
          return throwError(() => error);
        })
      );
  }

  update(id: number, data: Partial<${model_name}I>): Observable<${model_name}ResponseI> {
    return this.http.put<${model_name}ResponseI>(\`\${this.baseUrl}/\${id}/\`, data)
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error updating ${model_name}:', error);
          return throwError(() => error);
        })
      );
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(\`\${this.baseUrl}/\${id}/\`)
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error deleting ${model_name}:', error);
          return throwError(() => error);
        })
      );
  }

  refresh(): void {
    this.getAll().subscribe();
  }
}
EOF
)

        local service_filename="src/app/services/${table_name}.service.ts"
        echo -e "$service_file_content" > "$service_filename"
        print_success "Servicio creado exitosamente en: $service_filename"
    done

    print_success "Todos los servicios han sido creados."
    cd - > /dev/null
}

create_getall_html() {
    print_step "Creación de plantillas HTML para componentes 'getall'"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    cd "$PROJECTS_DIR/$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }

    if [ ! -f ".table_names" ]; then
        print_error "No se encontró el archivo '.table_names'. Por favor, ejecuta primero la creación de modelos y servicios."
        return 1
    fi

    mapfile -t table_names < .table_names

    for table_name in "${table_names[@]}"; do
        print_step "Configurando plantilla HTML para la entidad: '$table_name'"

        # Intentar obtener el nombre del modelo desde el archivo de mapeo
        local model_name=$(grep "^${table_name}:" .model_map | cut -d':' -f2)

        if [ -z "$model_name" ]; then
            print_warning "No se encontró un modelo para '${table_name}'. Por favor, introdúcelo manualmente."
            while true; do
                read -p "Introduce el nombre del MODELO en singular y capitalizado (ej. Client, Product): " model_name
                if [[ "$model_name" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
                    break
                else
                    print_error "El nombre debe empezar con mayúscula y solo contener caracteres alfanuméricos."
                fi
            done
        else
            print_info "Modelo encontrado para '${table_name}': '${model_name}'"
        done

        local entity_name_singular_lower=$(echo "$model_name" | tr '[:upper:]' '[:lower:]')
        local entity_name_plural_capitalized="$(tr '[:lower:]' '[:upper:]' <<< ${table_name:0:1})${table_name:1}"

        local headers=""
        local body_cells=""
        local colspan=2 # 1 para ID, 1 para Acciones

        # ID siempre está
        headers+="                <th pSortableColumn=\"id\">\n                    ID <p-sortIcon field=\"id\"></p-sortIcon>\n                </th>\n"
        body_cells+="                <td>{{ ${entity_name_singular_lower}.id }}</td>\n"

        # Preguntar por los otros atributos
        while true; do
            read -p "¿Deseas añadir una columna a la tabla para '${model_name}'? (s/n): " add_column
            if [[ ! "$add_column" =~ ^[sSyY]$ ]]; then
                break
            fi

            local attr_name
            read -p "Nombre del atributo (ej. name, email): " attr_name
            local attr_header
            read -p "Texto para la cabecera de la columna (ej. Nombre, Correo Electrónico): " attr_header

            headers+="                <th pSortableColumn=\"${attr_name}\">\n                    ${attr_header} <p-sortIcon field=\"${attr_name}\"></p-sortIcon>\n                </th>\n"
            body_cells+="                <td>{{ ${entity_name_singular_lower}.${attr_name} }}</td>\n"
            ((colspan++))
        done

        local html_file_content
        html_file_content=$(cat <<EOF
<div class="card p-8">
    <div class="flex justify-between items-center mb-4">
        <h2 class="text-2xl font-bold">Gestión de ${entity_name_plural_capitalized}</h2>
        <p-button
            label="Nuevo ${model_name}"
            icon="pi pi-plus"
            [routerLink]="['/${table_name}/new']"
            styleClass="p-button-success"
        ></p-button>
    </div>

    <p-table 
        [value]="${table_name}" 
        [loading]="loading"
        [paginator]="true"
        [rows]="10"
        [showCurrentPageReport]="true"
        currentPageReportTemplate="Mostrando {first} a {last} de {totalRecords} registros"
        [rowsPerPageOptions]="[5, 10, 25, 50]"
        dataKey="id"
        styleClass="p-datatable-striped"
        [tableStyle]="{'min-width': '50rem'}"
    >
        <ng-template pTemplate="header">
            <tr>
${headers}                <th class="text-center">Acciones</th>
            </tr>
        </ng-template>

        <ng-template pTemplate="body" let-${entity_name_singular_lower}>
            <tr>
${body_cells}                <td class="text-center">
                    <div class="flex justify-center gap-2">
                        <p-button icon="pi pi-pencil" [routerLink]="['/${table_name}/edit', ${entity_name_singular_lower}.id]" styleClass="p-button-rounded p-button-text p-button-warning" pTooltip="Editar" tooltipPosition="top"></p-button>
                        <p-button icon="pi pi-trash" (onClick)="confirmDelete(${entity_name_singular_lower})" styleClass="p-button-rounded p-button-text p-button-danger" pTooltip="Eliminar" tooltipPosition="top"></p-button>
                    </div>
                </td>
            </tr>
        </ng-template>

        <ng-template pTemplate="emptymessage">
            <tr>
                <td colspan="${colspan}" class="text-center p-4">No se encontraron registros</td>
            </tr>
        </ng-template>
    </p-table>
</div>

<p-confirmDialog></p-confirmDialog>
<p-toast></p-toast>
EOF
)
        local html_filename="src/app/components/${table_name}/getall/getall.html"
        echo -e "$html_file_content" > "$html_filename"
        print_success "Plantilla HTML creada en: $html_filename"
    done

    print_success "Todas las plantillas HTML 'getall' han sido creadas."
    cd - > /dev/null
}

show_part4_menu() {
    while true; do
        echo -e "\n${YELLOW}===== SECCIÓN 5: Generación de Modelos y Servicios =====${NC}"
        echo "1. Crear/Sobrescribir Modelos (Interfaces)"
        echo "2. Crear/Sobrescribir Servicios CRUD"
        echo "3. Enlazar Componentes 'getall' (Mostrar y Eliminar)"
        echo "4. Crear/Sobrescribir Plantillas HTML para 'getall'"
        echo "5. Volver al Menú Principal"
        read -p "Elige una opción: " sub_choice

        case $sub_choice in
            1) create_dynamic_models; press_enter_to_continue ;;
            2) create_dynamic_services; press_enter_to_continue ;;
            3) link_getall_components; press_enter_to_continue ;;
            4) create_getall_html; press_enter_to_continue ;;
            5) break ;;
            *) print_error "Opción no válida." ;;
        esac
    done
}

source ./part4_client_getall_html.sh
