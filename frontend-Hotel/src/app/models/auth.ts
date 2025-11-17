export interface LoginI {
  email: string;
  password: string;
}

export interface LoginResponseI {
  token: string;
  user: UserI;
}

export interface RegisterI {
  username: string;  
  email: string;
  password: string;
}

export interface RegisterResponseI {
  token: string;
  user: UserI;
}

export interface UserI {
  id: number;
  username:string;
  email: string;
  password: string;
  is_active: "ACTIVE" | "INACTIVE";
  avatar: string;
}
