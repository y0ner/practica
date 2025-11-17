#!/bin/bash

# Este archivo contiene la lógica para generar y actualizar los componentes
# de autenticación (Login y Register).

create_and_update_auth_components() {
    print_step "Generando y actualizando componentes de autenticación"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No se ha seleccionado un proyecto."
        return 1
    fi

    local project_path="$PROJECTS_DIR/$PROJECT_NAME"
    cd "$project_path" || { print_error "No se pudo acceder al directorio del proyecto."; return 1; }

    print_msg "Generando componentes de autenticación: Login y Register..."
    ng g c components/auth/login --skip-tests
    ng g c components/auth/register --skip-tests

    print_msg "Actualizando componente Login (TS y HTML)..."
    cat << 'EOF' > src/app/components/auth/login/login.ts
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { MessageService } from 'primeng/api';
import { ToastModule } from 'primeng/toast';
import { AuthService } from '../../../services/auth.service';
import { CardModule } from 'primeng/card';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, ButtonModule, InputTextModule, ToastModule, CardModule, RouterLink, ReactiveFormsModule],
  templateUrl: './login.html',
  styleUrl: './login.css',
  providers: [MessageService]
})
export class Login {
  form: FormGroup;
  loading: boolean = false;

  constructor(
    private fb: FormBuilder,
    private router: Router,
    private authService: AuthService,
    private messageService: MessageService
  ) {
    this.form = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(6)]]
    });
  }

  submit(): void {
    if (this.form.valid) {
      this.loading = true;
      const credentials = this.form.value;

      this.authService.login(credentials).subscribe({
        next: (response) => {
          this.messageService.add({
            severity: 'success',
            summary: 'Éxito',
            detail: 'Sesión iniciada correctamente'
          });
          setTimeout(() => {
            this.router.navigate(['/']); // Redirigir a la raíz protegida
          }, 1000);
        },
        error: (error) => {
          console.error('Error logging in:', error);
          this.messageService.add({
            severity: 'error',
            summary: 'Error',
            detail: 'Credenciales incorrectas'
          });
          this.loading = false;
        }
      });
    } else {
      this.form.markAllAsTouched();
    }
  }
}
EOF

    cat << 'EOF' > src/app/components/auth/login/login.html
<div class="min-h-screen flex items-center justify-center bg-gray-50">
  <div class="max-w-md w-full p-4">
    <p-card header="Iniciar Sesión" class="shadow-lg">
      <form [formGroup]="form" (ngSubmit)="submit()" class="space-y-6">
        <div class="flex flex-col">
          <label for="email" class="block mb-2 font-semibold text-gray-700">Email *</label>
          <input pInputText id="email" type="email" formControlName="email" class="w-full" placeholder="ejemplo@correo.com" />
          <small class="text-red-500 mt-1" *ngIf="form.get('email')?.invalid && form.get('email')?.touched">Email no válido</small>
        </div>

        <div class="flex flex-col">
          <label for="password" class="block mb-2 font-semibold text-gray-700">Contraseña *</label>
          <input pInputText id="password" type="password" formControlName="password" class="w-full" placeholder="Ingrese su contraseña" />
          <small class="text-red-500 mt-1" *ngIf="form.get('password')?.invalid && form.get('password')?.touched">La contraseña es requerida</small>
        </div>

        <div class="flex flex-col space-y-3 mt-6">
          <button pButton type="submit" class="w-full" label="Iniciar Sesión" icon="pi pi-sign-in" [loading]="loading" [disabled]="form.invalid || loading"></button>
          <a routerLink="/register" class="text-center text-blue-500 hover:underline">¿No tienes cuenta? Registrarse</a>
        </div>
      </form>
    </p-card>
  </div>
