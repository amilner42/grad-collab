module Page.Browse exposing (Model, Msg(..), init, update, view)

{-| A blank page.
-}

import Api.Api as Api
import Api.Core as Core
import Api.Endpoint as Endpoint
import Api.Errors.Unknown as UnknownError
import Bulma
import FetchData
import Field
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Route
import Session exposing (Session)
import TaskRequest exposing (TaskRequest)


type alias Model =
    { session : Session
    , researchField : Maybe Field.Field
    , fieldRequestingHelpFrom : Maybe Field.Field
    , taskRequests : FetchData.FetchData (Core.HttpError UnknownError.Error) (List TaskRequest)
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session
      , taskRequests = FetchData.Loading
      , researchField = Nothing
      , fieldRequestingHelpFrom = Nothing
      }
    , Api.getTaskRequests Endpoint.taskRequestEmptyQueryParams CompletedGetTaskRequests
    )


view : Model -> { title : String, content : Html.Html Msg }
view model =
    { title = "Browse"
    , content =
        case model.taskRequests of
            FetchData.Loading ->
                div [] []

            FetchData.Failure _ ->
                div
                    [ class "section has-text-centered is-large" ]
                    [ div
                        [ class "title" ]
                        [ text "Ooops, we're having troubles..." ]
                    , div
                        [ class "subtitle" ]
                        [ text "We will be back online shortly." ]
                    ]

            FetchData.Success taskRequests ->
                renderHasTaskRequestsPage model.researchField model.fieldRequestingHelpFrom taskRequests
    }


renderHasTaskRequestsPage : Maybe Field.Field -> Maybe Field.Field -> List TaskRequest -> Html.Html Msg
renderHasTaskRequestsPage researchFieldSearchFilter fieldRequestingHelpFromSearchFilter taskRequests =
    div
        [ class "section" ]
        [ h1
            [ class "title is-4 has-text-centered" ]
            [ text "Open Task Requests" ]
        , div
            [ style "padding" "0 10px" ]
            [ div
                [ class "field is-horizontal" ]
                [ p
                    [ class "label", style "padding-right" "10px", style "line-height" "36px" ]
                    [ text "Search Filters" ]
                , div
                    [ class "field-body" ]
                    [ div
                        [ class "field is-narrow has-addons" ]
                        [ div
                            [ class "control" ]
                            [ div
                                [ class "select is-fullwidth" ]
                                [ select
                                    [ onInput SelectedSearchResearchField ]
                                    [ option
                                        [ disabled True
                                        , hidden True
                                        , selected (researchFieldSearchFilter == Nothing)
                                        ]
                                        [ text "Field of Research" ]
                                    , option
                                        [ selected (researchFieldSearchFilter == Just Field.Biology) ]
                                        [ text "Biology" ]
                                    , option
                                        [ selected (researchFieldSearchFilter == Just Field.Chemistry) ]
                                        [ text "Chemistry" ]
                                    , option
                                        [ selected (researchFieldSearchFilter == Just Field.Physics) ]
                                        [ text "Physics" ]
                                    , option
                                        [ selected (researchFieldSearchFilter == Just Field.Math) ]
                                        [ text "Math" ]
                                    , option
                                        [ selected (researchFieldSearchFilter == Just Field.Stats) ]
                                        [ text "Stats" ]
                                    , option
                                        [ selected (researchFieldSearchFilter == Just Field.ComputerScience) ]
                                        [ text "Computer Science" ]
                                    ]
                                ]
                            ]
                        , div
                            [ class "control" ]
                            [ button
                                [ class "button"
                                , disabled <| researchFieldSearchFilter == Nothing
                                , onClick <| SelectedSearchResearchField ""
                                ]
                                [ text "clear" ]
                            ]
                        ]
                    , div
                        [ class "field is-narrow has-addons" ]
                        [ div
                            [ class "control" ]
                            [ div
                                [ class "select is-fullwidth" ]
                                [ select
                                    [ onInput SelectedSearchFieldRequestingHelpFrom ]
                                    [ option
                                        [ disabled True
                                        , hidden True
                                        , selected (fieldRequestingHelpFromSearchFilter == Nothing)
                                        ]
                                        [ text "Field Requesting Help From" ]
                                    , option
                                        [ selected (fieldRequestingHelpFromSearchFilter == Just Field.Biology) ]
                                        [ text "Biology" ]
                                    , option
                                        [ selected (fieldRequestingHelpFromSearchFilter == Just Field.Chemistry) ]
                                        [ text "Chemistry" ]
                                    , option
                                        [ selected (fieldRequestingHelpFromSearchFilter == Just Field.Physics) ]
                                        [ text "Physics" ]
                                    , option
                                        [ selected (fieldRequestingHelpFromSearchFilter == Just Field.Math) ]
                                        [ text "Math" ]
                                    , option
                                        [ selected (fieldRequestingHelpFromSearchFilter == Just Field.Stats) ]
                                        [ text "Stats" ]
                                    , option
                                        [ selected (fieldRequestingHelpFromSearchFilter == Just Field.ComputerScience) ]
                                        [ text "Computer Science" ]
                                    ]
                                ]
                            ]
                        , div [ class "control" ]
                            [ button
                                [ class "button"
                                , disabled <| fieldRequestingHelpFromSearchFilter == Nothing
                                , onClick <| SelectedSearchFieldRequestingHelpFrom ""
                                ]
                                [ text "clear" ]
                            ]
                        ]
                    ]
                ]
            ]
        , if List.isEmpty taskRequests then
            div
                [ class "section has-text-centered" ]
                [ div
                    [ class "content" ]
                    [ text "no results" ]
                ]

          else
            div
                [ class "columns is-multiline"
                , style "margin" "0px"
                ]
                (List.map renderTaskRequestLink taskRequests)
        ]


