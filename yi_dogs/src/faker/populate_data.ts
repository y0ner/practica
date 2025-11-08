import { sequelize } from '../database/db';
import { Breeds } from '../models/Breeds';
import { Dogs } from '../models/Dogs';
import { faker } from '@faker-js/faker';

async function createFakeData() {
    await sequelize.sync({ force: true });
    console.log('Base de datos sincronizada y tablas creadas.');

    // 1. Crear breeds falsos
    console.log('Creando breeds...');
    for (let i = 0; i < 10; i++) {
        await Breeds.create({
            name: faker.person.fullName(),
            status: 'ACTIVE',
        });
    }
    console.log('Autores creados exitosamente.');

    // 2. Crear perros falsas
    const breeds = await Breeds.findAll();
    
    if (breeds.length === 0) {
        console.error('No se encontraron breeds para asignar a las perros.');
        return;
    }

    console.log('Creando perros...');
    for (let i = 0; i < 50; i++) {
        await Dogs.create({
            birthday: faker.lorem.paragraph(),
            value_dog: faker.number.int({ min: 100, max: 1000 }),
            status: 'ACTIVE',
            breeds_id: breeds[faker.number.int({ min: 0, max: breeds.length - 1 })].id,
        });
    }
    console.log('Noticias creadas exitosamente.');
}

createFakeData().then(() => {
    console.log('Datos falsos para YI_NEWS creados exitosamente ✅');
}).catch((error) => {
    console.error('Error al crear datos falsos:', error);
}).finally(() => {
    sequelize.close();
});

// Para ejecutar este script, ejecute el siguiente comando:
// npm install -g ts-node
// ts-node src/faker/populate_data.ts
// npm install @faker-js/faker
