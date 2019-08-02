module SomePage exposing (Model, Msg(..), init, update, view)

import AuthMsg
import Html as Html exposing (Html)
import Html.Events as Html
import Http
import HttpUtil
import Json.Decode as Decode
import Json.Decode.Extra as Decode
import Json.Decode.Pipeline as Decode



-- MODEL


type alias Model =
    { response : Maybe BasicAuthResponse
    , responseError : Maybe String
    }


initialModel : Model
initialModel =
    { response = Nothing
    , responseError = Nothing
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel
    , Cmd.none
    )



-- VIEW


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.div []
            [ Html.text "Click one of the buttons to test" ]
        , Html.div []
            [ Html.button [ Html.onClick (PlainMsg AuthRequest) ] [ Html.text "With authentication" ]
            , Html.button [ Html.onClick (PlainMsg NoAuthRequest) ] [ Html.text "Without authentication" ]
            , Html.button [ Html.onClick (PlainMsg WrongAuthRequest) ] [ Html.text "Wrong authentication" ]
            ]
        , Html.div []
            [ case model.response of
                Nothing ->
                    Html.text ""

                Just response ->
                    Html.text "Authenticated!"
            , case model.responseError of
                Nothing ->
                    Html.text ""

                Just error ->
                    Html.text error
            ]
        ]



-- UPDATE


type Msg
    = PlainMsg PlainMsg
    | AuthFailMsg AuthMsg.AuthFailure
    | AuthSuccessMsg AuthSuccessMsg


type PlainMsg
    = AuthRequest
    | NoAuthRequest
    | WrongAuthRequest


type AuthSuccessMsg
    = RequestPerformed (Result Http.Error BasicAuthResponse)


withAuth : 
    (Result Http.Error a -> AuthSuccessMsg)
    -> Result Http.Error a
    -> Msg
withAuth =
    AuthMsg.withAuth AuthFailMsg AuthSuccessMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlainMsg submsg ->
            case submsg of
                AuthRequest ->
                    ( reset model
                    , someHttpGet "/auth/success"
                    )

                NoAuthRequest ->
                    ( reset model
                    , someHttpGet "/auth/failed"
                    )

                WrongAuthRequest ->
                    ( reset model
                    , someHttpGet "/auth/restricted-area"
                    )

        -- Handled in Main.elm
        AuthFailMsg _ ->
            ( model, Cmd.none )

        -- Default processing
        AuthSuccessMsg (RequestPerformed (Ok response)) ->
            ( { model
                | response = Just response
                , responseError = Nothing
              }
            , Cmd.none
            )

        -- Any other HTTP error processing (or fallback in case Main does not handle the message)
        AuthSuccessMsg (RequestPerformed (Err error)) ->
            ( { model
                | response = Nothing
                , responseError = Just (HttpUtil.errorToString error)
              }
            , Cmd.none
            )



-- Helper


reset : Model -> Model
reset model =
    { model
        | response = Nothing
        , responseError = Nothing
    }



-- Sample REST Service


type alias BasicAuthResponse =
    { authenticated : Bool
    , message : String
    }


basicAuthResponseDecoder : Decode.Decoder BasicAuthResponse
basicAuthResponseDecoder =
    Decode.succeed BasicAuthResponse
        |> Decode.required "authenticated" Decode.bool
        |> Decode.required "message" Decode.string


someHttpGet : String -> Cmd Msg
someHttpGet url =
    Http.get
        { url = url
        , expect = Http.expectJson (withAuth RequestPerformed) basicAuthResponseDecoder
        }
