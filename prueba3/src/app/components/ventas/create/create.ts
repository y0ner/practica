import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { RouterLink } from '@angular/router';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { Select } from 'primeng/select';
import { MessageService } from 'primeng/api';
import { ToastModule } from 'primeng/toast';
import { CardModule } from 'primeng/card';
import { SaleService } from '../../../services/ventas.service';

@Component({
  selector: 'app-create',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, ButtonModule, InputTextModule, Select, ToastModule, CardModule, RouterLink],
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
    private ventasService: SaleService,
    private messageService: MessageService
  ) {
    this.form = this.fb.group({
      client_id: ['', [Validators.required]],
      discounts: ['', [Validators.required]],
      sale_date: ['', [Validators.required]],
      status: ['ACTIVE', []],
      subtotal: ['', [Validators.required]],
      tax: ['', [Validators.required]],
      total: ['', [Validators.required]],
    });
  }

  submit(): void {
    if (this.form.valid) {
      this.loading = true;
      const formData = this.form.value;

      this.ventasService.create(formData).subscribe({
        next: (response) => {
          this.messageService.add({
            severity: 'success',
            summary: 'Éxito',
            detail: 'Sale creado correctamente'
          });
          setTimeout(() => {
            this.router.navigate(['/ventas']);
          }, 1000);
        },
        error: (error) => {
          console.error('Error creating Sale:', error);
          this.messageService.add({
            severity: 'error',
            summary: 'Error',
            detail: error.error?.message || 'Error al crear el Sale'
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
    this.router.navigate(['/ventas']);
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
        return `El campo es requerido.`;
      }
      if (field.errors['minlength']) {
        return `Debe tener al menos ${field.errors['minlength'].requiredLength} caracteres.`;
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
