module Page.Account exposing (Model, Msg(..), init, update, view)

{-| A blank page.
-}

import Account
import Api.Api as Api
import Api.Core as Core
import Api.Errors.Form as FormError
import Bulma
import Field
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import MaybeUtil
import Session exposing (Session)
import UniversityPosition
import User exposing (User)


{-| TODO remove dup data with session and user.
-}
type alias Model =
    { session : Session
    , user : User
    , accountForm : Account.AccountData
    , formError : FormError.Error
    }


init : Session -> User -> ( Model, Cmd Msg )
init session user =
    ( { session = session
      , user = user
      , accountForm = user.accountData
      , formError = FormError.empty
      }
    , Cmd.none
    )


view : Model -> { title : String, content : Html.Html Msg }
view model =
    { title = "Account"
    , content =
        let
            changedAccountData =
                model.user.accountData /= model.accountForm
        in
        div
            [ class "section" ]
            [ div
                [ class "columns is-centered" ]
                [ div
                    [ class "column is-half-desktop is-two-thirds-tablet" ]
                    [ div
                        [ class "box" ]
                        [ div [ class "title has-text-centered" ] [ text "Account Information" ]
                        , Bulma.formControl
                            (\hasError ->
                                input
                                    [ class "input"
                                    , disabled True
                                    , value model.user.email
                                    ]
                                    []
                            )
                            (FormError.getErrorForField "email" model.formError)
                            (Just "Email")
                        , Bulma.formControl
                            (\hasError ->
                                input
                                    [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                    , onInput EnteredName
                                    , value model.accountForm.name
                                    , placeholder "Bob Smith"
                                    ]
                                    []
                            )
                            (FormError.getErrorForField "name" model.formError)
                            (Just "Name")
                        , Bulma.formControl
                            (\hasError ->
                                div
                                    [ classList [ ( "select", True ), ( "is-danger", hasError ) ] ]
                                    [ select
                                        [ onInput SelectedUniversityPosition ]
                                        [ option
                                            [ disabled True
                                            , hidden True
                                            , selected (model.accountForm.universityPosition == Nothing)
                                            ]
                                            [ text "Select Your Current Position" ]
                                        , option
                                            [ selected <|
                                                model.accountForm.universityPosition
                                                    == Just UniversityPosition.Undergrad
                                            ]
                                            [ text "Undergrad" ]
                                        , option
                                            [ selected <|
                                                model.accountForm.universityPosition
                                                    == Just UniversityPosition.Masters
                                            ]
                                            [ text "Masters" ]
                                        , option
                                            [ selected <|
                                                model.accountForm.universityPosition
                                                    == Just UniversityPosition.PHD
                                            ]
                                            [ text "PHD" ]
                                        , option
                                            [ selected <|
                                                model.accountForm.universityPosition
                                                    == Just UniversityPosition.PostDoc
                                            ]
                                            [ text "Post Doc" ]
                                        , option
                                            [ selected <|
                                                model.accountForm.universityPosition
                                                    == Just UniversityPosition.Instructor
                                            ]
                                            [ text "Instructor" ]
                                        , option
                                            [ selected <|
                                                model.accountForm.universityPosition
                                                    == Just UniversityPosition.AssistantProfessor
                                            ]
                                            [ text "Assistant Professor" ]
                                        , option
                                            [ selected <|
                                                model.accountForm.universityPosition
                                                    == Just UniversityPosition.Professor
                                            ]
                                            [ text "Professor" ]
                                        ]
                                    ]
                            )
                            (FormError.getErrorForField "universityPosition" model.formError)
                            (Just "University Position")
                        , if
                            MaybeUtil.mapWithDefault
                                False
                                UniversityPosition.hasSupervisor
                                model.accountForm.universityPosition
                          then
                            Bulma.formControl
                                (\hasError ->
                                    input
                                        [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                        , onInput EnteredSupervisorEmail
                                        , value model.accountForm.supervisorEmail
                                        , placeholder "prof.name@myuni.com"
                                        ]
                                        []
                                )
                                (FormError.getErrorForField "supervisorEmail" model.formError)
                                (Just "Supervisor Email")

                          else
                            div [ class "is-hidden" ] []
                        , Bulma.formControl
                            (\hasError ->
                                div
                                    [ classList [ ( "select", True ), ( "is-danger", hasError ) ] ]
                                    [ select
                                        [ onInput SelectedField ]
                                        [ option
                                            [ disabled True
                                            , hidden True
                                            , selected (model.accountForm.field == Nothing)
                                            ]
                                            [ text "Select Your Field" ]
                                        , option
                                            [ selected (model.accountForm.field == Just Field.Biology) ]
                                            [ text "Biology" ]
                                        , option
                                            [ selected (model.accountForm.field == Just Field.Chemistry) ]
                                            [ text "Chemistry" ]
                                        , option
                                            [ selected (model.accountForm.field == Just Field.Physics) ]
                                            [ text "Physics" ]
                                        , option
                                            [ selected (model.accountForm.field == Just Field.Math) ]
                                            [ text "Math" ]
                                        , option
                                            [ selected (model.accountForm.field == Just Field.Stats) ]
                                            [ text "Stats" ]
                                        , option
                                            [ selected (model.accountForm.field == Just Field.ComputerScience) ]
                                            [ text "Computer Science" ]
                                        ]
                                    ]
                            )
                            (FormError.getErrorForField "field" model.formError)
                            (Just "Field")
                        , Bulma.formControl
                            (\hasError ->
                                input
                                    [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                    , onInput EnteredSpecialization
                                    , value model.accountForm.specialization
                                    , placeholder "Machine Learning"
                                    ]
                                    []
                            )
                            (FormError.getErrorForField "specialization" model.formError)
                            (Just "Specialization")
                        , Bulma.formControl
                            (\hasError ->
                                input
                                    [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                    , onInput EnteredUniversity
                                    , value model.accountForm.university
                                    , placeholder "University of British Columbia"
                                    ]
                                    []
                            )
                            []
                            (Just "University")
                        , Bulma.formControl
                            (\hasError ->
                                textarea
                                    [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                    , onInput EnteredDegreesHeld
                                    , style "height" "100px"
                                    , value model.accountForm.degreesHeld
                                    , placeholder "List all your degrees."
                                    ]
                                    []
                            )
                            (FormError.getErrorForField "degreesHeld" model.formError)
                            (Just "Degrees Held")
                        , Bulma.formControl
                            (\hasError ->
                                input
                                    [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                    , onInput EnteredCurrentAvailibility
                                    , value model.accountForm.currentAvailability
                                    , placeholder "Can take on small projects"
                                    ]
                                    []
                            )
                            (FormError.getErrorForField "currentAvailability" model.formError)
                            (Just "Current Availability")
                        , Bulma.formControl
                            (\hasError ->
                                textarea
                                    [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                    , onInput EnteredShortBio
                                    , style "height" "100px"
                                    , value model.accountForm.shortBio
                                    , placeholder """A short bio about yourself"""
                                    ]
                                    []
                            )
                            (FormError.getErrorForField "shortBio" model.formError)
                            (Just "Short Bio")
                        , Bulma.formControl
                            (\hasError ->
                                textarea
                                    [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                    , onInput EnteredResearchExperienceAndPapers
                                    , style "height" "100px"
                                    , value model.accountForm.researchExperienceAndPapers
                                    , placeholder "List all important research papers and experiences."
                                    ]
                                    []
                            )
                            (FormError.getErrorForField "researchExperienceAndPapers" model.formError)
                            (Just "Research Papers and Experience")
                        , Bulma.formControl
                            (\hasError ->
                                input
                                    [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                    , onInput EnteredLinkedInUrl
                                    , value model.accountForm.linkedInUrl
                                    , placeholder "https://www.linkedin.com/in/arie-milner-8990ba106/"
                                    ]
                                    []
                            )
                            (FormError.getErrorForField "linkedInUrl" model.formError)
                            (Just "LinkedIn Url")
                        , p
                            [ class "title is-size-7 has-text-danger has-text-centered" ]
                            (List.map text model.formError.entire)
                        , div
                            [ class "buttons is-right" ]
                            [ button
                                [ class "button is-success"
                                , disabled <| not changedAccountData
                                , onClick SubmittedForm
                                ]
                                [ text "save changes" ]
                            ]
                        ]
                    ]
                ]
            ]
    }


