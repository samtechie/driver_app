# Paack frontend quiz

## Context

Paack is a delivery company and every day we have a large number of packages to deliver. Those packages are sorted in our warehouse and we give a set of packages for a driver and then they finally deliver to our client.

The warehouse manager is the user in charge to assign the packages to the drivers and then this way the warehouse workers will know which are packages they need to deliver to each driver.

### Goal

Build a web application that helps the warehouse managers to assign packages to the drivers.

### Requirements

As a warehouse manager:

- [ ] I want to see the list of packages that need to be delivered
- [ ] I want to filter the packages list by customer name
- [ ] I want to assign a driver to a package
- [ ] I want to unassign a driver from a package

### Business rules

- You cannot assign or unassign a driver to a package that has the status set to `unprocessed`, because the package is not yet in the warehouse.
- You cannot unassign a driver to a package that has the status set to `delivered`.
- when you assign a driver to a package that is processed, the backend will change the status value to `on_course`.
- If you assign a driver to a package and the driver cannot carry because it's vehicle capacity(vehicle_max_volume), the server will return to you an error. 
- You cannot assign a driver to a package that already has a driver assigned

### Entities

- Driver
    - Id
    - Name
    - Vehicle
        - Van
        - Car
        - Bike
    - Vehicle max volume
    - Available volume
    
- Package
    - Id
    - Driver Id
    - Customer name
    - Volume
    - Address
    - Coordinates
        - latitude
        - longitude
    - Status
        - Possible values
            - unprocessed
                - It means that the package didn't arrive at the warehouse yet
            - processed
                - The warehouse already have the package
            - on_course
                - The package is already with the driver
            - delivered
                - The package was delivered to the client

### How to run the backend

Install all dependencies

`yarn`

Run the project

`yarn run-backend`

Access the API

`http://localhost:9090/`

### Api

### GET /drivers

response: 

```json
[
    {
        "id" : "3999a94e-c9b0-40d3-bcf2-cc3cb7c2d495",
        "name" : "Stephen Curry",
        "vehicle" : "bike",
        "vehicleMaxVolume" : 40,
        "availableVolume" : 20
    },
    {
        "id" : "757e0331-e655-4186-a770-7c9db6dc690d",
        "name" : "Kyrie Irving",
        "vehicle" : "van",
        "vehicleMaxVolume" : 300, 
        "availableVolume" : 300
    }
]
```


### GET /packages

response: 

```json
[
    {
        "id" : "3999a94e-c9b0-40d3-bcf2-cc3cb7c2d495",
        "driver" : null,
        "customerName" : "Pedro Antunez",
        "volume" : 4,
        "address" : "Diagonal 49, 2A",
        "coordinates" : {
            "latitude" : 41.3911056,
            "longitude" : 2.1548483
        },
        "status" : "processed"
    },
    {
        "id" : "9e657a04-4d5e-45b6-b3bc-d6f6bbd976b9",
        "driver" :   {
            "id" : "757e0331-e655-4186-a770-7c9db6dc690d",
            "name" : "Kyrie Irving",
            "vehicle" : "van",
            "vehicleMaxVolume" : 300 
        },
        "customerName" : "Fernanda Camara",
        "volume" : 50,
        "address" : "Via augusta 53",
        "coordinates" : {
            "latitude" : 41.3876053,
            "longitude" : 2.1492562
        },
        "status" : "on_course"
    },
    {
        "id" : "0907f060-88f5-4f97-a536-eb5071ebaae6",
        "driver" :  {
            "id" : "3999a94e-c9b0-40d3-bcf2-cc3cb7c2d495",
            "name" : "Stephen Curry",
            "vehicle" : "bike",
            "vehicleMaxVolume" : 40,
            "availableVolume" : 30
        },
        "customerName" : "Carla Martinez",
        "volume" : 10,
        "address" : "Gran de Grácia 17",
        "coordinates" : {
            "latitude" : 41.3876053,
            "longitude" : 2.1492562
        },
        "status" : "delivered"
    }
]
```

### POST /packages/:packageId/assign_driver

request:
```json
{ "driverId" : "3999a94e-c9b0-40d3-bcf2-cc3cb7c2d495" }
```

response: 

#### Success

status: 200

body: 
```json
{
    "id" : "0907f060-88f5-4f97-a536-eb5071ebaae6",
    
    "driver" : {
        "id" : "3999a94e-c9b0-40d3-bcf2-cc3cb7c2d495",
        "name" : "Stephen Curry",
        "vehicle" : "bike",
        "vehicleMaxVolume" : 40,
        "availableVolume" : 30
    },
    "customerName" : "Carla Martinez",
    "volume" : 10,
    "address" : "Gran de gracia 17",
    "coordinates" : {
        "latitude" : 41.3876053,
        "longitude" : 2.1492562
    },
    "status" : "delivered"
}
```

#### Possible Errors

status: 400

body: 
```json 
{ "error" : "<error_type>" }
```
error_type:

- PACKAGE_NOT_FOUND
- DRIVER_NOT_FOUND
- DRIVER_OVER_CAPACITY 
    - The package capacity is more than the driver can carry
- PACKAGE_ALREADY_DELIVERED
- PACKAGE_NOT_PROCESSED
- PACKAGE_ALREADY_ASSIGNED

### POST /packages/:packageId/unassign_driver

response: 

#### Success

status: 200

body: 
```json
{
    "id" : "0907f060-88f5-4f97-a536-eb5071ebaae6",
    "driver" : null,
    "customerName" : "Carla Martinez",
    "volume" : 10,
    "address" : "Gran de gracia 17",
    "coordinates" : {
        "latitude" : 41.3876053,
        "longitude" : 2.1492562
    },
    "status" : "delivered"
}
```

#### Possible Errors

status: 400

body: 
```json 
{ "error" : "<error_type>" }
```
error_type:
- PACKAGE_NOT_FOUND
- PACKAGE_DOESNT_HAVE_DRIVER
- PACKAGE_ALREADY_DELIVERED
