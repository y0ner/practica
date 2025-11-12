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
import { SaleService } from '../../../services/ventas.service';
import { SaleI, SaleResponseI } from '../../../models/ventas';

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
    private ventasService: SaleService,
    private messageService: MessageService
  ) {
    this.form = this.fb.group({
      client_id: ['', [Validators.required]],
      discounts: ['', [Validators.required]],
      sale_date: ['', [Validators.required]],
      subtotal: ['', [Validators.required]],
      tax: ['', [Validators.required]],
      total: ['', [Validators.required]],
      status: ['ACTIVE', Validators.required]
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
    this.ventasService.getById(this.entityId).subscribe({
      next: (data: SaleResponseI) => {
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

      this.ventasService.update(this.entityId, formData).subscribe({
        next: (response: SaleResponseI) => {
          this.messageService.add({ severity: 'success', summary: 'Éxito', detail: 'Sale actualizado correctamente' });
          setTimeout(() => this.router.navigate(['/ventas']), 1000);
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
    this.router.navigate(['/ventas']);
  }

  private markFormGroupTouched(): void {
    Object.values(this.form.controls).forEach(control => control.markAsTouched());
  }

  getFieldError(fieldName: string): string {
    const field = this.form.get(fieldName);
    if (field?.touched && field.errors) {
      if (field.errors['required']) return 'El campo es requerido.';
      if (field.errors['minlength']) return `Debe tener al menos ${field.errors['minlength'].requiredLength} caracteres.`;
      if (field.errors['email']) return 'El formato del email no es válido.';
      if (field.errors['pattern']) return 'El formato no es válido.';
    }
    return '';
  }
}