type Msg
    = NoOp
    | EnteredName String
    | SelectedUniversityPosition String
    | SelectedField String
    | EnteredSpecialization String
    | EnteredUniversity String
    | EnteredCurrentAvailibility String
    | EnteredSupervisorEmail String
    | EnteredShortBio String
    | EnteredLinkedInUrl String
    | EnteredDegreesHeld String
    | EnteredResearchExperienceAndPapers String
    | SubmittedForm
    | CompletedUpdateAccount (Result (Core.HttpError FormError.Error) ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        user =
            model.user

        updateAccountForm transform =
            transform model.accountForm
    in
    case msg of
        NoOp ->
            ( model, Cmd.none )

        EnteredName nameInput ->
            ( { model | accountForm = updateAccountForm (\accountForm -> { accountForm | name = nameInput }) }
            , Cmd.none
            )

        SelectedUniversityPosition selectedUniversityPosition ->
            ( { model
                | accountForm =
                    updateAccountForm
                        (\accountForm ->
                            { accountForm
                                | universityPosition = UniversityPosition.fromString selectedUniversityPosition
                            }
                        )
              }
            , Cmd.none
            )

        SelectedField selectedField ->
            ( { model
                | accountForm =
                    updateAccountForm (\accountForm -> { accountForm | field = Field.fromString selectedField })
              }
            , Cmd.none
            )

        EnteredSpecialization specializationInput ->
            ( { model
                | accountForm =
                    updateAccountForm (\accountForm -> { accountForm | specialization = specializationInput })
              }
            , Cmd.none
            )

        EnteredCurrentAvailibility currentAvailabilityInput ->
            ( { model
                | accountForm =
                    updateAccountForm (\accountForm -> { accountForm | currentAvailability = currentAvailabilityInput })
              }
            , Cmd.none
            )

        EnteredUniversity universityInput ->
            ( { model
                | accountForm = updateAccountForm (\accountForm -> { accountForm | university = universityInput })
              }
            , Cmd.none
            )

        EnteredSupervisorEmail supervisorEmailInput ->
            ( { model
                | accountForm =
                    updateAccountForm (\accountForm -> { accountForm | supervisorEmail = supervisorEmailInput })
              }
            , Cmd.none
            )

        EnteredShortBio shortBioInput ->
            ( { model | accountForm = updateAccountForm (\accountForm -> { accountForm | shortBio = shortBioInput }) }
            , Cmd.none
            )

        EnteredLinkedInUrl linkedInUrlInput ->
            ( { model
                | accountForm = updateAccountForm (\accountForm -> { accountForm | linkedInUrl = linkedInUrlInput })
              }
            , Cmd.none
            )

        EnteredDegreesHeld degreesHeldInput ->
            ( { model
                | accountForm = updateAccountForm (\accountForm -> { accountForm | degreesHeld = degreesHeldInput })
              }
            , Cmd.none
            )

        EnteredResearchExperienceAndPapers researchExperienceAndPapersInput ->
            ( { model
                | accountForm =
                    updateAccountForm
                        (\accountForm ->
                            { accountForm | researchExperienceAndPapers = researchExperienceAndPapersInput }
                        )
              }
            , Cmd.none
            )

        SubmittedForm ->
            ( model
            , Api.updateAccount model.user.id model.accountForm CompletedUpdateAccount
            )

        CompletedUpdateAccount (Ok _) ->
            ( { model
                | user = { user | accountData = model.accountForm }
                , formError = FormError.empty
              }
            , Cmd.none
            )

        CompletedUpdateAccount (Err httpErr) ->
            ( { model | formError = FormError.fromHttpError httpErr }, Cmd.none )
