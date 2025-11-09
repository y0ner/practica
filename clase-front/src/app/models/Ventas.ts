export interface SaleI {
  id?: number;
  sale_date: string;
  subtotal: number;
  tax: number;
  discounts: number;
  total: number;
  client_id: number;
  status: "ACTIVE" | "INACTIVE";
}


export interface SaleResponseI {
  id?: number;
  sale_date: string;
  subtotal: number;
  tax: number;
  discounts: number;
  total: number;
  client_id: number;
}
