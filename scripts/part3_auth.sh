#!/bin/bash

# Este archivo contendrá las funciones para la autenticación y autorización.

setup_authentication() {
    print_step "Implementando Autenticación y Autorización (JWT)"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    cd "$PROJECTS_DIR/$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }

    # 1. Crear modelo Auth
    print_msg "Creando modelo en src/app/models/auth.ts"
    mkdir -p src/app/models
    cat << 'EOF' > src/app/models/auth.ts
export interface LoginI {
  email: string;
  password: string;
}


export interface LoginResponseI {
  token: string;
  user: {
    id: number;
    username: string;
    email: string;
    password: string;
    is_active: "ACTIVE" | "INACTIVE";
    avatar: string;
  };
}


export interface RegisterI {
  username: string;  
  email: string;
  password: string;
}

export interface RegisterResponseI {
  token: string;
  user: {
    id: number;
    username: string;
    email: string;
    password: string;
    is_active: "ACTIVE" | "INACTIVE";
    avatar: string;
  };
}



export interface UserI {
  id: number;
  username:string;
  email: string;
  password: string;
  is_active: "ACTIVE" | "INACTIVE";
  avatar: string;
}
EOF

    # 2. Crear servicio Auth (versión final con BehaviorSubject)
    print_msg "Creando servicio en src/app/services/auth.service.ts"
    mkdir -p src/app/services
    cat << 'EOF' > src/app/services/auth.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap, BehaviorSubject } from 'rxjs';
import { LoginI, LoginResponseI, RegisterI, RegisterResponseI} from '../models/auth';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private baseUrl = 'http://localhost:4000/api';
  private tokenKey = 'auth_token';
  private authStateSubject = new BehaviorSubject<boolean>(this.hasValidToken());
  public authState$ = this.authStateSubject.asObservable();

  constructor(private http: HttpClient) {}

  login(credentials: LoginI): Observable<LoginResponseI> {
    return this.http.post<LoginResponseI>(`${this.baseUrl}/login`, credentials)
      .pipe(
        tap(response => {
          if (response.token) {
            this.setToken(response.token);
            this.authStateSubject.next(true);
          }
        })
      );
  }

  register(userData: RegisterI): Observable<RegisterResponseI> {
    return this.http.post<RegisterResponseI>(`${this.baseUrl}/register`, userData)
      .pipe(
        tap(response => {
          if (response.token) {
            this.setToken(response.token);
            this.authStateSubject.next(true);
          }
        })
      );
  }

  logout(): void {
    localStorage.removeItem(this.tokenKey);
    this.authStateSubject.next(false);
  }

  getToken(): string | null {
    return localStorage.getItem(this.tokenKey);
  }

  setToken(token: string): void {
    localStorage.setItem(this.tokenKey, token);
  }

  isLoggedIn(): boolean {
    return this.hasValidToken();
  }

  private hasValidToken(): boolean {
    const token = this.getToken();
    if (!token) return false;

    // Aquí puedes agregar validación adicional del token si es necesario
    // Por ejemplo, verificar si el token no ha expirado
    return true;
  }
}
EOF

    # 3. Actualizar app.component.ts y app.html
    print_msg "Actualizando app.component.ts para controlar visibilidad del layout"
    cat << 'EOF' > src/app/app.ts
import { Component, signal } from '@angular/core';
import { RouterOutlet, RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';
import { Aside } from './components/layout/aside/aside';
import { Header } from './components/layout/header/header';
import { Footer } from './components/layout/footer/footer';
import { AuthService } from './services/auth.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, Header, Footer, Aside, CommonModule, RouterLink],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  protected readonly title = signal('appfront');

  constructor(public authService: AuthService) {}
}
EOF

    print_msg "Actualizando app.component.html para mostrar layout condicionalmente"
    cat << 'EOF' > src/app/app.html
<!-- Layout principal, solo se muestra si el usuario está logueado -->
<main *ngIf="authService.isLoggedIn()" class="min-h-screen flex flex-col">
  <header class="h-16 bg-white border-b flex items-center w-full font-bold text-blue-600">
    <app-header class="w-full"></app-header>
  </header>

  <div class="flex flex-1">
    <aside class="w-64 bg-white border-r flex items-start justify-start font-bold text-blue-400">
      <app-aside></app-aside>
    </aside>

    <section class="flex-1 bg-gray-50 p-6">
      <router-outlet />
    </section>
  </div>

  <footer class="h-16 bg-white border-t flex items-center justify-center font-bold text-blue-600 mt-auto">
    <app-footer></app-footer>
  </footer>
