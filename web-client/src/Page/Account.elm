module Page.Account exposing (Model, Msg(..), init, update, view)

{-| A blank page.
-}

import Account
import Api.Api as Api
import Api.Core as Core
import Api.Errors.Form as FormError
import Bulma
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Session exposing (Session)
import Viewer exposing (Viewer)


{-| TODO remove dup data with session and viewer.
-}
type alias Model =
    { session : Session
    , viewer : Viewer
    , accountForm : Account.AccountData
    , formError : FormError.Error
    }


init : Session -> Viewer -> ( Model, Cmd Msg )
init session viewer =
    ( { session = session
      , viewer = viewer
      , accountForm = Account.emptyData
      , formError = FormError.empty
      }
    , Cmd.none
    )


view : Model -> { title : String, content : Html.Html Msg }
view model =
    { title = "Browse"
    , content =
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
                                    , value <| Viewer.getEmail model.viewer
                                    ]
                                    []
                            )
                            []
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
                            []
                            (Just "Name")
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
                            []
                            (Just "LinkedIn Profile")
                        , Bulma.formControl
                            (\hasError ->
                                input
                                    [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                    , onInput EnteredField
                                    , value model.accountForm.field
                                    , placeholder "Computer Science"
                                    ]
                                    []
                            )
                            []
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
                            []
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
                            []
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
                            []
                            (Just "Current Availability")
                        , Bulma.formControl
                            (\hasError ->
                                input
                                    [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                    , onInput EnteredSupervisorEmail
                                    , value model.accountForm.supervisorEmail
                                    , placeholder "smartprof@myuni.com"
                                    ]
                                    []
                            )
                            []
                            (Just "Supervisor Email")
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
                            []
                            (Just "Short Bio")
                        , Bulma.formControl
                            (\hasError ->
                                textarea
                                    [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                    , onInput EnteredResearchPapers
                                    , style "height" "100px"
                                    , value model.accountForm.researchPapers
                                    , placeholder "List things you have published."
                                    ]
                                    []
                            )
                            []
                            (Just "Research Papers")
                        , Bulma.formControl
                            (\hasError ->
                                textarea
                                    [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                    , onInput EnteredResearchExperience
                                    , style "height" "100px"
                                    , value model.accountForm.researchExperience
                                    , placeholder "List research experience that may not have published a paper."
                                    ]
                                    []
                            )
                            []
                            (Just "Research Experience")
                        , button
                            [ class "button button is-success is-fullwidth"
                            , onClick SubmittedForm
                            ]
                            [ text "Update Account" ]
                        ]
                    ]
                ]
            ]
    }


type Msg
    = NoOp
    | EnteredName String
    | EnteredField String
    | EnteredSpecialization String
    | EnteredUniversity String
    | EnteredCurrentAvailibility String
    | EnteredSupervisorEmail String
    | EnteredShortBio String
    | EnteredLinkedInUrl String
    | EnteredDegreesHeld String
    | EnteredResearchPapers String
    | EnteredResearchExperience String
    | SubmittedForm
    | CompletedUpdateAccount (Result (Core.HttpError FormError.Error) ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
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

        EnteredField fieldInput ->
            ( { model | accountForm = updateAccountForm (\accountForm -> { accountForm | field = fieldInput }) }
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

        EnteredResearchPapers researchPapersInput ->
            ( { model
                | accountForm =
                    updateAccountForm (\accountForm -> { accountForm | researchPapers = researchPapersInput })
              }
            , Cmd.none
            )

        EnteredResearchExperience researchExperienceInput ->
            ( { model
                | accountForm =
                    updateAccountForm (\accountForm -> { accountForm | researchExperience = researchExperienceInput })
              }
            , Cmd.none
            )

        SubmittedForm ->
            ( model
            , Api.updateAccount (Viewer.getId model.viewer) model.accountForm CompletedUpdateAccount
            )

        CompletedUpdateAccount (Ok _) ->
            ( model, Cmd.none )

        CompletedUpdateAccount (Err err) ->
            ( model, Cmd.none )
