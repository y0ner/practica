export interface RoomTypeI {
  id?: number;
  name: string;
  description: string;
  max_people: number;
  includes_breakfast: boolean;
  status: "ACTIVE" | "INACTIVE";
}


export interface RoomTypeResponseI {
  id?: number;
  name: string;
  description: string;
  max_people: number;
  includes_breakfast: boolean;

}
