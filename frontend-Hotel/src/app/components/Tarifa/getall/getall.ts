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
import { RateService } from '../../../services/Tarifa.service';
import { RateResponseI } from '../../../models/Tarifa';

@Component({
  selector: 'app-Tarifa-getall',
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
  Tarifa: RateResponseI[] = [];
  loading: boolean = false;
  private subscription = new Subscription();

  constructor(
    private TarifaService: RateService,
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
      this.TarifaService.getAll().subscribe({
        next: (data) => {
          this.Tarifa = data;
          this.TarifaService.updateLocalData(data);
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

  confirmDelete(item: RateResponseI): void {
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
      this.TarifaService.delete(id).subscribe({
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
