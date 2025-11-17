import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { MessageService } from 'primeng/api';
import { ToastModule } from 'primeng/toast';
import { CardModule } from 'primeng/card';
import { PaymentService } from '../../../services/Pago.service';

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
    private PagoService: PaymentService,
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
      setTimeout(() => this.router.navigate(['/Pago']), 2000);
    }
  }

  private deleteEntity(): void {
    this.PagoService.delete(this.entityId).subscribe({
      next: () => {
        this.messageService.add({ severity: 'success', summary: 'Éxito', detail: 'Payment eliminado correctamente' });
        setTimeout(() => this.router.navigate(['/Pago']), 1500);
      },
      error: (error: any) => {
        this.messageService.add({ severity: 'error', summary: 'Error', detail: error.error?.message || 'Error al eliminar el Payment' });
        this.loading = false;
        setTimeout(() => this.router.navigate(['/Pago']), 2000);
      }
    });
  }
}
