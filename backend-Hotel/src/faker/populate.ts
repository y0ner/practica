import { faker } from '@faker-js/faker';
import { sequelize } from '../database/db';
import { Client } from '../models/Client';
import { Service } from '../models/Service';
import { Reservation } from '../models/Reservation';
import { Room } from '../models/Room';
import { Season } from '../models/Season';
import { RoomType } from '../models/RoomType';
import { Hotel } from '../models/Hotel';
import { Rate } from '../models/Rate';
import { Payment } from '../models/Payment';
import { ReservationService } from '../models/ReservationService';
import { Checkout } from '../models/Checkout';
import { Checkin } from '../models/Checkin';
import { setupAssociations } from '../models/associations';


// Contenedor para los IDs de los modelos poblados
const populatedIds: { [key: string]: any[] } = {};

async function main() {
    console.log('Syncing database...');
    // Configura las asociaciones antes de sincronizar la base de datos
    setupAssociations();

    await sequelize.sync({ force: true }); // ¡CUIDADO! Esto borrará todos los datos existentes.

    console.log('Starting data population...');
    // Orden corregido para respetar las dependencias de claves foráneas
    await populateHotels(10);
    await populateRoomTypes(5);
    await populateRooms(50);
    await populateClients(50);
    await populateSeasons(4);
    await populateRates(20);
    await populateServices(50);
    await populateReservations(50);
    await populatePayments(50);
    await populateReservationServices(50);
    await populateCheckins(50);
    await populateCheckouts(50);

    console.log('Data population finished successfully.');
}

async function populateClients(count: number) {
    console.log('Populating Clients...');
    const createdItems = [];
    for (let i = 0; i < count; i++) {
        const newItem = await Client.create({
            first_name: faker.person.firstName(),
            last_name: faker.person.lastName(),
            document: faker.string.alphanumeric(10),
            phone: faker.phone.number(),
            email: faker.internet.email(),
            nationality: faker.location.country(),
            status: 'ACTIVE',
        });
        createdItems.push(newItem as any);
    }
    populatedIds['Client'] = createdItems;
}

async function populateServices(count: number) {
    console.log('Populating Services...');
    const createdItems = [];
    for (let i = 0; i < count; i++) {
        const newItem = await Service.create({
            name: faker.commerce.productName(),
            description: faker.lorem.sentence(),
            price: faker.number.float({ min: 10, max: 200, fractionDigits: 2 }),
            category: faker.commerce.department(),
            status: 'ACTIVE',
        });
        createdItems.push(newItem as any);
    }
    populatedIds['Service'] = createdItems;
}

async function populateReservations(count: number) {
    console.log('Populating Reservations...');
    const createdItems = [];
    for (let i = 0; i < count; i++) {
        const checkin_date = faker.date.soon({ days: 30 });
        const checkout_date = faker.date.soon({ days: 10, refDate: checkin_date });
        const newItem = await Reservation.create({
            reservation_date: faker.date.past(),
            checkin_date: checkin_date,
            checkout_date: checkout_date,
            number_of_guests: faker.number.int({ min: 1, max: 4 }),
            total_amount: faker.number.float({ min: 100, max: 2000, fractionDigits: 2 }),
            client_id: faker.helpers.arrayElement(populatedIds['Client']).id,
            room_id: faker.helpers.arrayElement(populatedIds['Room']).id, // Room debe estar poblado antes
            status: 'ACTIVE',
        });
        createdItems.push(newItem as any);
    }
    populatedIds['Reservation'] = createdItems;
}

async function populateRooms(count: number) {
    console.log('Populating Rooms...');
    const createdItems = [];
    for (let i = 0; i < count; i++) {
        const newItem = await Room.create({
            number: faker.number.int({ min: 101, max: 999 }),
            floor: faker.number.int({ min: 1, max: 9 }),
            capacity: faker.number.int({ min: 1, max: 6 }),
            description: faker.lorem.sentence(),
            base_price: faker.number.float({ min: 50, max: 500, fractionDigits: 2 }),
            available: faker.datatype.boolean(),
            roomtype_id: faker.helpers.arrayElement(populatedIds['RoomType']).id, // RoomType debe estar poblado antes
            hotel_id: faker.helpers.arrayElement(populatedIds['Hotel']).id, // Hotel debe estar poblado antes
            status: 'ACTIVE',
        });
        createdItems.push(newItem as any);
    }
    populatedIds['Room'] = createdItems;
}

async function populateSeasons(count: number) {
    console.log('Populating Seasons...');
    const createdItems = [];
    for (let i = 0; i < count; i++) {
        const newItem = await Season.create({
            name: faker.lorem.words(2),
            start_date: faker.date.past(),
            end_date: faker.date.future(),
            price_multiplier: faker.number.float({ min: 1, max: 2.5, fractionDigits: 1 }),
            status: 'ACTIVE',
        });
        createdItems.push(newItem as any);
    }
    populatedIds['Season'] = createdItems;
}

