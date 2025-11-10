export interface ClientI {
  id?: number;
  name: string;
  address: string;
  phone: string;
  email: string;
  password: string;
  status: "ACTIVE" | "INACTIVE";
}


export interface ClientResponseI {
  id?: number;
  name: string;
  address: string;
  phone: string;
  email: string;
}