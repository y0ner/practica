import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject, tap, catchError, throwError } from 'rxjs';
import { map } from 'rxjs/operators';
import { ClientI, ClientResponseI } from '../models/Clientes';

// Interfaz para la respuesta paginada de Django
interface PaginatedResponse<T> {
  count: number;
  next: string | null;
  previous: string | null;
  results: T[];
}

@Injectable({
  providedIn: 'root'
})
export class ClientService {
  private baseUrl = 'http://localhost:4000/api/Clientes';
  private ClientesSubject = new BehaviorSubject<ClientResponseI[]>([]);
  public Clientes$ = this.ClientesSubject.asObservable();

  constructor(private http: HttpClient) {}

  getAll(): Observable<ClientResponseI[]> {
    return this.http.get<PaginatedResponse<ClientResponseI>>(`${this.baseUrl}/`)
      .pipe(
        map(response => response.results), // Extraer solo el array de results
        tap(Clientes => {
          this.ClientesSubject.next(Clientes);
        }),
        catchError(error => {
          console.error('Error fetching Clientes:', error);
          return throwError(() => error);
        })
      );
  }

  getById(id: number): Observable<ClientResponseI> {
    return this.http.get<ClientResponseI>(`${this.baseUrl}/${id}/`)
      .pipe(
        catchError(error => {
          console.error('Error fetching Client:', error);
          return throwError(() => error);
        })
      );
  }

  create(data: ClientI): Observable<ClientResponseI> {
    return this.http.post<ClientResponseI>(`${this.baseUrl}/`, data)
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error creating Client:', error);
          return throwError(() => error);
        })
      );
  }

  update(id: number, data: Partial<ClientI>): Observable<ClientResponseI> {
    return this.http.put<ClientResponseI>(`${this.baseUrl}/${id}/`, data)
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error updating Client:', error);
          return throwError(() => error);
        })
      );
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}/`)
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error deleting Client:', error);
          return throwError(() => error);
        })
      );
  }

  refresh(): void {
    this.getAll().subscribe();
  }
}
