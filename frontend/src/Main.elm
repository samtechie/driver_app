module Main exposing (..)

import Attr
import Browser
import Color exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input
import Html
import Http exposing (Error, emptyBody)
import Json.Encode
import JsonParser exposing (..)


type Page
    = PackagesPage
    | DriversPage
    | DisplayPackage


type Msg
    = NoOp
    | RequestPackages
    | FinishSavedPackages (Result Http.Error (List Package))
    | FinishSavedPackage (Result Http.Error Package)
    | ToggleMenu
    | RequestDrivers
    | RequestPackageDrivers
    | FinishSavedDrivers (Result Http.Error (List Driver))
    | ShowPackage Package
    | AssignDriver String String
    | ShowDriver Driver
    | UnAssignDriver String


type alias Flags =
    ()



---- MODEL ----


type alias Model =
    { currPage : Page
    , savedPackages : List Package
    , lastError : String
    , isMenuOpen : Bool
    , savedDrivers : List Driver
    , selectedPackage : Maybe Package
    , selectedDriver : Maybe Driver
    }


serverUrl =
    "http://localhost:9090/"


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { currPage = PackagesPage
      , savedPackages = []
      , lastError = ""
      , isMenuOpen = False
      , savedDrivers = []
      , selectedPackage = Nothing
      , selectedDriver = Nothing
      }
    , Cmd.none
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestPackages ->
            ( { model | currPage = PackagesPage }
            , getPackages
            )

        FinishSavedPackages (Ok savedPackages) ->
            ( { model | savedPackages = savedPackages }, Cmd.none )

        FinishSavedPackages (Err error) ->
            ( { model | lastError = httpErrorString error }, Cmd.none )

        FinishSavedPackage (Ok package) ->
            ( { model | selectedPackage = Just package }, Cmd.none )

        FinishSavedPackage (Err error) ->
            ( { model | lastError = httpErrorString error }, Cmd.none )

        FinishSavedDrivers (Ok savedDrivers) ->
            ( { model | savedDrivers = savedDrivers }, Cmd.none )

        FinishSavedDrivers (Err error) ->
            ( { model | lastError = httpErrorString error }, Cmd.none )

        ShowPackage package ->
            ( { model | currPage = DisplayPackage, selectedPackage = Just package }, Cmd.none )

        ShowDriver driver ->
            ( { model | currPage = DisplayPackage, selectedDriver = Just driver }, Cmd.none )

        ToggleMenu ->
            ( { model | isMenuOpen = not model.isMenuOpen }, Cmd.none )

        RequestDrivers ->
            ( { model | currPage = DriversPage }
            , getDrivers
            )

        AssignDriver driverId packageId ->
            ( { model | currPage = DisplayPackage }, assignDriver driverId packageId )

        UnAssignDriver packageId ->
            ( { model | currPage = DisplayPackage }, unAssignDriver packageId )

        RequestPackageDrivers ->
            ( { model | currPage = DisplayPackage }
            , getDrivers
            )

        NoOp ->
            ( model, Cmd.none )


assignDriver : String -> String -> Cmd Msg
assignDriver driverId packageId =
    let
        body =
            Http.jsonBody <|
                Json.Encode.object
                    [ ( "driverId", Json.Encode.string driverId ) ]
    in
    Http.post
        { url = serverUrl ++ "packages/" ++ packageId ++ "/assign_driver"
        , body = body
        , expect = Http.expectJson FinishSavedPackage decodePackage
        }


unAssignDriver : String -> Cmd Msg
unAssignDriver packageId =
    Http.post
        { url = serverUrl ++ "packages/" ++ packageId ++ "/unassign_driver"
        , body = emptyBody
        , expect = Http.expectJson FinishSavedPackage decodePackage
        }


getPackages : Cmd Msg
getPackages =
    Http.get
        { url = serverUrl ++ "packages"
        , expect = Http.expectJson FinishSavedPackages decodePackages
        }


getDrivers : Cmd Msg
getDrivers =
    Http.get
        { url = serverUrl ++ "drivers"
        , expect = Http.expectJson FinishSavedDrivers decodeDrivers
        }



---- FUNCTIONS


httpErrorString : Http.Error -> String
httpErrorString error =
    case error of
        Http.BadBody message ->
            "Unable to handle response: " ++ message

        Http.BadStatus statusCode ->
            "Server error: " ++ String.fromInt statusCode

        Http.BadUrl url ->
            "invalid URL: " ++ url

        Http.NetworkError ->
            "Network error"

        Http.Timeout ->
            "Request timeout"


view : Model -> Browser.Document Msg
view model =
    let
        content =
            case model.currPage of
                PackagesPage ->
                    packagesPage model

                DriversPage ->
                    driversPage model

                DisplayPackage ->
                    displayPackage model
    in
    { title = "Delivery Manager"
    , body =
        [ layout [ inFront <| menuPanel model ] <|
            column [ width fill, spacingXY 0 20 ]
                [ navBar
                , content
                ]
        ]
    }


blue : Color
blue =
    rgb255 52 101 164


navBar : Element Msg
navBar =
    row
        [ width fill
        , paddingXY 60 10
        , Border.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
        , Border.color blue
        ]
        [ el [ alignLeft ] <| text "Delivery Manager"
        , Input.button (Attr.greyButton ++ [ padding 5, alignRight, width (px 80) ])
            { onPress = Just ToggleMenu
            , label = el [ centerX ] <| text "Menu"
            }
        ]


