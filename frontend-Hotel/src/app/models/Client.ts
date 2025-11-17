export interface ClientI {
  id?: number;
  first_name: string;
  last_name: string;
  document: string;
  phone: string;
  email: string;
  nationality: string;
  status: "ACTIVE" | "INACTIVE";
}


export interface ClientResponseI {
  id?: number;
  first_name: string;
  last_name: string;
  document: string;
  phone: string;
  email: string;
  nationality: string;

}
