#!/bin/bash

# Este archivo contiene la lógica para generar dinámicamente los componentes 'delete'.

generate_delete_components() {
    print_step "Generando Componentes 'delete' dinámicamente"
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
        print_step "Configurando componente 'delete' para la entidad: '$table_name'"

        local model_name=$(grep "^${table_name}:" .model_map | cut -d':' -f2)
        if [ -z "$model_name" ]; then
            read -p "Introduce el nombre del MODELO en singular y capitalizado (ej. Client, Product): " model_name
        fi
        print_info "Modelo encontrado para '${table_name}': '${model_name}'"

        # No se necesitan preguntas interactivas para el delete.

        # Generar el contenido del archivo TypeScript
        local ts_file_content
        ts_file_content=$(cat <<EOF
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { MessageService } from 'primeng/api';
import { ToastModule } from 'primeng/toast';
import { CardModule } from 'primeng/card';
import { ${model_name}Service } from '../../../services/${table_name}.service';

@Component({
  selector: 'app-delete',
  standalone: true,
  imports: [CommonModule, ToastModule, CardModule],
  templateUrl: './delete.html',
  styleUrl: './delete.css',
  providers: [MessageService]
})
export class Delete implements OnInit {
  loading: boolean = true;
  entityId: number = 0;

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private ${table_name}Service: ${model_name}Service,
    private messageService: MessageService
  ) {}

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.entityId = parseInt(id, 10);
      this.deleteEntity();
    } else {
      this.messageService.add({ severity: 'error', summary: 'Error', detail: 'ID no proporcionado' });
      this.loading = false;
      setTimeout(() => this.router.navigate(['/${table_name}']), 2000);
    }
  }

  private deleteEntity(): void {
    this.${table_name}Service.delete(this.entityId).subscribe({
      next: () => {
        this.messageService.add({ severity: 'success', summary: 'Éxito', detail: '${model_name} eliminado correctamente' });
        setTimeout(() => this.router.navigate(['/${table_name}']), 1500);
      },
      error: (error: any) => {
        this.messageService.add({ severity: 'error', summary: 'Error', detail: error.error?.message || 'Error al eliminar el ${model_name}' });
        this.loading = false;
        setTimeout(() => this.router.navigate(['/${table_name}']), 2000);
      }
    });
  }
}
EOF
)
        local ts_filepath="src/app/components/${table_name}/delete/delete.ts"
        echo -e "$ts_file_content" > "$ts_filepath"
        print_success "Componente 'delete' TS generado en: $ts_filepath"

        # Generar el contenido del archivo HTML
        local html_file_content=$(cat <<EOF
<div class="flex items-center justify-center min-h-screen bg-gray-50">
  <p-card header="Eliminando ${model_name}..." class="text-center">
    <div class="py-4">
      <i class="pi pi-spin pi-spinner" style="font-size: 2.5rem"></i>
      <p class="mt-4 text-lg">Por favor, espere mientras se procesa la solicitud.</p>
    </div>
  </p-card>
</div>
<p-toast></p-toast>
EOF
)
        local html_filepath="src/app/components/${table_name}/delete/delete.html"
        echo -e "$html_file_content" > "$html_filepath"
        print_success "Plantilla HTML 'delete' generada en: $html_filepath"
    done

    print_success "Todos los componentes 'delete' han sido generados."
    cd - > /dev/null
}