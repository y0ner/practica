#!/bin/bash

# Este archivo contiene la lógica para generar dinámicamente los componentes 'create'.

generate_create_components() {
    print_step "Generando Componentes 'create' dinámicamente"
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
        print_step "Configurando componente 'create' para la entidad: '$table_name'"

        # 1. Obtener el nombre del modelo (singular, capitalizado)
        local model_name=$(grep "^${table_name}:" .model_map | cut -d':' -f2)
        if [ -z "$model_name" ]; then
            print_warning "No se encontró un modelo para '${table_name}'. Por favor, introdúcelo manualmente."
            read -p "Introduce el nombre del MODELO en singular y capitalizado (ej. Client, Product): " model_name
        fi
        print_info "Modelo encontrado para '${table_name}': '${model_name}'"

        # 2. Leer los atributos de la interfaz de creación (ej: ClientI)
        local model_file="src/app/models/${table_name}.ts"
        if [ ! -f "$model_file" ]; then
            print_error "No se encontró el archivo del modelo en '$model_file'. No se pueden determinar los atributos."
            continue
        fi
        
        # Extraer atributos de la interfaz que NO es 'ResponseI'
        local attributes=($(sed -n "/export interface ${model_name}I {/,/}/p" "$model_file" | grep ':' | sed -e 's/^\s*//' -e 's/?:.*//' -e 's/:.*//' | grep -v -E '^(id)$' | sort -u))

        if [ ${#attributes[@]} -eq 0 ]; then
            print_error "No se encontraron atributos en la interfaz '${model_name}I' del archivo '$model_file'."
            continue
        fi

        print_info "Atributos encontrados para el formulario: ${attributes[*]}"

        # 3. Construir el FormGroup dinámicamente
        local form_group_fields=""
        for attr in "${attributes[@]}"; do
            echo -e "\n${YELLOW}Configurando el campo '${attr}':${NC}"
            
            local validators="[]"
            local default_value="''"

            # Preguntar por validadores
            local temp_validators=()
            read -p "¿Es '${attr}' un campo requerido? (s/n): " is_required
            if [[ "$is_required" =~ ^[sSyY]$ ]]; then
                temp_validators+=("Validators.required")
            fi

            if [[ "$attr" == "email" ]]; then
                temp_validators+=("Validators.email")
            fi

            read -p "¿Añadir validación de longitud mínima (minLength)? (Introduce un número o deja en blanco): " min_length
            if [[ "$min_length" =~ ^[0-9]+$ ]]; then
                temp_validators+=("Validators.minLength(${min_length})")
            fi

            read -p "¿Añadir validación de patrón (pattern)? (Introduce el regex o deja en blanco): " pattern
            if [[ -n "$pattern" ]]; then
                temp_validators+=("Validators.pattern(/${pattern}/)")
            fi

            if [ ${#temp_validators[@]} -gt 0 ]; then
                validators="[$(IFS=,; echo "${temp_validators[*]}")]"
            fi

            # Campo especial 'status'
            if [[ "$attr" == "status" ]]; then
                default_value="'ACTIVE'"
            fi

            form_group_fields+="      ${attr}: [${default_value}, ${validators}],\n"
        done
        # Quitar la última coma
        form_group_fields=$(echo -e "${form_group_fields}" | sed '$ s/,$//')

        # 4. Generar el contenido del archivo TypeScript
        local ts_file_content
        ts_file_content=$(cat <<EOF
import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { DropdownModule } from 'primeng/dropdown'; // Para el campo status
import { MessageService } from 'primeng/api';
import { ToastModule } from 'primeng/toast';
import { CardModule } from 'primeng/card';
import { ${model_name}Service } from '../../../services/${table_name}.service';

@Component({
  selector: 'app-create',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, ButtonModule, InputTextModule, DropdownModule, ToastModule, CardModule, RouterLink],
  templateUrl: './create.html',
  styleUrl: './create.css',
  providers: [MessageService]
})
export class Create {
  form: FormGroup;
  loading: boolean = false;
  statusOptions = [
    { label: 'Activo', value: 'ACTIVE' },
    { label: 'Inactivo', value: 'INACTIVE' }
  ];

  constructor(
    private fb: FormBuilder,
    private router: Router,
    private ${table_name}Service: ${model_name}Service,
    private messageService: MessageService
  ) {
    this.form = this.fb.group({
${form_group_fields}
    });
  }

  submit(): void {
    if (this.form.valid) {
      this.loading = true;
      const formData = this.form.value;

      this.${table_name}Service.create(formData).subscribe({
        next: (response) => {
          this.messageService.add({
            severity: 'success',
            summary: 'Éxito',
            detail: '${model_name} creado correctamente'
          });
          setTimeout(() => {
            this.router.navigate(['/${table_name}']);
          }, 1000);
        },
        error: (error) => {
          console.error('Error creating ${model_name}:', error);
          this.messageService.add({
            severity: 'error',
            summary: 'Error',
            detail: error.error?.message || 'Error al crear el ${model_name}'
          });
          this.loading = false;
        }
      });
    } else {
      this.markFormGroupTouched();
      this.messageService.add({
        severity: 'warn',
        summary: 'Advertencia',
        detail: 'Por favor complete todos los campos requeridos'
      });
    }
  }

  cancelar(): void {
    this.router.navigate(['/${table_name}']);
  }

  private markFormGroupTouched(): void {
    Object.values(this.form.controls).forEach(control => {
      control.markAsTouched();
    });
  }

  getFieldError(fieldName: string): string {
    const field = this.form.get(fieldName);
    if (field?.touched && field.errors) {
      if (field.errors['required']) {
        return \`El campo es requerido.\`;
      }
      if (field.errors['minlength']) {
        return \`Debe tener al menos \${field.errors['minlength'].requiredLength} caracteres.\`;
      }
      if (field.errors['email']) {
        return 'El formato del email no es válido.';
      }
      if (field.errors['pattern']) {
        return 'El formato no es válido.';
      }
    }
    return '';
  }
}
EOF
)
        local ts_filepath="src/app/components/${table_name}/create/create.ts"
        echo -e "$ts_file_content" > "$ts_filepath"
        print_success "Componente 'create' TS generado en: $ts_filepath"

        # 5. Generar el contenido del archivo HTML
        local html_form_fields=""
        for attr in "${attributes[@]}"; do
            local attr_name=$(echo "$attr" | cut -d':' -f1)
            local attr_capitalized="$(echo "${attr_name:0:1}" | tr '[:lower:]' '[:upper:]')${attr_name:1}"
            local input_type="text"
            local placeholder_attr=""
            local extra_classes=""

            if [[ "$attr_name" == "email" ]]; then
                input_type="email"
            elif [[ "$attr_name" == "password" ]]; then
                input_type="password"
            elif [[ "$attr_name" == "phone" ]]; then
                placeholder_attr="            placeholder=\"1234567890\""
            fi

            if [[ "$attr_name" == "status" ]]; then
                html_form_fields+=$(cat <<EOT
        <div class="flex flex-col">
          <label class="block mb-2 font-semibold text-gray-700">Estado *</label>
          <p-dropdown
            formControlName="status"
            [options]="statusOptions"
            placeholder="Seleccionar estado"
            class="w-full"
          ></p-dropdown>
        </div>
EOT
)
            else
                html_form_fields+=$(cat <<EOT
        <div class="flex flex-col">
          <label class="block mb-2 font-semibold text-gray-700">${attr_capitalized} *</label>
          <input 
            pInputText 
            type="${input_type}"
            formControlName="${attr_name}" 
            class="w-full"
${placeholder_attr}
            [class.ng-invalid]="form.get('${attr_name}')?.invalid && form.get('${attr_name}')?.touched"
          />
          <small class="text-red-500 mt-1" *ngIf="getFieldError('${attr_name}')">
            {{ getFieldError('${attr_name}') }}
          </small>
        </div>
EOT
)
            fi
        done

        local html_file_content=$(cat <<EOF
<div class="max-w-4xl mx-auto p-6">
  <div class="bg-white rounded-lg shadow-lg p-8">
    <h2 class="text-2xl font-bold mb-6 text-gray-800">Crear Nuevo ${model_name}</h2>

    <form [formGroup]="form" (ngSubmit)="submit()">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
${html_form_fields}
      </div>

      <div class="flex justify-center mt-8">
        <div class="bg-gray-50 rounded-lg p-4 flex gap-4 items-center">
          <button
            pButton
            type="submit"
            class="p-button bg-blue-500 hover:bg-blue-600 text-white"
            label="Guardar"
            icon="pi pi-save"
            [loading]="loading"
            [disabled]="loading"
          ></button>
          <button
            pButton
            type="button"
            class="p-button p-button-secondary"
            label="Cancelar"
            icon="pi pi-times"
            (click)="cancelar()"
            [disabled]="loading"
          ></button>
        </div>
      </div>
    </form>
  </div>
</div>

<p-toast></p-toast>
EOF
)
        local html_filepath="src/app/components/${table_name}/create/create.html"
        echo -e "$html_file_content" > "$html_filepath"
        print_success "Plantilla HTML 'create' generada en: $html_filepath"
    done

    print_success "Todos los componentes 'create' han sido generados."
    cd - > /dev/null
}
