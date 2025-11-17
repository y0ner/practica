import { Client } from "./Client";
import { Hotel } from "./Hotel";
import { Reservation } from "./Reservation";
import { Room } from "./Room";
import { RoomType } from "./RoomType";
import { Season } from "./Season";
import { Rate } from "./Rate";
import { Checkin } from "./Checkin";
import { Service } from "./Service";
import { Payment } from "./Payment";
import { Checkout } from "./Checkout";
import { ReservationService } from "./ReservationService";

export const setupAssociations = () => {
  // Client - Reservation (One to Many)
  Client.hasMany(Reservation, {
    foreignKey: "client_id",
    sourceKey: "id",
  });
  Reservation.belongsTo(Client, {
    foreignKey: "client_id",
    targetKey: "id",
  });

  // Hotel - Room (One to Many)
  Hotel.hasMany(Room, {
    foreignKey: "hotel_id",
    sourceKey: "id",
  });
  Room.belongsTo(Hotel, {
    foreignKey: "hotel_id",
    targetKey: "id",
  });

  // Reservation - Checkin (One to Many)
  Reservation.hasMany(Checkin, {
    foreignKey: "reservation_id",
    sourceKey: "id",
  });
  Checkin.belongsTo(Reservation, {
    foreignKey: "reservation_id",
    targetKey: "id",
  });

  // Reservation - Service (Many to Many)
  Reservation.belongsToMany(Service, {
    through: ReservationService,
    foreignKey: "reservation_id",
  });
  Service.belongsToMany(Reservation, {
    through: ReservationService,
    foreignKey: "service_id",
  });

  // Reservation - Payment (One to Many)
  Reservation.hasMany(Payment, {
    foreignKey: "reservation_id",
    sourceKey: "id",
  });
  Payment.belongsTo(Reservation, {
    foreignKey: "reservation_id",
    targetKey: "id",
  });

  // Reservation - Checkout (One to Many)
  Reservation.hasMany(Checkout, {
    foreignKey: "reservation_id",
    sourceKey: "id",
  });
  Checkout.belongsTo(Reservation, {
    foreignKey: "reservation_id",
    targetKey: "id",
  });

  // Room - Reservation (One to Many)
  Room.hasMany(Reservation, {
    foreignKey: "room_id",
    sourceKey: "id",
  });
  Reservation.belongsTo(Room, {
    foreignKey: "room_id",
    targetKey: "id",
  });

  // RoomType - Room (One to Many)
  RoomType.hasMany(Room, {
    foreignKey: "roomtype_id",
    sourceKey: "id",
  });
  Room.belongsTo(RoomType, {
    foreignKey: "roomtype_id",
    targetKey: "id",
  });

  // RoomType - Rate (One to Many)
  RoomType.hasMany(Rate, {
    foreignKey: "roomtype_id",
    sourceKey: "id",
  });
  Rate.belongsTo(RoomType, {
    foreignKey: "roomtype_id",
    targetKey: "id",
  });

  // Season - Rate (One to Many)
  Season.hasMany(Rate, {
    foreignKey: "season_id",
    sourceKey: "id",
  });
  Rate.belongsTo(Season, {
    foreignKey: "season_id",
    targetKey: "id",
  });
};