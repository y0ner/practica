import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, BehaviorSubject, tap, catchError, throwError } from 'rxjs';
import { map } from 'rxjs/operators';
import { RoomI, RoomResponseI } from '../models/Room';
import { AuthService } from './auth.service';

// Interfaz para la respuesta del backend (espera un objeto con una propiedad que es el array)
interface RoomApiResponse {
  rooms: RoomResponseI[];
}

@Injectable({
  providedIn: 'root'
})
export class RoomService {
  private baseUrl = 'http://localhost:4000/api/Room';
  private RoomSubject = new BehaviorSubject<RoomResponseI[]>([]);
  public Room$ = this.RoomSubject.asObservable();

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

  getAll(): Observable<RoomResponseI[]> {
    return this.http.get<RoomApiResponse>(this.baseUrl, { headers: this.getHeaders() })
      .pipe(
        map(response => response.rooms), // Extraer el array de la propiedad
        tap(Room => {
          this.RoomSubject.next(Room);
        }),
        catchError(error => {
          console.error('Error fetching Room:', error);
          return throwError(() => error);
        })
      );
  }

  getById(id: number): Observable<RoomResponseI> {
    return this.http.get<RoomResponseI>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        catchError(error => {
          console.error(`Error fetching Room with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  create(data: RoomI): Observable<RoomResponseI> {
    return this.http.post<RoomResponseI>(this.baseUrl, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error creating Room:', error);
          return throwError(() => error);
        })
      );
  }

  update(id: number, data: Partial<RoomI>): Observable<RoomResponseI> {
    return this.http.patch<RoomResponseI>(`${this.baseUrl}/${id}`, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error updating Room with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error deleting Room with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  deleteLogic(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}/logic`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error logic-deleting Room with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  refresh(): void {
    this.getAll().subscribe();
  }

  updateLocalData(Room: RoomResponseI[]): void {
    this.RoomSubject.next(Room);
  }
}
