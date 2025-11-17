import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, BehaviorSubject, tap, catchError, throwError } from 'rxjs';
import { map } from 'rxjs/operators';
import { PaymentI, PaymentResponseI } from '../models/Payment';
import { AuthService } from './auth.service';

// Interfaz para la respuesta del backend (espera un objeto con una propiedad que es el array)
interface PaymentApiResponse {
  payments: PaymentResponseI[];
}

@Injectable({
  providedIn: 'root'
})
export class PaymentService {
  private baseUrl = 'http://localhost:4000/api/Payment';
  private PaymentSubject = new BehaviorSubject<PaymentResponseI[]>([]);
  public Payment$ = this.PaymentSubject.asObservable();

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

  getAll(): Observable<PaymentResponseI[]> {
    return this.http.get<PaymentApiResponse>(this.baseUrl, { headers: this.getHeaders() })
      .pipe(
        map(response => response.payments), // Extraer el array de la propiedad
        tap(Payment => {
          this.PaymentSubject.next(Payment);
        }),
        catchError(error => {
          console.error('Error fetching Payment:', error);
          return throwError(() => error);
        })
      );
  }

  getById(id: number): Observable<PaymentResponseI> {
    return this.http.get<PaymentResponseI>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        catchError(error => {
          console.error(`Error fetching Payment with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  create(data: PaymentI): Observable<PaymentResponseI> {
    return this.http.post<PaymentResponseI>(this.baseUrl, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error creating Payment:', error);
          return throwError(() => error);
        })
      );
  }

  update(id: number, data: Partial<PaymentI>): Observable<PaymentResponseI> {
    return this.http.patch<PaymentResponseI>(`${this.baseUrl}/${id}`, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error updating Payment with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error deleting Payment with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  deleteLogic(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}/logic`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error logic-deleting Payment with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  refresh(): void {
    this.getAll().subscribe();
  }

  updateLocalData(Payment: PaymentResponseI[]): void {
    this.PaymentSubject.next(Payment);
  }
}
