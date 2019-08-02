module Main exposing (main)

import AuthMsg exposing (AuthFailure(..))
import SomePage
import Browser
import Home
import Html as Html exposing (Html)
import Html.Events as Html
import Http
import Json.Decode as Decode
import Json.Decode.Extra as Decode
import Json.Decode.Pipeline as Decode
import Unauthenticated
import Unauthorized


-- MODEL


type alias Model =
    { page : Page
    }


type Page
    = Home Home.Model
    | SomePage SomePage.Model
    | Unauthenticated Unauthenticated.Model
    | Unauthorized Unauthorized.Model


init : () -> ( Model, Cmd Msg )
init _ =
    let (somePageModel, _) = SomePage.init
    in
    ( { page = SomePage somePageModel }
    , Cmd.none
    )



-- VIEW


view : Model -> Html Msg
view model =
    Html.div []
        [ nav
        , case model.page of
            Home homeModel ->
                Html.map HomeMsg <| Home.view homeModel

            SomePage somePageModel ->
                Html.map SomePageMsg <| SomePage.view somePageModel

            Unauthenticated unauthenticatedModel ->
                Html.map UnauthenticatedMsg <| Unauthenticated.view unauthenticatedModel

            Unauthorized unauthorizedModel ->
                Html.map UnauthorizedMsg <| Unauthorized.view unauthorizedModel
        ]


nav : Html Msg
nav =
    Html.div []
        [ Html.button [ Html.onClick GoToHome ] [ Html.text "Home" ]
        , Html.button [ Html.onClick GoToSomePage ] [ Html.text "SomePage" ]
        ]



-- UPDATE


type Msg
    = Noop
    | HomeMsg Home.Msg
    | SomePageMsg SomePage.Msg
    | UnauthenticatedMsg Unauthenticated.Msg
    | UnauthorizedMsg Unauthorized.Msg
    | GoToHome
    | GoToSomePage


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model
            , Cmd.none
            )

        SomePageMsg (SomePage.AuthFailMsg failType) ->
            case failType of 
                AuthMsg.Unauthenticated -> handleUnauthenticated model
                AuthMsg.Unauthorized -> handleUnauthorized model 

        SomePageMsg somePageMsg ->
            case model.page of
                SomePage somePageModel ->
                    let
                        ( newSomePageModel, newSomePageCmd ) =
                            SomePage.update somePageMsg somePageModel
                    in
                    ( { model | page = SomePage newSomePageModel }
                    , Cmd.map SomePageMsg newSomePageCmd
                    )

                _ ->
                    ( model, Cmd.none )

        HomeMsg homeMsg ->
            case model.page of
                Home homeModel ->
                    let
                        ( newHomeModel, newHomeCmd ) =
                            Home.update homeMsg homeModel
                    in
                    ( { model | page = Home newHomeModel }
                    , Cmd.map HomeMsg newHomeCmd
                    )

                _ ->
                    ( model, Cmd.none )

        UnauthenticatedMsg unauthenticatedMsg ->
            case model.page of
                Unauthenticated unauthenticatedModel ->
                    let
                        ( newUnauthenticatedModel, newUnauthenticatedCmd ) =
                            Unauthenticated.update unauthenticatedMsg unauthenticatedModel
                    in
                    ( { model | page = Unauthenticated newUnauthenticatedModel }
                    , Cmd.map UnauthenticatedMsg newUnauthenticatedCmd
                    )

                _ ->
                    ( model, Cmd.none )

        UnauthorizedMsg unauthorizedMsg ->
            case model.page of
                Unauthorized unauthorizedModel ->
                    let
                        ( newUnauthorizedModel, newUnauthorizedCmd ) =
                            Unauthorized.update unauthorizedMsg unauthorizedModel
                    in
                    ( { model | page = Unauthorized newUnauthorizedModel }
                    , Cmd.map UnauthorizedMsg newUnauthorizedCmd
                    )

                _ ->
                    ( model, Cmd.none )

        GoToHome ->
            ( { model | page = Home Home.init }
            , Cmd.none
            )

        GoToSomePage ->
            let
                ( somePageModel, _ ) =
                    SomePage.init
            in
            ( { model | page = SomePage somePageModel }
            , Cmd.none
            )

handleUnauthenticated : Model -> (Model, Cmd Msg)
handleUnauthenticated model = 
    ( { model | page = Unauthenticated Unauthenticated.init }
    , Cmd.none
    )

handleUnauthorized : Model -> (Model, Cmd Msg)
handleUnauthorized model = 
    ( { model | page = Unauthorized Unauthorized.init }
    , Cmd.none
    )

-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
