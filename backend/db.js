const faker = require('faker');
const generator = require('./generator');

let drivers = [];
let packages = [];

for (var i = 0; i < faker.random.number({min: 5, max: 10}); i++) {
  drivers.push(generator.generateDriver());
}

for (var i = 0; i < faker.random.number({min: 12, max: 30}); i++) {
  packages.push(generator.generatePackage(drivers, packages));
}

module.exports = {
  packages,
  drivers,
};
