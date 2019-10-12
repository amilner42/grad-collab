module Page.Home exposing (Model, Msg, init, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Api.Api as Api
import Api.Core as Core exposing (Cred)
import Api.Errors.Form as FormError
import Api.Errors.Unknown as UnknownError
import Browser.Navigation as Nav
import Bulma
import CollabRequest exposing (CollabRequest)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RemoteData exposing (RemoteData)
import Route
import Session exposing (Session)
import Viewer



-- MODEL


type alias Model =
    { session : Session
    , collabRequests : RemoteData.RemoteData (Core.HttpError UnknownError.Error) (List CollabRequest)
    }


init : Session -> ( Model, Cmd Msg )
init session =
    case Session.viewer session of
        Nothing ->
            ( { session = session, collabRequests = RemoteData.NotAsked }
            , Cmd.none
            )

        Just _ ->
            ( { session = session, collabRequests = RemoteData.Loading }
            , Api.getCollabRequests CompletedGetCollabRequests
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
                renderHomePage model.collabRequests
    }


renderHomePage : RemoteData (Core.HttpError UnknownError.Error) (List CollabRequest) -> Html Msg
renderHomePage rdCollabRequests =
    case rdCollabRequests of
        RemoteData.NotAsked ->
            div [] []

        RemoteData.Loading ->
            div [] []

        RemoteData.Failure _ ->
            div
                [ class "section has-text-centered is-large" ]
                [ div
                    [ class "title" ]
                    [ text "Ooops, we're having troubles..." ]
                , div
                    [ class "subtitle" ]
                    [ text "We will be back online shortly." ]
                ]

        RemoteData.Success collabRequests ->
            if List.isEmpty collabRequests then
                div
                    [ class "section has-text-centered is-large" ]
                    [ div
                        [ class "title" ]
                        [ text "You have no open collab requests." ]
                    , div
                        [ class "subtitle" ]
                        [ text "Create one easily to help find the perfect collaborator." ]
                    ]

            else
                renderHasCollabRequestsPage collabRequests


renderHasCollabRequestsPage : List CollabRequest -> Html.Html Msg
renderHasCollabRequestsPage collabRequests =
    div
        [ class "section" ]
        [ h1
            [ class "title is-4 has-text-centered" ]
            [ text "Your Collaboration Requests" ]
        , div
            [ class "columns is-multiline"
            , style "margin" "0px"
            ]
            (List.map renderCollabRequestLink collabRequests)
        ]


renderCollabRequestLink : CollabRequest -> Html.Html Msg
renderCollabRequestLink collabRequest =
    div
        [ class "column is-one-third-desktop is-half-tablet"
        , onClick <| GoTo <| Route.BrowseCollabRequest collabRequest.id
        , style "cursor" "pointer"
        ]
        [ div
            [ class "box has-text-centered"
            , style "height" "250px"
            , style "padding" "10px"
            ]
            [ div
                [ class "level is-mobile"
                , style "width" "100%"
                , style "height" "20px"
                , style "margin-bottom" "5px"
                ]
                [ div
                    [ class "level-item level-left has-text-weight-bold" ]
                    [ text collabRequest.field ]
                ]
            , div
                [ class "level is-mobile"
                , style "width" "100%"
                , style "height" "20px"
                , style "margin-bottom" "5px"
                ]
                [ div
                    [ class "level-item level-left has-text-grey-light" ]
                    [ text collabRequest.subject ]
                ]
            , div
                [ style "margin-top" "15px"
                , style "overflow-y" "auto"
                , style "height" "160px"
                ]
                [ text collabRequest.projectImpactSummary ]
            ]
        ]


renderLandingPage : Html Msg
renderLandingPage =
    section
        [ class "section is-large" ]
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
                        [ text "collaborating easily and effectively" ]
                    ]
                ]
            ]
        ]



-- UPDATE


type Msg
    = GoTo Route.Route
    | CompletedGetCollabRequests (Result.Result (Core.HttpError UnknownError.Error) (List CollabRequest.CollabRequest))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        navKey =
            Session.navKey model.session
    in
    case msg of
        GoTo route ->
            ( model, Route.pushUrl navKey route )

        CompletedGetCollabRequests (Ok collabRequests) ->
            ( { model | collabRequests = RemoteData.Success collabRequests }, Cmd.none )

        CompletedGetCollabRequests (Err httpGetCollabRequestsErr) ->
            ( { model | collabRequests = RemoteData.Failure httpGetCollabRequestsErr }, Cmd.none )
