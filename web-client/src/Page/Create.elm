module Page.Create exposing (Model, Msg, init, update, view)

import Api.Api as Api
import Api.Core as Core
import Api.Errors.Form as FormError
import Bulma
import CollabRequest
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Route
import Session exposing (Session)
import User exposing (User)



-- MODEL


type alias Model =
    { session : Session
    , collabRequestFormError : FormError.Error
    , collabRequestFormData : CollabRequest.CollabRequestData
    }


init : Session -> ( Model, Cmd msg )
init session =
    ( { session = session
      , collabRequestFormError = FormError.empty
      , collabRequestFormData = CollabRequest.empty
      }
    , Cmd.none
    )



-- VIEW


view : Model -> { title : String, content : Html.Html Msg }
view model =
    let
        maybeUser =
            Session.user model.session

        crFormData =
            model.collabRequestFormData
    in
    { title = "Create"
    , content =
        case maybeUser of
            Nothing ->
                renderLoggedOutCreatePage

            Just _ ->
                section
                    [ class "section" ]
                    [ div
                        [ class "columns is-centered" ]
                        [ div
                            [ class "column is-half-desktop is-two-thirds-tablet" ]
                            [ div
                                [ class "box" ]
                                [ h1 [ class "title has-text-centered" ] [ text "Create a Task Request" ]
                                , Bulma.formControl
                                    (\hasError ->
                                        input
                                            [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                            , placeholder "Eg. Computer Science or Biology"
                                            , onInput EnteredField
                                            , value crFormData.field
                                            ]
                                            []
                                    )
                                    (FormError.getErrorForField "field" model.collabRequestFormError)
                                    (Just "Field")
                                , Bulma.formControl
                                    (\hasError ->
                                        input
                                            [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                            , placeholder "Eg. Machine Learning or Genomics"
                                            , onInput EnteredSubject
                                            , value crFormData.subject
                                            ]
                                            []
                                    )
                                    (FormError.getErrorForField "subject" model.collabRequestFormError)
                                    (Just "Subject")
                                , Bulma.formControl
                                    (\hasError ->
                                        textarea
                                            [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                            , style "min-height" "100px"
                                            , placeholder "What makes your project impactful and worth contributing to?"
                                            , onInput EnteredProjectImpactSummary
                                            , value crFormData.projectImpactSummary
                                            ]
                                            []
                                    )
                                    (FormError.getErrorForField "projectImpactSummary" model.collabRequestFormError)
                                    (Just "Project Impact Summary")
                                , Bulma.formControl
                                    (\hasError ->
                                        textarea
                                            [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                            , style "min-height" "100px"
                                            , placeholder "As clearly as you can, explain the expected tasks and required skills."
                                            , onInput EnteredExpectedTasksAndSkills
                                            , value crFormData.expectedTasksAndSkills
                                            ]
                                            []
                                    )
                                    (FormError.getErrorForField "expectedTasksAndSkills" model.collabRequestFormError)
                                    (Just "Expected Tasks and Skills")
                                , Bulma.formControl
                                    (\hasError ->
                                        textarea
                                            [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                            , style "min-height" "100px"
                                            , placeholder "What can you offer upon successful completion of the task? Eg. 3rd name on paper if it gets published."
                                            , onInput EnteredReward
                                            , value crFormData.reward
                                            ]
                                            []
                                    )
                                    (FormError.getErrorForField "reward" model.collabRequestFormError)
                                    (Just "Reward")
                                , Bulma.formControl
                                    (\hasError ->
                                        textarea
                                            [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                            , style "min-height" "100px"
                                            , placeholder "Anything important you couldn't mention above should be placed here."
                                            , onInput EnteredAdditionalInfo
                                            , value crFormData.additionalInfo
                                            ]
                                            []
                                    )
                                    (FormError.getErrorForField "additionalInfo" model.collabRequestFormError)
                                    (Just "Additional Info")
                                , p
                                    [ class "title is-size-7 has-text-danger has-text-centered" ]
                                    (List.map text model.collabRequestFormError.entire)
                                , button
                                    [ class "button button is-success is-fullwidth"
                                    , onClick SubmittedForm
                                    ]
                                    [ text "Submit Task Request" ]
                                ]
                            ]
                        ]
                    ]
    }


renderLoggedOutCreatePage : Html Msg
renderLoggedOutCreatePage =
    div
        [ class "section is-large has-text-centered" ]
        [ div
            [ class "title" ]
            [ text "Tell us About Yourself" ]
        , div
            [ class "subtitle" ]
            [ text "sign up free to instantly start creating task requests" ]
        ]



-- UPDATE


type Msg
    = EnteredField String
    | EnteredSubject String
    | EnteredProjectImpactSummary String
    | EnteredExpectedTasksAndSkills String
    | EnteredReward String
    | EnteredAdditionalInfo String
    | SubmittedForm
    | CompletedCreateCollabRequest (Result (Core.HttpError FormError.Error) String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        navKey =
            Session.navKey model.session

        updateFormData updater modelIn =
            { modelIn | collabRequestFormData = updater model.collabRequestFormData }
    in
    case msg of
        EnteredField fieldInput ->
            ( model |> updateFormData (\fd -> { fd | field = fieldInput }), Cmd.none )

        EnteredSubject subjectInput ->
            ( model |> updateFormData (\fd -> { fd | subject = subjectInput }), Cmd.none )

        EnteredProjectImpactSummary projectImpactSummaryInput ->
            ( model |> updateFormData (\fd -> { fd | projectImpactSummary = projectImpactSummaryInput }), Cmd.none )

        EnteredReward rewardInput ->
            ( model |> updateFormData (\fd -> { fd | reward = rewardInput }), Cmd.none )

        EnteredExpectedTasksAndSkills expectedTasksAndSkillsInput ->
            ( model |> updateFormData (\fd -> { fd | expectedTasksAndSkills = expectedTasksAndSkillsInput }), Cmd.none )

        EnteredAdditionalInfo additionalInfoInput ->
            ( model |> updateFormData (\fd -> { fd | additionalInfo = additionalInfoInput }), Cmd.none )

        SubmittedForm ->
            ( model, Api.createCollabRequest model.collabRequestFormData CompletedCreateCollabRequest )

        CompletedCreateCollabRequest (Ok collabRequestId) ->
            ( model, Route.replaceUrl navKey <| Route.BrowseCollabRequest collabRequestId )

        CompletedCreateCollabRequest (Err httpCreateRequestError) ->
            ( { model | collabRequestFormError = FormError.fromHttpError httpCreateRequestError }, Cmd.none )
