module Page.Home exposing (Model, Msg, init, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Api.Core exposing (Cred)
import Api.Errors.Form as FormError
import Bulma
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Session exposing (Session)
import Viewer



-- MODEL


type alias Model =
    { session : Session
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session }
    , Cmd.none
    )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Home"
    , content =
        case Session.viewer model.session of
            Nothing ->
                renderLandingPage

            Just viewer ->
                div
                    []
                    [ text "TODO" ]
    }


renderLandingPage : Html Msg
renderLandingPage =
    section
        [ class "section is-medium" ]
        [ div
            [ class "container" ]
            [ div
                [ class "columns is-centered" ]
                [ div
                    [ class "column is-half" ]
                    [ h1
                        [ class "title has-text-centered" ]
                        [ text "Welcome" ]
                    , h2
                        [ class "subtitle has-text-centered" ]
                        [ text "Log in with your school email to create collab requests." ]
                    ]
                ]
            ]
        ]



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
