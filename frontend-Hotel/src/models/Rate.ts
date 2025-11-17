export interface RateI {
  id?: number;
  amount: number;
  currency: string;
  description: string;
  refundable: boolean;
  season_id: number;
  room_type_id: number;
  status: "ACTIVE" | "INACTIVE";
}


export interface RateResponseI {
  id?: number;
  amount: number;
  currency: string;
  description: string;
  refundable: boolean;
  room_type_id: number;
  season_id: number;

}
