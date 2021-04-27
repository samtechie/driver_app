const {packageStatuses} = require('./constants');
const dataHelper = require('./dataHelper');

const sendError = (res, error) => res.status(400).json({error: error});

const getDrivers = (req, res) => {
  const db = req.app.get('db');

  res.json(dataHelper.getDrivers(db));
};

const getPackages = (req, res) => {
  const db = req.app.get('db');

  res.json(dataHelper.getPackages(db));
};

const assignDriver = (req, res) => {
  const db = req.app.get('db');

  const package = dataHelper.findPackageById(req.params.packageId, db);
  const driver = dataHelper.findDriverById(req.body.driverId, db);

  if (!package) {
    sendError(res, 'PACKAGE_NOT_FOUND');
    return;
  }

  if (!driver) {
    sendError(res, 'DRIVER_NOT_FOUND');
    return;
  }

  const driverPackages = dataHelper.getPackagesByDriverId(driver.id, db);

  if (dataHelper.driverRemainingCapacity(driver, db) - package.volume <= 0) {
    sendError(res, 'DRIVER_OVER_CAPACITY');
    return;
  }

  if (package.status === packageStatuses.DELIVERED) {
    sendError(res, 'PACKAGE_ALREADY_DELIVERED');
    return;
  }

  if (package.status === packageStatuses.UNPROCESSED) {
    sendError(res, 'PACKAGE_NOT_PROCESSED');
    return;
  }

  if (package.driver !== null) {
    sendError(res, 'PACKAGE_ALREADY_ASSIGNED');
    return;
  }

  const newDb = dataHelper.assignDriver(package, driver, db);

  req.app.set('db', newDb);

  res.json(dataHelper.findPackageById(package.id, newDb));
};

const unassignDriver = (req, res) => {
  const db = req.app.get('db');

  const package = dataHelper.findPackageById(req.params.packageId, db);

  if (!package) {
    sendError(res, 'PACKAGE_NOT_FOUND');
    return;
  }

  if (package.driver === null) {
    sendError(res, 'PACKAGE_DOESNT_HAVE_DRIVER');
    return;
  }

  if (package.status === packageStatuses.DELIVERED) {
    sendError(res, 'PACKAGE_ALREADY_DELIVERED');
    return;
  }

  const newDb = dataHelper.unassignDriver(package, db);

  req.app.set('db', newDb);

  res.json(dataHelper.findPackageById(package.id, newDb));
};

module.exports = {
  assignDriver,
  unassignDriver,
  getDrivers,
  getPackages,
};
