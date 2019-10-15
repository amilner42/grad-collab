module Page.CreateTask exposing (Model, Msg, init, update, view)

import Api.Api as Api
import Api.Core as Core
import Api.Errors.Form as FormError
import Bulma
import Field
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Route
import Session exposing (Session)
import TaskRequest
import User exposing (User)



-- MODEL


type alias Model =
    { session : Session
    , taskRequestFormError : FormError.Error
    , taskRequstFormData : TaskRequest.TaskRequestData
    }


init : Session -> ( Model, Cmd msg )
init session =
    ( { session = session
      , taskRequestFormError = FormError.empty
      , taskRequstFormData = TaskRequest.empty
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
            model.taskRequstFormData
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
                                        div
                                            [ classList [ ( "select", True ), ( "is-danger", hasError ) ] ]
                                            [ select
                                                [ onInput SelectedResearchField ]
                                                [ option
                                                    [ disabled True
                                                    , hidden True
                                                    , selected (crFormData.researchField == Nothing)
                                                    ]
                                                    [ text "Select Your Field" ]
                                                , option
                                                    [ selected (crFormData.researchField == Just Field.Biology) ]
                                                    [ text "Biology" ]
                                                , option
                                                    [ selected (crFormData.researchField == Just Field.Chemistry) ]
                                                    [ text "Chemistry" ]
                                                , option
                                                    [ selected (crFormData.researchField == Just Field.Physics) ]
                                                    [ text "Physics" ]
                                                , option
                                                    [ selected (crFormData.researchField == Just Field.Math) ]
                                                    [ text "Math" ]
                                                , option
                                                    [ selected (crFormData.researchField == Just Field.Stats) ]
                                                    [ text "Stats" ]
                                                , option
                                                    [ selected (crFormData.researchField == Just Field.ComputerScience) ]
                                                    [ text "Computer Science" ]
                                                ]
                                            ]
                                    )
                                    (FormError.getErrorForField "researchField" model.taskRequestFormError)
                                    (Just "Research Field")
                                , Bulma.formControl
                                    (\hasError ->
                                        input
                                            [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                            , placeholder "Eg. Machine Learning or Genomics"
                                            , onInput EnteredResearchSubject
                                            , value crFormData.researchSubject
                                            ]
                                            []
                                    )
                                    (FormError.getErrorForField "researchSubject" model.taskRequestFormError)
                                    (Just "Research Subject")
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
                                    (FormError.getErrorForField "projectImpactSummary" model.taskRequestFormError)
                                    (Just "Project Impact Summary")
                                , Bulma.formControl
                                    (\hasError ->
                                        div
                                            [ classList [ ( "select", True ), ( "is-danger", hasError ) ] ]
                                            [ select
                                                [ onInput SelectedFieldRequestingHelpFrom ]
                                                [ option
                                                    [ disabled True
                                                    , hidden True
                                                    , selected (crFormData.fieldRequestingHelpFrom == Nothing)
                                                    ]
                                                    [ text "Select Your Field" ]
                                                , option
                                                    [ selected (crFormData.fieldRequestingHelpFrom == Just Field.Biology) ]
                                                    [ text "Biology" ]
                                                , option
                                                    [ selected (crFormData.fieldRequestingHelpFrom == Just Field.Chemistry) ]
                                                    [ text "Chemistry" ]
                                                , option
                                                    [ selected (crFormData.fieldRequestingHelpFrom == Just Field.Physics) ]
                                                    [ text "Physics" ]
                                                , option
                                                    [ selected (crFormData.fieldRequestingHelpFrom == Just Field.Math) ]
                                                    [ text "Math" ]
                                                , option
                                                    [ selected (crFormData.fieldRequestingHelpFrom == Just Field.Stats) ]
                                                    [ text "Stats" ]
                                                , option
                                                    [ selected (crFormData.fieldRequestingHelpFrom == Just Field.ComputerScience) ]
                                                    [ text "Computer Science" ]
                                                ]
                                            ]
                                    )
                                    (FormError.getErrorForField "fieldRequestingHelpFrom" model.taskRequestFormError)
                                    (Just "Field Requesting Help From")
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
                                    (FormError.getErrorForField "expectedTasksAndSkills" model.taskRequestFormError)
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
                                    (FormError.getErrorForField "reward" model.taskRequestFormError)
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
                                    (FormError.getErrorForField "additionalInfo" model.taskRequestFormError)
                                    (Just "Additional Info")
                                , p
                                    [ class "title is-size-7 has-text-danger has-text-centered" ]
                                    (List.map text model.taskRequestFormError.entire)
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
    = SelectedResearchField String
    | EnteredResearchSubject String
    | EnteredProjectImpactSummary String
    | SelectedFieldRequestingHelpFrom String
    | EnteredExpectedTasksAndSkills String
    | EnteredReward String
    | EnteredAdditionalInfo String
    | SubmittedForm
    | CompletedCreateTaskRequest (Result (Core.HttpError FormError.Error) String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        navKey =
            Session.navKey model.session

        updateFormData updater modelIn =
            { modelIn | taskRequstFormData = updater model.taskRequstFormData }
    in
    case msg of
        SelectedResearchField selectedResearchField ->
            ( model |> updateFormData (\fd -> { fd | researchField = Field.fromString selectedResearchField }), Cmd.none )

        EnteredResearchSubject researchSubjectInput ->
            ( model |> updateFormData (\fd -> { fd | researchSubject = researchSubjectInput }), Cmd.none )

        EnteredProjectImpactSummary projectImpactSummaryInput ->
            ( model |> updateFormData (\fd -> { fd | projectImpactSummary = projectImpactSummaryInput }), Cmd.none )

        EnteredReward rewardInput ->
            ( model |> updateFormData (\fd -> { fd | reward = rewardInput }), Cmd.none )

        SelectedFieldRequestingHelpFrom selectedFieldRequestingHelpFrom ->
            ( model
                |> updateFormData
                    (\fd ->
                        { fd
                            | fieldRequestingHelpFrom = Field.fromString selectedFieldRequestingHelpFrom
                        }
                    )
            , Cmd.none
            )

        EnteredExpectedTasksAndSkills expectedTasksAndSkillsInput ->
            ( model |> updateFormData (\fd -> { fd | expectedTasksAndSkills = expectedTasksAndSkillsInput }), Cmd.none )

        EnteredAdditionalInfo additionalInfoInput ->
            ( model |> updateFormData (\fd -> { fd | additionalInfo = additionalInfoInput }), Cmd.none )

        SubmittedForm ->
            ( model, Api.createTaskRequest model.taskRequstFormData CompletedCreateTaskRequest )

        CompletedCreateTaskRequest (Ok taskRequestId) ->
            ( model, Route.replaceUrl navKey <| Route.BrowseTaskRequest taskRequestId )

        CompletedCreateTaskRequest (Err httpCreateRequestError) ->
            ( { model | taskRequestFormError = FormError.fromHttpError httpCreateRequestError }, Cmd.none )
