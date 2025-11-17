import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, BehaviorSubject, tap, catchError, throwError } from 'rxjs';
import { map } from 'rxjs/operators';
import { RoomTypeI, RoomTypeResponseI } from '../models/RoomType';
import { AuthService } from './auth.service';

// Interfaz para la respuesta del backend (espera un objeto con una propiedad que es el array)
interface RoomTypeApiResponse {
  roomtypes: RoomTypeResponseI[];
}

@Injectable({
  providedIn: 'root'
})
export class RoomTypeService {
  private baseUrl = 'http://localhost:4000/api/RoomType';
  private RoomTypeSubject = new BehaviorSubject<RoomTypeResponseI[]>([]);
  public RoomType$ = this.RoomTypeSubject.asObservable();

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

  getAll(): Observable<RoomTypeResponseI[]> {
    return this.http.get<RoomTypeApiResponse>(this.baseUrl, { headers: this.getHeaders() })
      .pipe(
        map(response => response.roomtypes), // Extraer el array de la propiedad
        tap(RoomType => {
          this.RoomTypeSubject.next(RoomType);
        }),
        catchError(error => {
          console.error('Error fetching RoomType:', error);
          return throwError(() => error);
        })
      );
  }

  getById(id: number): Observable<RoomTypeResponseI> {
    return this.http.get<RoomTypeResponseI>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        catchError(error => {
          console.error(`Error fetching RoomType with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  create(data: RoomTypeI): Observable<RoomTypeResponseI> {
    return this.http.post<RoomTypeResponseI>(this.baseUrl, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error creating RoomType:', error);
          return throwError(() => error);
        })
      );
  }

  update(id: number, data: Partial<RoomTypeI>): Observable<RoomTypeResponseI> {
    return this.http.patch<RoomTypeResponseI>(`${this.baseUrl}/${id}`, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error updating RoomType with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error deleting RoomType with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  deleteLogic(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}/logic`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error logic-deleting RoomType with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  refresh(): void {
    this.getAll().subscribe();
  }

  updateLocalData(RoomType: RoomTypeResponseI[]): void {
    this.RoomTypeSubject.next(RoomType);
  }
}
