#!/bin/bash

# Este archivo contiene la lógica para la creación dinámica de servicios CRUD de Angular.

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
        fi

        local capitalized_plural_name="$(echo "${table_name:0:1}" | tr '[:lower:]' '[:upper:]')${table_name:1}"

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