packagesPage : Model -> Element Msg
packagesPage model =
    let
        tableAttrs =
            [ width (px 800)
            , paddingEach { top = 10, bottom = 50, left = 10, right = 10 }
            , spacingXY 10 10
            , centerX
            ]

        headerAttrs =
            [ Font.bold
            , Background.color Color.lightGrey
            , Border.color Color.darkCharcoal
            , Border.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
            , centerX
            ]
    in
    table tableAttrs
        { data = model.savedPackages
        , columns =
            [ { header = el headerAttrs <| text "Customer name"
              , width = fill
              , view =
                    \package ->
                        el
                            [ Font.underline
                            , mouseOver [ Font.color lightCharcoal ]
                            , onClick <| ShowPackage package
                            ]
                        <|
                            text package.customerName
              }
            , { header = el headerAttrs <| text "volume"
              , width = fill
              , view = .volume >> String.fromInt >> text
              }
            , { header = el headerAttrs <| text "address"
              , width = fill
              , view = .address >> text
              }
            , { header = el headerAttrs <| text "Status"
              , width = fill
              , view = .status >> text
              }
            ]
        }


driversPage : Model -> Element Msg
driversPage model =
    let
        tableAttrs =
            [ width (px 800)
            , paddingEach { top = 10, bottom = 50, left = 10, right = 10 }
            , spacingXY 10 10
            , centerX
            ]

        headerAttrs =
            [ Font.bold
            , Background.color Color.lightGrey
            , Border.color Color.darkCharcoal
            , Border.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
            , centerX
            ]
    in
    table tableAttrs
        { data = model.savedDrivers
        , columns =
            [ { header = el headerAttrs <| text "Driver name"
              , width = fill
              , view = .name >> text
              }
            , { header = el headerAttrs <| text "vehicle"
              , width = fill
              , view = .vehicle >> text
              }
            , { header = el headerAttrs <| text "Max Volume"
              , width = fill
              , view = .vehicleMaxVolume >> String.fromInt >> text
              }
            ]
        }


menuPanel : Model -> Element Msg
menuPanel model =
    let
        items =
            [ el [ pointer, onClick RequestPackages ] <| text "Packages"
            , el [ pointer, onClick RequestDrivers ] <| text "Drivers"
            ]

        panel =
            column
                [ Background.color Color.white
                , Border.widthEach { left = 1, right = 0, top = 0, bottom = 0 }
                , Border.color Color.grey
                , Border.shadow
                    { offset = ( 0, 0 )
                    , size = 1
                    , blur = 10
                    , color = Color.lightCharcoal
                    }
                , Font.bold
                , Font.color Color.darkCharcoal
                , Font.family [ Font.sansSerif ]
                , width <| fillPortion 1
                , height fill
                , paddingXY 20 20
                , spacingXY 0 20
                ]
                items

        overlay =
            el [ width <| fillPortion 4, height fill, onClick ToggleMenu ] none
    in
    if model.isMenuOpen then
        row [ width fill, height fill ] [ overlay, panel ]

    else
        none


displayPackage : Model -> Element Msg
displayPackage model =
    let
        driverDetails =
            case model.selectedPackage of
                Nothing ->
                    "No Package"

                Just package ->
                    case package.driver of
                        Nothing ->
                            "No driver"

                        Just driver ->
                            driver.name

        packageId =
            case model.selectedPackage of
                Nothing ->
                    "No Package"

                Just package ->
                    package.id

        driverId =
            case model.selectedDriver of
                Nothing ->
                    "No Driver"

                Just driver ->
                    driver.id

        tableAttrs =
            [ width (px 800)
            , paddingEach { top = 10, bottom = 50, left = 10, right = 10 }
            , spacingXY 10 10
            , centerX
            ]

        headerAttrs =
            [ Font.bold
            , Background.color Color.lightGrey
            , Border.color Color.darkCharcoal
            , Border.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
            , centerX
            ]
    in
    column
        [ width (px 800)
        , spacingXY 0 10
        , centerX
        ]
        [ row
            [ width fill
            , paddingXY 60 10
            ]
            [ el [ alignLeft ] <| text driverDetails
            , Input.button
                (Attr.greenButton ++ [ centerX, width (px 95), height (px 40) ])
                { onPress = Just (UnAssignDriver packageId)
                , label = el [ centerX ] <| text "UnAssign"
                }
            , el [ alignRight ] <| text packageId
            ]
        , Input.button
            (Attr.greenButton ++ [ centerX, width (px 200), height (px 40) ])
            { onPress = Just RequestPackageDrivers
            , label = el [ centerX ] <| text "Load Drivers!"
            }
        , table tableAttrs
            { data = model.savedDrivers
            , columns =
                [ { header = el headerAttrs <| text "Driver name"
                  , width = fill
                  , view =
                        \driver ->
                            row []
                                [ el
                                    [ Font.underline
                                    , mouseOver [ Font.color lightCharcoal, Background.color lightYellow ]
                                    , onClick <| ShowDriver driver
                                    ]
                                  <|
                                    text driver.name
                                , Input.button
                                    (Attr.greenButton ++ [ alignRight, width (px 95), height (px 40) ])
                                    { onPress = Just (AssignDriver driverId packageId)
                                    , label = el [ centerX ] <| text "Assign"
                                    }
                                ]
                  }
                , { header = el headerAttrs <| text "vehicle"
                  , width = fill
                  , view = .vehicle >> text
                  }
                , { header = el headerAttrs <| text "Max Volume"
                  , width = fill
                  , view = .vehicleMaxVolume >> String.fromInt >> text
                  }
                ]
            }
        ]



---- PROGRAM ----


main =
    Browser.document
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
