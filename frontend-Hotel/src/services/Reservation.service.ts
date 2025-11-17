import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, BehaviorSubject, tap, catchError, throwError } from 'rxjs';
import { map } from 'rxjs/operators';
import { ReservationI, ReservationResponseI } from '../models/Reservation';
import { AuthService } from './auth.service';

// Interfaz para la respuesta del backend (espera un objeto con una propiedad que es el array)
interface ReservationApiResponse {
  reservations: ReservationResponseI[];
}

@Injectable({
  providedIn: 'root'
})
export class ReservationService {
  private baseUrl = 'http://localhost:4000/api/Reservation';
  private ReservationSubject = new BehaviorSubject<ReservationResponseI[]>([]);
  public Reservation$ = this.ReservationSubject.asObservable();

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

  getAll(): Observable<ReservationResponseI[]> {
    return this.http.get<ReservationApiResponse>(this.baseUrl, { headers: this.getHeaders() })
      .pipe(
        map(response => response.reservations), // Extraer el array de la propiedad
        tap(Reservation => {
          this.ReservationSubject.next(Reservation);
        }),
        catchError(error => {
          console.error('Error fetching Reservation:', error);
          return throwError(() => error);
        })
      );
  }

  getById(id: number): Observable<ReservationResponseI> {
    return this.http.get<ReservationResponseI>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        catchError(error => {
          console.error(`Error fetching Reservation with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  create(data: ReservationI): Observable<ReservationResponseI> {
    return this.http.post<ReservationResponseI>(this.baseUrl, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error creating Reservation:', error);
          return throwError(() => error);
        })
      );
  }

  update(id: number, data: Partial<ReservationI>): Observable<ReservationResponseI> {
    return this.http.patch<ReservationResponseI>(`${this.baseUrl}/${id}`, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error updating Reservation with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error deleting Reservation with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  deleteLogic(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}/logic`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error logic-deleting Reservation with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  refresh(): void {
    this.getAll().subscribe();
  }

  updateLocalData(Reservation: ReservationResponseI[]): void {
    this.ReservationSubject.next(Reservation);
  }
}
