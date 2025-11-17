import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { TableModule } from 'primeng/table';
import { ButtonModule } from 'primeng/button';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { ToastModule } from 'primeng/toast';
import { TooltipModule } from 'primeng/tooltip'; // Mantener TooltipModule
import { ConfirmationService, MessageService } from 'primeng/api';
import { Subscription } from 'rxjs';
import { RoomService } from '../../../services/Habitacion.service';
import { RoomResponseI } from '../../../models/Habitacion';

@Component({
  selector: 'app-Habitacion-getall',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TableModule,
    ButtonModule,
    ConfirmDialogModule,
    ToastModule,
    TooltipModule // Mantener TooltipModule
  ],
  providers: [ConfirmationService, MessageService],
  templateUrl: './getall.html',
  styleUrl: './getall.css'
})
export class Getall implements OnInit, OnDestroy {
  Habitacion: RoomResponseI[] = [];
  loading: boolean = false;
  private subscription = new Subscription();

  constructor(
    private HabitacionService: RoomService,
    private confirmationService: ConfirmationService,
    private messageService: MessageService
  ) {}

  ngOnInit(): void {
    this.loadData(); // Carga inicial de datos
  }

  ngOnDestroy(): void {
    this.subscription.unsubscribe();
  }

  loadData(): void {
    this.loading = true;
    this.subscription.add(
      this.HabitacionService.getAll().subscribe({
        next: (data) => {
          this.Habitacion = data;
          this.HabitacionService.updateLocalData(data);
          this.loading = false;
        },
        error: (error) => {
          this.messageService.add({
            severity: 'error', // Corregido: severity
            summary: 'Error',
            detail: 'No se pudieron cargar los datos'
          });
          this.loading = false;
        }
      })
    );
  }

  confirmDelete(item: RoomResponseI): void {
    this.confirmationService.confirm({
      message: `¿Está seguro de que desea eliminar el registro ${item.id}?`,
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
      this.HabitacionService.delete(id).subscribe({
        next: () => {
          this.messageService.add({
            severity: 'success',
            summary: 'Éxito',
            detail: 'Registro eliminado correctamente'
          });
          this.loadData(); // Recargar datos después de eliminar
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
