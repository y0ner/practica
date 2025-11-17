export interface PaymentI {
  id?: number;
  amount: number;
  method: string;
  currency: string;
  payment_date: Date;
  reference: string;
  reservation_id: number;
  status?: "ACTIVE" | "CANCELLED";  // coincide con el backend
}

export interface PaymentResponseI {
  id?: number;
  amount: number;
  method: string;
  currency: string;
  payment_date: Date;
  reference: string;
  reservation_id: number;

}
