#!/bin/bash

# Este archivo contiene la lógica para enlazar los componentes 'getall' con sus servicios y modelos.

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
        fi

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