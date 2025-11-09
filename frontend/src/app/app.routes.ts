import { Routes } from '@angular/router';

// Imports para todos los componentes CRUD
import { Getall as Getall } from './components//getall/getall.component';
import { Create as Create } from './components//create/create.component';
import { Update as Update } from './components//update/update.component';
import { Delete as Delete } from './components//delete/delete.component';

export const routes: Routes = [
    { 
        path: '', 
        redirectTo: '/', 
        pathMatch: 'full' 
    },
    { path: "s", component: Getall },
    { path: "s/new", component: Create },
    { path: "s/edit/:id", component: Update },
    { path: "s/delete/:id", component: Delete },
];
