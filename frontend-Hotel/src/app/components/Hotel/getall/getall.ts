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
import { HotelService } from '../../../services/Hotel.service';
import { HotelResponseI } from '../../../models/Hotel';

@Component({
  selector: 'app-Hotel-getall',
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
  Hotel: HotelResponseI[] = [];
  loading: boolean = false;
  private subscription = new Subscription();

  constructor(
    private HotelService: HotelService,
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
      this.HotelService.getAll().subscribe({
        next: (data) => {
          this.Hotel = data;
          this.HotelService.updateLocalData(data);
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

  confirmDelete(item: HotelResponseI): void {
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
      this.HotelService.delete(id).subscribe({
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
