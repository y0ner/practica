export interface ReservationServiceI {
  id?: number;
  quantity: number;
  reservation_id: number;
  service_id: number;
  status: "ACTIVE" | "INACTIVE";
}


export interface ReservationServiceResponseI {
  id?: number;
  quantity: number;
  reservation_id: number;
  service_id: number;

}
