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
import { SaleService } from '../../../services/Ventas.service';
import { SaleResponseI } from '../../../models/Ventas';

@Component({
  selector: 'app-Ventas-getall',
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
  Ventas: SaleResponseI[] = [];
  loading = false;
  private subscription = new Subscription();

  constructor(
    private VentasService: SaleService,
    private confirmationService: ConfirmationService,
    private messageService: MessageService
  ) {}

  ngOnInit(): void {
    this.loadData();

    this.subscription.add(
      this.VentasService.Ventas$.subscribe(data => {
        this.Ventas = data;
      })
    );
  }

  ngOnDestroy(): void {
    this.subscription.unsubscribe();
  }

  loadData(): void {
    this.loading = true;
    this.subscription.add(
      this.VentasService.getAll().subscribe({
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

  confirmDelete(item: SaleResponseI): void {
    this.confirmationService.confirm({
      message: `¿Está seguro de que desea eliminar este registro?`,
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
      this.VentasService.delete(id).subscribe({
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