</main>

<!-- Si no está logueado, solo se renderiza el router-outlet (para login/register) -->
<router-outlet *ngIf="!authService.isLoggedIn()"></router-outlet>
EOF

    # 4. Actualizar Header (TS y HTML, versiones finales)
    print_msg "Actualizando src/app/components/layout/header/header.component.ts con menú dinámico"
    cat << 'EOF' > src/app/components/layout/header/header.ts
import { Component, OnInit, OnDestroy } from '@angular/core';
import { Router } from '@angular/router';
import { MenuItem } from 'primeng/api';
import { OverlayBadge } from 'primeng/overlaybadge';
import { TieredMenu } from 'primeng/tieredmenu';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../../services/auth.service';
import { Subscription } from 'rxjs';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [CommonModule, OverlayBadge, TieredMenu, RouterLink],
  templateUrl: './header.html',
  styleUrl: './header.css'
})
export class Header implements OnInit, OnDestroy {
  items: MenuItem[] = [];
  isLoggedIn = false;
  private authSubscription?: Subscription;

  constructor(
    private router: Router,
    public authService: AuthService
  ) {}

  ngOnInit() {
    // Escuchar cambios en el estado de autenticación para actualizar el menú
    this.authSubscription = this.authService.authState$.subscribe(isLoggedIn => {
      this.isLoggedIn = isLoggedIn;
      this.updateMenuItems();
    });
    // Carga inicial
    this.isLoggedIn = this.authService.isLoggedIn();
    this.updateMenuItems();
  }

  ngOnDestroy() {
    if (this.authSubscription) {
      this.authSubscription.unsubscribe();
    }
  }

  private updateMenuItems(): void {
    if (this.isLoggedIn) {
      this.items = [
        { label: 'Configuración', icon: 'pi pi-cog' },
        { label: 'Información', icon: 'pi pi-info-circle' },
        { separator: true },
        { label: 'Cerrar sesión', icon: 'pi pi-sign-out', command: () => this.logout() }
      ];
    } else {
      this.items = [
        { label: 'Iniciar sesión', icon: 'pi pi-sign-in', command: () => this.goToLogin() },
        { label: 'Registrarse', icon: 'pi pi-user-plus', command: () => this.goToRegister() }
      ];
    }
  }

  private logout(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
  }

  private goToLogin(): void {
    this.router.navigate(['/login']);
  }

  private goToRegister(): void {
    this.router.navigate(['/register']);
  }
}
EOF

    print_msg "Actualizando src/app/components/layout/header/header.component.html"
    cat << 'EOF' > src/app/components/layout/header/header.html
<!-- Botones derechos alineados totalmente a la derecha -->
<div class="w-full flex justify-end items-center gap-2 px-4">

    <!-- Solo mostrar notificaciones si está logueado -->
    <button 
        *ngIf="isLoggedIn"
        type="button" 
        class="text-orange-500 bg-gray-100 hover:bg-gray-200 rounded-full shadow hover:shadow-lg flex items-center justify-center w-10 h-10">
        <p-overlaybadge value="2">
            <i class="pi pi-bell text-xl"></i>
        </p-overlaybadge>
    </button>

    <button type="button"
        class="text-orange-500 bg-gray-100 hover:bg-gray-200 rounded-full shadow hover:shadow-lg w-10 h-10 flex items-center justify-center"
        (click)="menu.toggle($event)">
        <i class="pi pi-user text-xl"></i>
    </button>
</div>

<!-- Menú fuera del contenedor de botones -->
<p-tieredmenu #menu [model]="items" [popup]="true" />
EOF
    
    # 5. Configurar providers y estilos (Método definitivo)
    print_msg "Corrigiendo src/app/app.config.ts para incluir provideHttpClient y preservar la configuración del tema..."

    # Leemos el tema y la ruta para mantener la selección del usuario
    THEME_PRESET_NAME=$(grep -oP "(?<=preset: )\w+" src/app/app.config.ts | head -n 1)
    THEME_IMPORT_PATH=$(grep -oP "(?<=from ')[^']+(?=';)" src/app/app.config.ts | grep 'themes' | head -n 1)

    # Reescribimos el archivo app.config.ts con la estructura correcta y definitiva.
    cat << EOF > src/app/app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { provideHttpClient } from '@angular/common/http';