</div>
<p-toast></p-toast>
EOF

    print_msg "Actualizando componente Register (TS y HTML)..."
    cat << 'EOF' > src/app/components/auth/register/register.ts
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators, AbstractControl } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { MessageService } from 'primeng/api';
import { ToastModule } from 'primeng/toast';
import { AuthService } from '../../../services/auth.service';
import { CardModule } from 'primeng/card';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, ButtonModule, InputTextModule, ToastModule, CardModule, RouterLink, ReactiveFormsModule],
  templateUrl: './register.html',
  styleUrl: './register.css',
  providers: [MessageService]
})
export class Register {
  form: FormGroup;
  loading: boolean = false;

  constructor(
    private fb: FormBuilder,
    private router: Router,
    private authService: AuthService,
    private messageService: MessageService
  ) {
    this.form = this.fb.group({
      username: ['', [Validators.required, Validators.minLength(2)]],
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', [Validators.required]]
    }, { validators: this.passwordMatchValidator });
  }

  passwordMatchValidator(control: AbstractControl) {
    const password = control.get('password');
    const confirmPassword = control.get('confirmPassword');
    if (password?.value !== confirmPassword?.value) {
      confirmPassword?.setErrors({ passwordMismatch: true });
      return { passwordMismatch: true };
    }
    return null;
  }

  submit(): void {
    if (this.form.valid) {
      this.loading = true;
      const { confirmPassword, ...registerData } = this.form.value;

      this.authService.register(registerData).subscribe({
        next: (response) => {
          this.messageService.add({
            severity: 'success',
            summary: 'Éxito',
            detail: 'Usuario registrado correctamente'
          });
          setTimeout(() => {
            this.router.navigate(['/']);
          }, 1000);
        },
        error: (error) => {
          this.messageService.add({
            severity: 'error',
            summary: 'Error',
            detail: error.error?.message || 'Error al registrar usuario'
          });
          this.loading = false;
        }
      });
    } else {
      this.form.markAllAsTouched();
    }
  }
}
EOF

    cat << 'EOF' > src/app/components/auth/register/register.html
<div class="min-h-screen flex items-center justify-center bg-gray-50">
  <div class="max-w-md w-full p-4">
    <p-card header="Registrar Usuario" class="shadow-lg">
      <form [formGroup]="form" (ngSubmit)="submit()" class="space-y-6">
        
        <div class="flex flex-col"><label for="username" class="block mb-2 font-semibold text-gray-700">Username *</label><input pInputText id="username" type="text" formControlName="username" class="w-full" /><small class="text-red-500 mt-1" *ngIf="form.get('username')?.invalid && form.get('username')?.touched">Username es requerido</small></div>
        <div class="flex flex-col"><label for="email" class="block mb-2 font-semibold text-gray-700">Email *</label><input pInputText id="email" type="email" formControlName="email" class="w-full" /><small class="text-red-500 mt-1" *ngIf="form.get('email')?.invalid && form.get('email')?.touched">Email no válido</small></div>
        <div class="flex flex-col"><label for="password" class="block mb-2 font-semibold text-gray-700">Contraseña *</label><input pInputText id="password" type="password" formControlName="password" class="w-full" /><small class="text-red-500 mt-1" *ngIf="form.get('password')?.invalid && form.get('password')?.touched">La contraseña debe tener al menos 6 caracteres</small></div>
        <div class="flex flex-col"><label for="confirmPassword" class="block mb-2 font-semibold text-gray-700">Confirmar Contraseña *</label><input pInputText id="confirmPassword" type="password" formControlName="confirmPassword" class="w-full" /><small class="text-red-500 mt-1" *ngIf="form.get('confirmPassword')?.hasError('passwordMismatch')">Las contraseñas no coinciden</small></div>

        <div class="flex flex-col space-y-3 mt-6">
          <button pButton type="submit" class="w-full" label="Registrarse" icon="pi pi-user-plus" [loading]="loading" [disabled]="form.invalid || loading"></button>
          <a routerLink="/login" class="text-center text-blue-500 hover:underline">¿Ya tienes cuenta? Iniciar Sesión</a>
        </div>
      </form>
    </p-card>
  </div>
</div>
<p-toast></p-toast>
EOF

    print_success "Componentes de autenticación generados y actualizados."
    cd - > /dev/null
}