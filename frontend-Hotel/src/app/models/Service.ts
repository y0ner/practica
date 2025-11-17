export interface ServiceI {
  id?: number;
  name: string;
  description: string;
  price: number;
  category: string;
  status: "ACTIVE" | "INACTIVE";
}


export interface ServiceResponseI {
  id?: number;
  name: string;
  description: string;
  price: number;
  category: string;

}