renderTaskRequestLink : TaskRequest -> Html.Html Msg
renderTaskRequestLink taskRequest =
    div
        [ class "column is-one-third-desktop is-half-tablet"
        , onClick <| GoTo <| Route.BrowseTaskRequest taskRequest.id
        , style "cursor" "pointer"
        ]
        [ div
            [ class "box has-text-centered"
            , style "height" "250px"
            , style "padding" "10px"
            , style "border-radius" "0px"
            ]
            [ div
                [ class "level is-mobile"
                , style "width" "100%"
                , style "height" "20px"
                , style "margin-bottom" "5px"
                ]
                [ div
                    [ class "level-item level-left has-text-weight-bold" ]
                    [ text <| Field.toString taskRequest.researchField ]
                ]
            , div
                [ class "level is-mobile"
                , style "width" "100%"
                , style "height" "20px"
                , style "margin-bottom" "5px"
                ]
                [ div
                    [ class "level-item level-left has-text-grey-light" ]
                    [ text taskRequest.researchSubject ]
                ]
            , div
                [ style "margin-top" "15px"
                , style "overflow-y" "auto"
                , style "height" "160px"
                ]
                [ text taskRequest.projectImpactSummary ]
            ]
        ]


type Msg
    = GoTo Route.Route
    | SelectedSearchResearchField String
    | SelectedSearchFieldRequestingHelpFrom String
    | CompletedGetTaskRequests (Result.Result (Core.HttpError UnknownError.Error) (List TaskRequest))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        navKey =
            Session.navKey model.session

        qpFromModel { researchField, fieldRequestingHelpFrom } =
            { forUserId = Nothing
            , researchField = researchField
            , fieldRequestingHelpFrom = fieldRequestingHelpFrom
            }
    in
    case msg of
        GoTo route ->
            ( model, Route.pushUrl navKey route )

        SelectedSearchResearchField fieldAsStr ->
            let
                newModel =
                    { model | researchField = Field.fromString fieldAsStr, taskRequests = FetchData.Loading }
            in
            ( newModel
            , Api.getTaskRequests (qpFromModel newModel) CompletedGetTaskRequests
            )

        SelectedSearchFieldRequestingHelpFrom fieldAsStr ->
            let
                newModel =
                    { model | fieldRequestingHelpFrom = Field.fromString fieldAsStr, taskRequests = FetchData.Loading }
            in
            ( newModel
            , Api.getTaskRequests (qpFromModel newModel) CompletedGetTaskRequests
            )

        CompletedGetTaskRequests (Err err) ->
            ( { model | taskRequests = FetchData.Failure err }, Cmd.none )

        CompletedGetTaskRequests (Ok taskRequests) ->
            ( { model | taskRequests = FetchData.Success taskRequests }, Cmd.none )
