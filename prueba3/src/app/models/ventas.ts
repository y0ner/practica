export interface SaleI {
  id?: number;
  sale_date: Date;
  subtotal: number;
  tax: number;
  discounts: number;
  total: number;
  client_id: number;
  status: "ACTIVE" | "INACTIVE";
}


export interface SaleResponseI {
  id?: number;
  sale_date: Date;
  subtotal: number;
  tax: number;
  discounts: number;
  total: number;
  client_id: number;
  status: "ACTIVE" | "INACTIVE";
}
