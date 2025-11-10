import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject, tap, catchError, throwError } from 'rxjs';
import { map } from 'rxjs/operators';
import { SaleI, SaleResponseI } from '../models/Ventas';

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
export class SaleService {
  private baseUrl = 'http://localhost:4000/api/ventas';
  private VentasSubject = new BehaviorSubject<SaleResponseI[]>([]);
  public Ventas$ = this.VentasSubject.asObservable();

  constructor(private http: HttpClient) {}

  getAll(): Observable<SaleResponseI[]> {
    return this.http.get<PaginatedResponse<SaleResponseI>>(`${this.baseUrl}/`)
      .pipe(
        map(response => response.results), // Extraer solo el array de results
        tap(Ventas => {
          this.VentasSubject.next(Ventas);
        }),
        catchError(error => {
          console.error('Error fetching Ventas:', error);
          return throwError(() => error);
        })
      );
  }

  getById(id: number): Observable<SaleResponseI> {
    return this.http.get<SaleResponseI>(`${this.baseUrl}/${id}/`)
      .pipe(
        catchError(error => {
          console.error('Error fetching Sale:', error);
          return throwError(() => error);
        })
      );
  }

  create(data: SaleI): Observable<SaleResponseI> {
    return this.http.post<SaleResponseI>(`${this.baseUrl}/`, data)
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error creating Sale:', error);
          return throwError(() => error);
        })
      );
  }

  update(id: number, data: Partial<SaleI>): Observable<SaleResponseI> {
    return this.http.put<SaleResponseI>(`${this.baseUrl}/${id}/`, data)
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error updating Sale:', error);
          return throwError(() => error);
        })
      );
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}/`)
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error deleting Sale:', error);
          return throwError(() => error);
        })
      );
  }

  refresh(): void {
    this.getAll().subscribe();
  }
}