async function populateRoomTypes(count: number) {
    console.log('Populating RoomTypes...');
    const createdItems = [];
    for (let i = 0; i < count; i++) {
        const newItem = await RoomType.create({
            name: faker.lorem.words(2),
            description: faker.lorem.sentence(),
            max_people: faker.number.int({ min: 1, max: 6 }),
            includes_breakfast: faker.datatype.boolean(),
            status: 'ACTIVE',
        });
        createdItems.push(newItem as any);
    }
    populatedIds['RoomType'] = createdItems;
}

async function populateHotels(count: number) {
    console.log('Populating Hotels...');
    const createdItems = [];
    for (let i = 0; i < count; i++) {
        const newItem = await Hotel.create({
            name: faker.company.name(),
            address: faker.location.streetAddress(),
            city: faker.location.city(),
            country: faker.location.country(),
            phone: faker.phone.number(),
            stars: faker.number.int({ min: 1, max: 5 }),
            status: 'ACTIVE',
        });
        createdItems.push(newItem as any);
    }
    populatedIds['Hotel'] = createdItems;
}

async function populateRates(count: number) {
    console.log('Populating Rates...');
    const createdItems = [];
    for (let i = 0; i < count; i++) {
        const newItem = await Rate.create({
            amount: faker.number.float({ min: 80, max: 800, fractionDigits: 2 }),
            currency: faker.finance.currencyCode(),
            description: faker.lorem.sentence(),
            refundable: faker.datatype.boolean(),
            season_id: faker.helpers.arrayElement(populatedIds['Season']).id, // Season debe estar poblado antes
            roomtype_id: faker.helpers.arrayElement(populatedIds['RoomType']).id, // RoomType debe estar poblado antes
            status: 'ACTIVE',
        });
        createdItems.push(newItem as any);
    }
    populatedIds['Rate'] = createdItems;
}

async function populatePayments(count: number) {
    console.log('Populating Payments...');
    const createdItems = [];
    for (let i = 0; i < count; i++) {
        const newItem = await Payment.create({
            amount: faker.number.float({ min: 100, max: 2000, fractionDigits: 2 }),
            method: faker.helpers.arrayElement(['Credit Card', 'PayPal', 'Cash']),
            currency: faker.finance.currencyCode(),
            payment_date: faker.date.past(),
            reference: faker.string.alphanumeric(16),
            reservation_id: faker.helpers.arrayElement(populatedIds['Reservation']).id, // Reservation debe estar poblado antes
            status: 'ACTIVE',
        });
        createdItems.push(newItem as any);
    }
    populatedIds['Payment'] = createdItems;
}

async function populateReservationServices(count: number) {
    console.log('Populating ReservationServices...');
    const createdItems = [];
    const reservations = populatedIds['Reservation'];
    const services = populatedIds['Service'];

    for (const reservation of reservations) {
        // Asigna un número aleatorio de servicios (entre 1 y 3) a cada reserva
        const servicesToAssign = faker.helpers.arrayElements(services, { min: 1, max: 3 });
        for (const service of servicesToAssign) {
            const newItem = await ReservationService.create({
                quantity: faker.number.int({ min: 1, max: 5 }),
                reservation_id: reservation.id,
                service_id: service.id,
                status: 'ACTIVE',
            });
            createdItems.push(newItem as any);
        }
    }
    populatedIds['ReservationService'] = createdItems;
}

async function populateCheckouts(count: number) {
    console.log('Populating Checkouts...');
    const createdItems = [];
    for (let i = 0; i < count; i++) {
        const newItem = await Checkout.create({
            time: faker.date.recent(),
            observation: faker.lorem.sentence(),
            reservation_id: faker.helpers.arrayElement(populatedIds['Reservation']).id, // Reservation debe estar poblado antes
        });
        createdItems.push(newItem as any);
    }
    populatedIds['Checkout'] = createdItems;
}

async function populateCheckins(count: number) {
    console.log('Populating Checkins...');
    const createdItems = [];
    for (let i = 0; i < count; i++) {
        const newItem = await Checkin.create({
            time: faker.date.recent(),
            observation: faker.lorem.sentence(),
            reservation_id: faker.helpers.arrayElement(populatedIds['Reservation']).id, // Reservation debe estar poblado antes
        });
        createdItems.push(newItem as any);
    }
    populatedIds['Checkin'] = createdItems;
}


main().catch(e => {
    console.error('Error populating database:', e);
    process.exit(1);
});

/*
  Para ejecutar este script y poblar la base de datos (esto borrará los datos existentes),
  asegúrate de que el script "populate" esté en tu package.json y luego ejecuta:
  npm run populate
*/
