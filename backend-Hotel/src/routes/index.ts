import { Router } from "express";
import { SeasonRoutes } from "./Season.Routes";
import { RoomTypeRoutes } from "./RoomType.Routes";
import { ReservationServiceRoutes } from "./ReservationService.Routes";
import { HotelRoutes } from "./Hotel.Routes";
import { ServiceRoutes } from "./Service.Routes";
import { ReservationRoutes } from "./Reservation.Routes";
import { CheckoutRoutes } from "./Checkout.Routes";
import { RateRoutes } from "./Rate.Routes";
import { RoomRoutes } from "./Room.Routes";
import { PaymentRoutes } from "./Payment.Routes";
import { ClientRoutes } from "./Client.Routes";
import { CheckinRoutes } from "./Checkin.Routes";

import { UserRoutes } from "./authorization/user";
import { RoleRoutes } from "./authorization/role";
import { RoleUserRoutes } from "./authorization/role_user";
import { RefreshTokenRoutes } from "./authorization/refresh_token";
import { ResourceRoutes } from "./authorization/resource";
import { ResourceRoleRoutes } from "./authorization/resourceRole";
import { AuthRoutes } from "./authorization/auth";

export class Routes {
    public seasonRoutes: SeasonRoutes = new SeasonRoutes();
    public roomTypeRoutes: RoomTypeRoutes = new RoomTypeRoutes();
    public reservationServiceRoutes: ReservationServiceRoutes = new ReservationServiceRoutes();
    public hotelRoutes: HotelRoutes = new HotelRoutes();
    public serviceRoutes: ServiceRoutes = new ServiceRoutes();
    public reservationRoutes: ReservationRoutes = new ReservationRoutes();
    public checkoutRoutes: CheckoutRoutes = new CheckoutRoutes();
    public rateRoutes: RateRoutes = new RateRoutes();
    public roomRoutes: RoomRoutes = new RoomRoutes();
    public paymentRoutes: PaymentRoutes = new PaymentRoutes();
    public clientRoutes: ClientRoutes = new ClientRoutes();
    public checkinRoutes: CheckinRoutes = new CheckinRoutes();

    // --- Authorization Routes ---
    public userRoutes: UserRoutes = new UserRoutes();
    public roleRoutes: RoleRoutes = new RoleRoutes();
    public roleUserRoutes: RoleUserRoutes = new RoleUserRoutes();
    public refreshTokenRoutes: RefreshTokenRoutes = new RefreshTokenRoutes();
    public resourceRoutes: ResourceRoutes = new ResourceRoutes();
    public resourceRoleRoutes: ResourceRoleRoutes = new ResourceRoleRoutes();
    public authRoutes: AuthRoutes = new AuthRoutes();
}

