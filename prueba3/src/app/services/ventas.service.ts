import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, BehaviorSubject, tap, catchError, throwError } from 'rxjs';
import { map } from 'rxjs/operators';
import { SaleI, SaleResponseI } from '../models/ventas';
import { AuthService } from './auth.service';

// Interfaz para la respuesta del backend (espera un objeto con una propiedad que es el array)
interface SaleApiResponse {
  sales: SaleResponseI[];
}

@Injectable({
  providedIn: 'root'
})
export class SaleService {
  private baseUrl = 'http://localhost:4000/api/sales';
  private ventasSubject = new BehaviorSubject<SaleResponseI[]>([]);
  public ventas$ = this.ventasSubject.asObservable();

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) {}

  private getHeaders(): HttpHeaders {
    let headers = new HttpHeaders();
    const token = this.authService.getToken();
    if (token) {
      headers = headers.set('Authorization', `Bearer ${token}`);
    }
    return headers;
  }

  getAll(): Observable<SaleResponseI[]> {
    return this.http.get<SaleApiResponse>(this.baseUrl, { headers: this.getHeaders() })
      .pipe(
        map(response => response.sales), // Extraer el array de la propiedad
        tap(ventas => {
          this.ventasSubject.next(ventas);
        }),
        catchError(error => {
          console.error('Error fetching ventas:', error);
          return throwError(() => error);
        })
      );
  }

  getById(id: number): Observable<SaleResponseI> {
    return this.http.get<SaleResponseI>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        catchError(error => {
          console.error(`Error fetching Sale with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  create(data: SaleI): Observable<SaleResponseI> {
    return this.http.post<SaleResponseI>(this.baseUrl, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error creating Sale:', error);
          return throwError(() => error);
        })
      );
  }

  update(id: number, data: Partial<SaleI>): Observable<SaleResponseI> {
    return this.http.patch<SaleResponseI>(`${this.baseUrl}/${id}`, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error updating Sale with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error deleting Sale with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  deleteLogic(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}/logic`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error logic-deleting Sale with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  refresh(): void {
    this.getAll().subscribe();
  }

  updateLocalData(ventas: SaleResponseI[]): void {
    this.ventasSubject.next(ventas);
  }
}
