const faker = require('faker');
const constants = require('./constants');
const dataHelper = require('./dataHelper');

const randomize = faker.helpers.randomize;
const {VAN, CAR, BIKE} = constants.driverVehicles;
const {
  UNPROCESSED,
  PROCESSED,
  ON_COURSE,
  DELIVERED,
} = constants.packageStatuses;

function generateVehicle() {
  return randomize([VAN, CAR, BIKE]);
}

function capacityByVehicle(vehicle) {
  switch (vehicle) {
    case VAN:
      return 300;
    case CAR:
      return 100;
    case BIKE:
      return 40;
  }
}

generateDriver = () => {
  const vehicle = generateVehicle();

  return {
    id: faker.random.uuid(),
    name: faker.name.findName(),
    vehicle: vehicle,
    vehicleMaxVolume: capacityByVehicle(vehicle),
  };
};

const getAvailableDriver = (drivers, packageVolume, packages) => {
  const driver = randomize([true, false]) ? randomize(drivers) : null;

  if (driver) {
    const driverPackages = packages.filter(
      p => p.driver && p.driver.id == driver.id,
    );

    const packagesTotalVolume = driverPackages.reduce(
      (acc, p) => p.volume + acc,
      0,
    );

    if (driver.vehicleMaxVolume - packagesTotalVolume - packageVolume < 0) {
      const filteredDrivers = drivers.filter(d => d.id !== driver.id);
      return getAvailableDriver(filteredDrivers, packageVolume, packages);
    }

    return driver;
  }

  return null;
};

generatePackage = (drivers, packages) => {
  const volume = faker.random.number({min: 1, max: 60});
  const driver = getAvailableDriver(drivers, volume, packages);

  const availableStatuses = driver
    ? [ON_COURSE, DELIVERED]
    : [UNPROCESSED, PROCESSED];

  return {
    id: faker.random.uuid(),
    driver: driver,
    customerName: faker.name.findName(),
    volume: volume,
    address: faker.address.streetAddress(),
    coordinates: {
      latitude: faker.address.latitude(),
      longitude: faker.address.longitude(),
    },
    status: randomize(availableStatuses),
  };
};

module.exports = {
  generateDriver,
  generatePackage,
};
