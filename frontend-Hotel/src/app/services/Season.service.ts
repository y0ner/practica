import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, BehaviorSubject, tap, catchError, throwError } from 'rxjs';
import { map } from 'rxjs/operators';
import { SeasonI, SeasonResponseI } from '../models/Season';
import { AuthService } from './auth.service';

// Interfaz para la respuesta del backend (espera un objeto con una propiedad que es el array)
interface SeasonApiResponse {
  seasons: SeasonResponseI[];
}

@Injectable({
  providedIn: 'root'
})
export class SeasonService {
  private baseUrl = 'http://localhost:4000/api/Season';
  private SeasonSubject = new BehaviorSubject<SeasonResponseI[]>([]);
  public Season$ = this.SeasonSubject.asObservable();

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

  getAll(): Observable<SeasonResponseI[]> {
    return this.http.get<SeasonApiResponse>(this.baseUrl, { headers: this.getHeaders() })
      .pipe(
        map(response => response.seasons), // Extraer el array de la propiedad
        tap(Season => {
          this.SeasonSubject.next(Season);
        }),
        catchError(error => {
          console.error('Error fetching Season:', error);
          return throwError(() => error);
        })
      );
  }

  getById(id: number): Observable<SeasonResponseI> {
    return this.http.get<SeasonResponseI>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        catchError(error => {
          console.error(`Error fetching Season with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  create(data: SeasonI): Observable<SeasonResponseI> {
    return this.http.post<SeasonResponseI>(this.baseUrl, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error creating Season:', error);
          return throwError(() => error);
        })
      );
  }

  update(id: number, data: Partial<SeasonI>): Observable<SeasonResponseI> {
    return this.http.patch<SeasonResponseI>(`${this.baseUrl}/${id}`, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error updating Season with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error deleting Season with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  deleteLogic(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}/logic`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error logic-deleting Season with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  refresh(): void {
    this.getAll().subscribe();
  }

  updateLocalData(Season: SeasonResponseI[]): void {
    this.SeasonSubject.next(Season);
  }
}
