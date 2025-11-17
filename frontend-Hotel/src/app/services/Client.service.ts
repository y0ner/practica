import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, BehaviorSubject, tap, catchError, throwError } from 'rxjs';
import { map } from 'rxjs/operators';
import { ClientI, ClientResponseI } from '../models/Client';
import { AuthService } from './auth.service';

// Interfaz para la respuesta del backend (espera un objeto con una propiedad que es el array)
interface ClientApiResponse {
  clients: ClientResponseI[];
}

@Injectable({
  providedIn: 'root'
})
export class ClientService {
  private baseUrl = 'http://localhost:4000/api/Client';
  private ClientSubject = new BehaviorSubject<ClientResponseI[]>([]);
  public Client$ = this.ClientSubject.asObservable();

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

  getAll(): Observable<ClientResponseI[]> {
    return this.http.get<ClientApiResponse>(this.baseUrl, { headers: this.getHeaders() })
      .pipe(
        map(response => response.clients), // Extraer el array de la propiedad
        tap(Client => {
          this.ClientSubject.next(Client);
        }),
        catchError(error => {
          console.error('Error fetching Client:', error);
          return throwError(() => error);
        })
      );
  }

  getById(id: number): Observable<ClientResponseI> {
    return this.http.get<ClientResponseI>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        catchError(error => {
          console.error(`Error fetching Client with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  create(data: ClientI): Observable<ClientResponseI> {
    return this.http.post<ClientResponseI>(this.baseUrl, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error('Error creating Client:', error);
          return throwError(() => error);
        })
      );
  }

  update(id: number, data: Partial<ClientI>): Observable<ClientResponseI> {
    return this.http.patch<ClientResponseI>(`${this.baseUrl}/${id}`, data, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error updating Client with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error deleting Client with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  deleteLogic(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}/logic`, { headers: this.getHeaders() })
      .pipe(
        tap(() => this.refresh()),
        catchError(error => {
          console.error(`Error logic-deleting Client with id ${id}:`, error);
          return throwError(() => error);
        })
      );
  }

  refresh(): void {
    this.getAll().subscribe();
  }

  updateLocalData(Client: ClientResponseI[]): void {
    this.ClientSubject.next(Client);
  }
}
