export interface ReservationI {
  id?: number;
  reservation_date: Date;
  checkin_date: Date;
  checkout_date: Date;
  number_of_guests: number;
  total_amount: number;
  client_id: number;
  room_id: number;
  status: "ACTIVE" | "INACTIVE";
}


export interface ReservationResponseI {
  id?: number;
  reservation_date: Date;
  checkin_date: Date;
  checkout_date: Date;
  number_of_guests: number;
  total_amount: number;
  client_id: number;
  room_id: number;

}
