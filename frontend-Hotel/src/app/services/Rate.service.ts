import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, BehaviorSubject, tap, catchError, throwError } from 'rxjs';
import { map } from 'rxjs/operators';
import { RateI, RateResponseI } from '../models/Rate';
import { AuthService } from './auth.service';

// Interfaz para la respuesta del backend (espera un objeto con una propiedad que es el array)
interface RateApiResponse {
  rates: RateResponseI[];
}

@Injectable({
  providedIn: 'root'
})
export class RateService {
  private baseUrl = 'http://localhost:4000/api/Rate';
  private RateSubject = new BehaviorSubject<RateResponseI[]>([]);
  public Rate$ = this.RateSubject.asObservable();

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

  getAll(): Observable<RateResponseI[]> {
    return this.http.get<RateApiResponse>(this.baseUrl, { headers: this.getHeaders() })
      .pipe(
        map(response => response.rates), // Extraer el array de la propiedad
        tap(Rate => {
          this.RateSubject.next(Rate);
        }),
        catchError(error => {
          console.error('Error fetching Rate:', error);
          return throwError(() => error);
        })
      );
  }

  getById(id: number): Observable<RateResponseI> {
    return this.http.get<RateResponseI>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        catchError(error => {
          console.error(`Error fetching Rate with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  create(data: RateI): Observable<RateResponseI> {
    return this.http.post<RateResponseI>(this.baseUrl, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error creating Rate:', error);
          return throwError(() => error);
        })
      );
  }

  update(id: number, data: Partial<RateI>): Observable<RateResponseI> {
    return this.http.patch<RateResponseI>(`${this.baseUrl}/${id}`, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error updating Rate with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error deleting Rate with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  deleteLogic(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}/logic`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error logic-deleting Rate with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  refresh(): void {
    this.getAll().subscribe();
  }

  updateLocalData(Rate: RateResponseI[]): void {
    this.RateSubject.next(Rate);
  }
}
