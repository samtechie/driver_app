const driverRemainingCapacity = (driver, db) => {
  const driverPackages = db.packages.filter(
    p => p.driver && p.driver.id === driver.id,
  );

  const packagesTotalVolume = driverPackages.reduce(
    (acc, p) => p.volume + acc,
    0,
  );

  return driver.vehicleMaxVolume - packagesTotalVolume;
};

const getDriverWithRemainingVolume = (d, db) => ({
  ...d,
  availableVolume: driverRemainingCapacity(d, db),
});

const getDrivers = db =>
  db.drivers.map(d => getDriverWithRemainingVolume(d, db));

const getPackages = db =>
  db.packages.map(p => ({
    ...p,
    driver: p.driver ? getDriverWithRemainingVolume(p.driver, db) : null,
  }));

const findPackageById = (packageId, db) =>
  getPackages(db).find(p => p.id === packageId);

const findDriverById = (driverId, db) =>
  getDrivers(db).find(d => d.id === driverId);

const getPackagesByDriverId = (driverId, db) =>
  getPackages(db).filter(p => p.driver && p.driver.id === driverId);

const updatePackage = (newPackage, db) => ({
  ...db,
  packages: getPackages(db).map(oldPackage =>
    oldPackage.id === newPackage.id ? newPackage : oldPackage,
  ),
});

const assignDriver = (package, driver, db) =>
  updatePackage({...package, driver: driver}, db);

const unassignDriver = (package, db) =>
  updatePackage({...package, driver: null}, db);

module.exports = {
  getPackages,
  getDrivers,
  findDriverById,
  findPackageById,
  getPackagesByDriverId,
  assignDriver,
  unassignDriver,
  driverRemainingCapacity,
};
