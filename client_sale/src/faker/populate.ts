import { faker } from '@faker-js/faker';
import { sequelize } from '../database/db';
import { Client } from '../models/Client';
import { Sale } from '../models/Sale';


// Contenedor para los IDs de los modelos poblados
const populatedIds: { [key: string]: any[] } = {};

async function main() {
    console.log('Syncing database...');
    await sequelize.sync({ force: true }); // ¡CUIDADO! Esto borrará todos los datos existentes.

    console.log('Starting data population...');
    await populateClients(50);
    await populateSales(50);

    console.log('Data population finished successfully.');
}

async function populateClients(count: number) {
    console.log('Populating Clients...');
    const createdItems = [];
    for (let i = 0; i < count; i++) {
        const newItem = await Client.create({
            name: faker.person.fullName(),
            address: faker.location.streetAddress(),
            phone: faker.phone.number(),
            email: faker.internet.email(),
            password: faker.internet.password(),
            status: 'ACTIVE',
        });
        createdItems.push(newItem as any);
    }
    populatedIds['Client'] = createdItems;
}

async function populateSales(count: number) {
    console.log('Populating Sales...');
    const createdItems = [];
    for (let i = 0; i < count; i++) {
        const newItem = await Sale.create({
            sale_date: faker.date.past(),
            subtotal: faker.number.int({ min: 10000, max: 500000 }),
            tax: faker.number.int({ min: 1000, max: 50000 }),
            discounts: faker.number.int({ min: 1000, max: 50000 }),
            total: faker.number.int({ min: 10000, max: 500000 }),
            client_id: faker.helpers.arrayElement(populatedIds['Client']).id,
            status: 'ACTIVE',
        });
        createdItems.push(newItem as any);
    }
    populatedIds['Sale'] = createdItems;
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
