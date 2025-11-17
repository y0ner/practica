export interface HotelI {
  id?: number;
  name: string;
  address: string;
  city: string;
  country: string;
  phone: string;
  stars: number;
  status: "ACTIVE" | "INACTIVE";
}


export interface HotelResponseI {
  id?: number;
  name: string;
  address: string;
  city: string;
  country: string;
  phone: string;
  stars: number;

}
