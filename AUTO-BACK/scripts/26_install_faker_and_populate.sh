#!/bin/bash

# ==========================================
# 2️⃣6️⃣ Instalar faker y crear script de población
# Autor: Yoner
# ==========================================

. "$(dirname "$0")/utils.sh"

echo -e "${CYAN}Instalando @faker-js/faker...${NC}"
npm install @faker-js/faker
echo -e "${GREEN}✅ @faker-js/faker instalado correctamente.${NC}"

echo -e "${CYAN}Creando script de población de datos en src/faker/populate_data.ts...${NC}"
mkdir -p src/faker

cat <<'EOF' > src/faker/populate_data.ts
import { Client } from '../models/Client';
import { ProductType } from '../models/ProductType';
import { Product } from '../models/Product';
import { Sale } from '../models/Sale';
import { ProductSale } from '../models/ProductSale';
import { faker } from '@faker-js/faker';

async function createFakeData() {
    // Crear clientes falsos
    for (let i = 0; i < 50; i++) {
        await Client.create({
            name: faker.person.fullName(),
            address: faker.location.streetAddress(),
            phone: faker.phone.number(), // Genera un número de teléfono aleatorio
            email: faker.internet.email(),
            password: faker.internet.password(),
            status: 'ACTIVE',
        });
    }

    // Crear tipos de productos falsos
    for (let i = 0; i < 10; i++) {
        await ProductType.create({
            name: faker.commerce.department(),
            description: faker.commerce.productDescription(),
            status: 'ACTIVE',
        });
    }

    // Crear productos falsos
    const typeProducts = await ProductType.findAll();
    for (let i = 0; i < 20; i++) {
        await Product.create({
            name: faker.commerce.productName(),
            brand: faker.company.name(),
            price: faker.number.bigInt(),
            min_stock: faker.number.int({ min: 1, max: 10 }),
            quantity: faker.number.int({ min: 1, max: 100 }),
            product_type_id: typeProducts.length > 0
                ? typeProducts[faker.number.int({ min: 0, max: typeProducts.length - 1 })]?.id
                : null,
            status: 'ACTIVE',
        });
    }

    // Crear ventas falsas
    const clients = await Client.findAll();
    for (let i = 0; i < 100; i++) {
        await Sale.create({
            sale_date: faker.date.past(),
            subtotal: faker.number.bigInt(),
            tax: faker.number.bigInt(),
            discounts: faker.number.bigInt(),
            total: faker.number.bigInt(),
            status: 'ACTIVE',
            client_id: clients.length > 0
                ? clients[faker.number.int({ min: 0, max: clients.length - 1 })]?.id ?? null
                : null
        });
    }

//     // Crear productos ventas falsos
    const sales = await Sale.findAll();
    const products = await Product.findAll();
    for (let i = 0; i < 200; i++) {
        await ProductSale.create({
            total: faker.number.bigInt(),
            sale_id: sales[faker.number.int({ min: 0, max: sales.length - 1 })]?.id ?? null,
            product_id: products[faker.number.int({ min: 0, max: products.length - 1 })]?.id ?? null
        });
    }
}

createFakeData().then(() => {
    console.log('Datos falsos creados exitosamente');
}).catch((error) => {
    console.error('Error al crear datos falsos:', error);
});

// Para ejecutar este script, ejecute el siguiente comando:
// npm install -g ts-node
// ts-node src/faker/populate_data.ts
// npm install @faker-js/faker
EOF

echo -e "${GREEN}✅ Script de población de datos creado correctamente.${NC}"
pause