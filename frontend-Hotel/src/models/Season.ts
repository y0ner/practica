export interface SeasonI {
  id?: number;
  name: string;
  start_date: Date;
  end_date: Date;
  price_multiplier: number;
  status: "ACTIVE" | "INACTIVE";
}


export interface SeasonResponseI {
  id?: number;
  name: string;
  start_date: Date;
  end_date: Date;
  price_multiplier: number;

}
