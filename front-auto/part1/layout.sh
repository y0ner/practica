#!/bin/bash

create_layout_components() {
    print_step "Creando componentes de Layout y actualizando App"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    print_msg "Trabajando en el proyecto: $PROJECT_NAME"
    cd "$PROJECTS_DIR/$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }

    print_msg "Generando componentes Header, Aside, y Footer..."
    ng g c components/layout/header
    ng g c components/layout/aside
    ng g c components/layout/footer
    
    print_msg "Sobrescribiendo archivos .ts de layout con plantilla base..."

cat << 'EOF' > src/app/components/layout/aside/aside.ts
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-aside',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './aside.html',
  styleUrl: './aside.css'
})
export class Aside {

}
EOF

cat << 'EOF' > src/app/components/layout/footer/footer.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-footer',
  standalone: true,
  imports: [],
  templateUrl: './footer.html',
  styleUrl: './footer.css'
})
export class Footer {

}
EOF

cat << 'EOF' > src/app/components/layout/header/header.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [],
  templateUrl: './header.html',
  styleUrl: './header.css'
})
export class Header {

}
EOF

    print_msg "Actualizando src/app/app.ts y src/app/app.html"
    cat << 'EOF' > src/app/app.ts
import { Component, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { Header } from './components/layout/header/header';
import { Footer } from './components/layout/footer/footer';
import { Aside } from './components/layout/aside/aside';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, Header, Footer, Aside],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  protected readonly title = signal('frontend');
}
EOF

    cat << 'EOF' > src/app/app.html
<main class="min-h-screen flex flex-col">
  <header class="h-16 bg-white border-b flex items-center justify-center font-bold text-blue-600">
    <app-header></app-header>
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
EOF

    print_success "Componentes de Layout creados y App actualizada."
    cd - > /dev/null
}