import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, BehaviorSubject, tap, catchError, throwError } from 'rxjs';
import { map } from 'rxjs/operators';
import { ServiceI, ServiceResponseI } from '../models/Service';
import { AuthService } from './auth.service';

// Interfaz para la respuesta del backend (espera un objeto con una propiedad que es el array)
interface ServiceApiResponse {
  services: ServiceResponseI[];
}

@Injectable({
  providedIn: 'root'
})
export class ServiceService {
  private baseUrl = 'http://localhost:4000/api/Service';
  private ServiceSubject = new BehaviorSubject<ServiceResponseI[]>([]);
  public Service$ = this.ServiceSubject.asObservable();

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

  getAll(): Observable<ServiceResponseI[]> {
    return this.http.get<ServiceApiResponse>(this.baseUrl, { headers: this.getHeaders() })
      .pipe(
        map(response => response.services), // Extraer el array de la propiedad
        tap(Service => {
          this.ServiceSubject.next(Service);
        }),
        catchError(error => {
          console.error('Error fetching Service:', error);
          return throwError(() => error);
        })
      );
  }

  getById(id: number): Observable<ServiceResponseI> {
    return this.http.get<ServiceResponseI>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        catchError(error => {
          console.error(`Error fetching Service with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  create(data: ServiceI): Observable<ServiceResponseI> {
    return this.http.post<ServiceResponseI>(this.baseUrl, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error creating Service:', error);
          return throwError(() => error);
        })
      );
  }

  update(id: number, data: Partial<ServiceI>): Observable<ServiceResponseI> {
    return this.http.patch<ServiceResponseI>(`${this.baseUrl}/${id}`, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error updating Service with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error deleting Service with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  deleteLogic(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}/logic`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error logic-deleting Service with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  refresh(): void {
    this.getAll().subscribe();
  }

  updateLocalData(Service: ServiceResponseI[]): void {
    this.ServiceSubject.next(Service);
  }
}
