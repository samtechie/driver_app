module JsonParser exposing (..)

import Json.Decode as Decode exposing (Decoder, int, null, oneOf, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode


type alias Package =
    { id : String
    , driver : Maybe Driver
    , customerName : String
    , volume : Int
    , address : String
    , coordinates : Coordinates
    , status : String
    }


type alias Driver =
    { id : String
    , name : String
    , vehicle : String
    , vehicleMaxVolume : Int
    }


type alias Coordinates =
    { latitude : Float
    , longitude : Float
    }


decodePackage : Decoder Package
decodePackage =
    Decode.succeed Package
        |> required "id" Decode.string
        |> required "driver" (Decode.nullable decodeDriver)
        |> required "customerName" Decode.string
        |> required "volume" Decode.int
        |> required "address" Decode.string
        |> required "coordinates" decodeCoordinates
        |> required "status" Decode.string


decodePackages : Decode.Decoder (List Package)
decodePackages =
    Decode.list
        (Decode.succeed Package
            |> required "id" Decode.string
            |> required "driver" (Decode.nullable decodeDriver)
            |> required "customerName" Decode.string
            |> required "volume" Decode.int
            |> required "address" Decode.string
            |> required "coordinates" decodeCoordinates
            |> required "status" Decode.string
        )
        -- |> Decode.map (List.filter (\package -> package.status == "unprocessed"))


decodeDriver : Decoder Driver
decodeDriver =
    Decode.succeed Driver
        |> required "id" string
        |> required "name" Decode.string
        |> required "vehicle" Decode.string
        |> required "vehicleMaxVolume" Decode.int


decodeDrivers : Decode.Decoder (List Driver)
decodeDrivers =
    Decode.list
        (Decode.succeed Driver
            |> required "id" string
            |> required "name" Decode.string
            |> required "vehicle" Decode.string
            |> required "vehicleMaxVolume" Decode.int
        )


stringifiedFloat : Decoder Float
stringifiedFloat =
    Decode.string
        |> Decode.andThen
            (\str ->
                case String.toFloat str of
                    Just float ->
                        Decode.succeed float

                    Nothing ->
                        Decode.fail "not a valid float"
            )


decodeCoordinates : Decoder Coordinates
decodeCoordinates =
    Decode.succeed Coordinates
        |> required "latitude" stringifiedFloat
        |> required "longitude" stringifiedFloat


encodeMaybe : (a -> Json.Encode.Value) -> Maybe a -> Json.Encode.Value
encodeMaybe encoder maybe =
    case maybe of
        Just val ->
            encoder val

        Nothing ->
            Json.Encode.null


encodePackage : Package -> Json.Encode.Value
encodePackage record =
    Json.Encode.object
        [ ( "id", Json.Encode.string <| record.id )
        , ( "driver", encodeMaybe encodeDriver <| record.driver )
        , ( "customerName", Json.Encode.string <| record.customerName )
        , ( "volume", Json.Encode.int <| record.volume )
        , ( "address", Json.Encode.string <| record.address )
        , ( "coordinates", encodeCoordinates <| record.coordinates )
        , ( "status", Json.Encode.string <| record.status )
        ]


encodeDriver : Driver -> Json.Encode.Value
encodeDriver record =
    Json.Encode.object
        [ ( "id", Json.Encode.string <| record.id )
        , ( "name", Json.Encode.string <| record.name )
        , ( "vehicle", Json.Encode.string <| record.vehicle )
        , ( "vehicleMaxVolume", Json.Encode.int <| record.vehicleMaxVolume )
        ]


encodeCoordinates : Coordinates -> Json.Encode.Value
encodeCoordinates record =
    Json.Encode.object
        [ ( "latitude", Json.Encode.float <| record.latitude )
        , ( "longitude", Json.Encode.float <| record.longitude )
        ]
