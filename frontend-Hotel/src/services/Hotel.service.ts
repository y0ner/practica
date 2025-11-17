import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, BehaviorSubject, tap, catchError, throwError } from 'rxjs';
import { map } from 'rxjs/operators';
import { HotelI, HotelResponseI } from '../models/Hotel';
import { AuthService } from './auth.service';

// Interfaz para la respuesta del backend (espera un objeto con una propiedad que es el array)
interface HotelApiResponse {
  hotels: HotelResponseI[];
}

@Injectable({
  providedIn: 'root'
})
export class HotelService {
  private baseUrl = 'http://localhost:4000/api/Hotel';
  private HotelSubject = new BehaviorSubject<HotelResponseI[]>([]);
  public Hotel$ = this.HotelSubject.asObservable();

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

  getAll(): Observable<HotelResponseI[]> {
    return this.http.get<HotelApiResponse>(this.baseUrl, { headers: this.getHeaders() })
      .pipe(
        map(response => response.hotels), // Extraer el array de la propiedad
        tap(Hotel => {
          this.HotelSubject.next(Hotel);
        }),
        catchError(error => {
          console.error('Error fetching Hotel:', error);
          return throwError(() => error);
        })
      );
  }

  getById(id: number): Observable<HotelResponseI> {
    return this.http.get<HotelResponseI>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        catchError(error => {
          console.error(`Error fetching Hotel with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  create(data: HotelI): Observable<HotelResponseI> {
    return this.http.post<HotelResponseI>(this.baseUrl, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error creating Hotel:', error);
          return throwError(() => error);
        })
      );
  }

  update(id: number, data: Partial<HotelI>): Observable<HotelResponseI> {
    return this.http.patch<HotelResponseI>(`${this.baseUrl}/${id}`, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error updating Hotel with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error deleting Hotel with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  deleteLogic(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}/logic`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error logic-deleting Hotel with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  refresh(): void {
    this.getAll().subscribe();
  }

  updateLocalData(Hotel: HotelResponseI[]): void {
    this.HotelSubject.next(Hotel);
  }
}