import { providePrimeNG } from 'primeng/config';
import { ConfirmationService, MessageService } from 'primeng/api';
import ${THEME_PRESET_NAME} from '${THEME_IMPORT_PATH}';

import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideAnimationsAsync(),
    provideHttpClient(),
    providePrimeNG({ theme: {
            preset: ${THEME_PRESET_NAME},
            options: { darkModeSelector: false }
        } }),
    ConfirmationService,
    MessageService
  ]
};
EOF
    print_success "El archivo src/app/app.config.ts ha sido corregido."

    print_msg "Instalando primeicons..."
    npm install primeicons

    print_msg "Importando primeicons en src/styles.css"
    # Añadir la importación solo si no existe
    if ! grep -q "primeicons.css" src/styles.css; then
        echo '@import "primeicons/primeicons.css";' >> src/styles.css
        print_success "Primeicons importado en styles.css."
    else
        print_msg "Primeicons ya estaba importado en styles.css."
    fi

    # 6. Generar componentes Login y Register
    print_msg "Generando componentes de autenticación..."
    ng g c components/auth/login --skip-tests
    ng g c components/auth/register --skip-tests

    # 7. Actualizar componente Login (TS y HTML)
    print_msg "Actualizando src/app/components/auth/login/login.component.ts"
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

    print_msg "Actualizando src/app/components/auth/login/login.component.html"
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

    # 8. Actualizar componente Register (TS y HTML)
    print_msg "Actualizando src/app/components/auth/register/register.component.ts"
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

    print_msg "Actualizando src/app/components/auth/register/register.component.html"
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

    # 9. Crear AuthGuard
    print_msg "Creando AuthGuard en src/app/guards/auth.guard.ts"
    mkdir -p src/app/guards
    cat << 'EOF' > src/app/guards/authguard.ts
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isLoggedIn()) {
    return true;
  }

  router.navigate(['/login']);
  return false;
};
EOF

    # 10. Actualizar rutas (app.routes.ts)
    print_msg "Actualizando src/app/app.routes.ts con rutas protegidas"
    # Leemos las tablas del archivo .table_names para generar las rutas dinámicamente
    if [ ! -f ".table_names" ]; then
        print_error "No se encontró el archivo '.table_names'. Las rutas CRUD no se pueden proteger. Ejecuta el paso 6 de la sección 1."
        return 1
    fi
    mapfile -t table_names < .table_names

    local crud_imports=""
    local crud_routes=""
    for table_name in "${table_names[@]}"; do
        local lower_name="$table_name"
        local capitalized_name="$(tr '[:lower:]' '[:upper:]' <<< ${lower_name:0:1})${lower_name:1}"
        crud_imports+=$(cat <<EOF
import { Getall as ${capitalized_name}Getall } from './components/${lower_name}/getall/getall';
import { Create as ${capitalized_name}Create } from './components/${lower_name}/create/create';
import { Update as ${capitalized_name}Update } from './components/${lower_name}/update/update';
import { Delete as ${capitalized_name}Delete } from './components/${lower_name}/delete/delete';
EOF
)
        crud_routes+=$(cat <<EOF
    { path: '${lower_name}', component: ${capitalized_name}Getall, canActivate: [authGuard] },
    { path: '${lower_name}/new', component: ${capitalized_name}Create, canActivate: [authGuard] },
    { path: '${lower_name}/edit/:id', component: ${capitalized_name}Update, canActivate: [authGuard] },
    { path: '${lower_name}/delete/:id', component: ${capitalized_name}Delete, canActivate: [authGuard] },
EOF
)
    done

    cat << EOF > src/app/app.routes.ts
import { Routes } from '@angular/router';
import { Login } from './components/auth/login/login';
import { Register } from './components/auth/register/register';
import { authGuard } from './guards/authguard';

// CRUD imports
${crud_imports}

export const routes: Routes = [
    { path: 'login', component: Login },
    { path: 'register', component: Register },

    // Ruta raíz protegida que redirige a la primera tabla
    { path: '', redirectTo: '/${table_names[0]}', pathMatch: 'full' },

    // CRUD routes
${crud_routes}

    // Wildcard route
    { path: '**', redirectTo: '/login' }
];
EOF

    print_success "Implementación de Autenticación y Autorización completada."

    # Volvemos al directorio original del script
    local script_dir; script_dir=$(dirname "$(realpath "$0")")
    cd "$script_dir" || return
}