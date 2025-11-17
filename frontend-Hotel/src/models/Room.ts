export interface RoomI {
  id?: number;
  number: number;
  floor: number;
  capacity: number;
  description: string;
  base_price: number;
  available: boolean;
  room_type_id: number;
  hotel_id: number;
  status: "ACTIVE" | "INACTIVE";
}


export interface RoomResponseI {
  id?: number;
  number: number;
  floor: number;
  capacity: number;
  description: string;
  base_price: number;
  available: boolean;
  hotel_id: number;
  room_type_id: number;

}
