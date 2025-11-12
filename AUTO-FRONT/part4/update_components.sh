#!/bin/bash

# Este archivo contiene la lógica para generar dinámicamente los componentes 'update'.

generate_update_components() {
    print_step "Generando Componentes 'update' dinámicamente"
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
        print_step "Configurando componente 'update' para la entidad: '$table_name'"

        local model_name=$(grep "^${table_name}:" .model_map | cut -d':' -f2)
        if [ -z "$model_name" ]; then
            read -p "Introduce el nombre del MODELO en singular y capitalizado (ej. Client, Product): " model_name
        fi
        print_info "Modelo encontrado para '${table_name}': '${model_name}'"

        local model_file="src/app/models/${table_name}.ts"
        if [ ! -f "$model_file" ]; then
            print_error "No se encontró el archivo del modelo en '$model_file'."
            continue
        fi
        
        # Usamos la misma interfaz 'I' que para la creación
        local attributes=($(sed -n "/export interface ${model_name}I {/,/}/p" "$model_file" | grep ':' | sed -e 's/^\s*//' -e 's/?:.*//' -e 's/:.*//' | grep -v -E '^(id|status)$' | sort -u))

        if [ ${#attributes[@]} -eq 0 ]; then
            print_error "No se encontraron atributos en la interfaz '${model_name}I'."
            continue
        fi

        print_info "Atributos encontrados para el formulario: ${attributes[*]}"

        local form_group_fields=""
        for attr in "${attributes[@]}"; do
            echo -e "\n${YELLOW}Configurando el campo '${attr}' para el formulario de ACTUALIZACIÓN:${NC}"
            
            local validators="[]"
            local default_value="''"
            local temp_validators=()

            # Para la actualización, la contraseña no suele ser requerida
            if [[ "$attr" == "password" ]]; then
                read -p "¿El campo 'password' debe tener una longitud mínima si se introduce? (Introduce un número o deja en blanco): " min_length
                if [[ "$min_length" =~ ^[0-9]+$ ]]; then
                    temp_validators+=("Validators.minLength(${min_length})")
                fi
                print_info "La contraseña será opcional en el formulario de actualización."
            else
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
            fi

            if [ ${#temp_validators[@]} -gt 0 ]; then
                validators="[$(IFS=,; echo "${temp_validators[*]}")]"
            fi

            form_group_fields+="      ${attr}: [${default_value}, ${validators}],\n"
        done
        form_group_fields=$(echo -e "${form_group_fields}" | sed '$ s/,$//')

        # Generar el contenido del archivo TypeScript
        # Añadir el campo 'status' estáticamente al FormGroup
        form_group_fields+="\n      status: ['ACTIVE', Validators.required]"
        local ts_file_content
        ts_file_content=$(cat <<EOF
import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { Select } from 'primeng/select';
import { MessageService } from 'primeng/api';
import { ToastModule } from 'primeng/toast';
import { CardModule } from 'primeng/card';
import { ${model_name}Service } from '../../../services/${table_name}.service';
import { ${model_name}I, ${model_name}ResponseI } from '../../../models/${table_name}';

@Component({
  selector: 'app-update',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, ButtonModule, InputTextModule, Select, ToastModule, CardModule, RouterLink],
  templateUrl: './update.html',
  styleUrl: './update.css',
  providers: [MessageService]
})
export class Update implements OnInit {
  form: FormGroup;
  loading: boolean = true; // Inicia en true para mostrar spinner mientras carga
  entityId: number = 0;
  statusOptions = [
    { label: 'Activo', value: 'ACTIVE' },
    { label: 'Inactivo', value: 'INACTIVE' }
  ];

  constructor(
    private fb: FormBuilder,
    private router: Router,
    private route: ActivatedRoute,
    private ${table_name}Service: ${model_name}Service,
    private messageService: MessageService
  ) {
    this.form = this.fb.group({
${form_group_fields}
    });
  }

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.entityId = parseInt(id, 10);
      this.loadData();
    } else {
        this.loading = false;
        this.messageService.add({ severity: 'error', summary: 'Error', detail: 'ID de entidad no proporcionado' });
    }
  }

  loadData(): void {
    this.loading = true;
    this.${table_name}Service.getById(this.entityId).subscribe({
      next: (data: ${model_name}ResponseI) => {
        // Excluimos la contraseña para que no se cargue en el formulario
        // patchValue rellena los campos que coinciden. Como la respuesta no incluye la contraseña,
        // el campo del formulario se quedará con su valor inicial (vacío).
        this.form.patchValue(data);
        this.loading = false;
      },
      error: (error: any) => {
        this.messageService.add({ severity: 'error', summary: 'Error', detail: 'No se pudieron cargar los datos' });
        this.loading = false;
      }
    });
  }

  submit(): void {
    if (this.form.valid) {
      this.loading = true;
      let formData = this.form.value;

      // Si el campo de contraseña está vacío, no lo enviamos en la actualización
      if (!formData.password) {
        delete formData.password;
      }

      this.${table_name}Service.update(this.entityId, formData).subscribe({
        next: (response: ${model_name}ResponseI) => {
          this.messageService.add({ severity: 'success', summary: 'Éxito', detail: '${model_name} actualizado correctamente' });
          setTimeout(() => this.router.navigate(['/${table_name}']), 1000);
        },
        error: (error: any) => {
          this.messageService.add({ severity: 'error', summary: 'Error', detail: error.error?.message || 'Error al actualizar' });
          this.loading = false;
        }
      });
    } else {
      this.markFormGroupTouched();
    }
  }

  cancelar(): void {
    this.router.navigate(['/${table_name}']);
  }

  private markFormGroupTouched(): void {
    Object.values(this.form.controls).forEach(control => control.markAsTouched());
  }

  getFieldError(fieldName: string): string {
    const field = this.form.get(fieldName);
    if (field?.touched && field.errors) {
      if (field.errors['required']) return 'El campo es requerido.';
      if (field.errors['minlength']) return \`Debe tener al menos \${field.errors['minlength'].requiredLength} caracteres.\`;
      if (field.errors['email']) return 'El formato del email no es válido.';
      if (field.errors['pattern']) return 'El formato no es válido.';
    }
    return '';
  }
}
EOF
)
        local ts_filepath="src/app/components/${table_name}/update/update.ts"
        echo -e "$ts_file_content" > "$ts_filepath"
        print_success "Componente 'update' TS generado en: $ts_filepath"

        # Generar el contenido del archivo HTML
        local html_form_fields=""
        for attr in "${attributes[@]}"; do
            local attr_name=$(echo "$attr" | cut -d':' -f1)
            local attr_capitalized="$(echo "${attr_name:0:1}" | tr '[:lower:]' '[:upper:]')${attr_name:1}"
            local input_type="text"
            local placeholder_text=""

            if [[ "$attr_name" == "email" ]]; then input_type="email"; fi
            if [[ "$attr_name" == "password" ]]; then
                input_type="password"
                placeholder_text="Dejar en blanco para no cambiar"
            fi

            if [[ "$attr_name" == "status" ]]; then
                html_form_fields+=$(cat <<EOT
        <div class="flex flex-col"><label class="block mb-2 font-semibold text-gray-700">Estado *</label><p-select formControlName="status" [options]="statusOptions" class="w-full"></p-select></div>
EOT
)
            else
                html_form_fields+=$(cat <<EOT
        <div class="flex flex-col"><label class="block mb-2 font-semibold text-gray-700">${attr_capitalized} *</label><input pInputText type="${input_type}" formControlName="${attr_name}" class="w-full" placeholder="${placeholder_text}"/><small class="text-red-500 mt-1" *ngIf="getFieldError('${attr_name}')">{{ getFieldError('${attr_name}') }}</small></div>
EOT
)
            fi
        done

        local html_file_content=$(cat <<EOF
<div class="max-w-4xl mx-auto p-6">
  <div class="bg-white rounded-lg shadow-lg p-8">
    <h2 class="text-2xl font-bold mb-6 text-gray-800">Editar ${model_name}</h2>

    <div class="flex justify-center py-8" *ngIf="loading">
      <i class="pi pi-spin pi-spinner" style="font-size: 2.5rem"></i>
    </div>

    <form [formGroup]="form" (ngSubmit)="submit()" *ngIf="!loading">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
${html_form_fields}
      </div>

      <div class="flex justify-center mt-8">
        <div class="bg-gray-50 rounded-lg p-4 flex gap-4 items-center">
          <button pButton type="submit" label="Actualizar" icon="pi pi-save" [loading]="loading" [disabled]="form.invalid || loading"></button>
          <button pButton type="button" class="p-button-secondary" label="Cancelar" icon="pi pi-times" (click)="cancelar()" [disabled]="loading"></button>
        </div>
      </div>
    </form>
  </div>
</div>
<p-toast></p-toast>
EOF
)
        local html_filepath="src/app/components/${table_name}/update/update.html"
        echo -e "$html_file_content" > "$html_filepath"
        print_success "Plantilla HTML 'update' generada en: $html_filepath"
    done

    print_success "Todos los componentes 'update' han sido generados."
    cd - > /dev/null
}