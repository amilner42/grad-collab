module Page.Login exposing (Model, Msg, init, update, view)

{-| The login page.
-}

import Api.Api as Api
import Api.Core as Core
import Api.Errors.Form as FormError
import Bulma
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Route exposing (Route)
import Session exposing (Session)
import User exposing (User)



-- MODEL


type alias Model =
    { session : Session
    , form : Form
    , formError : FormError.Error
    }


type alias Form =
    { email : String
    , password : String
    }


init : Session -> ( Model, Cmd msg )
init session =
    ( { session = session
      , form =
            { email = ""
            , password = ""
            }
      , formError = FormError.empty
      }
    , Cmd.none
    )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Login"
    , content =
        section
            [ class "section is-medium" ]
            [ div
                [ class "container" ]
                [ div
                    [ class "columns is-centered" ]
                    [ div
                        [ class "column is-half" ]
                        [ div
                            [ class "box", style "padding" "40px" ]
                            [ h1 [ class "title has-text-centered" ] [ text "Welcome Back" ]
                            , p
                                [ class "title is-size-7 has-text-danger has-text-centered" ]
                                (List.map text <| model.formError.entire)
                            , Bulma.formControl
                                (\hasError ->
                                    input
                                        [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                        , style "text-align" "center"
                                        , placeholder "school email"
                                        , onInput EnteredEmail
                                        , value model.form.email
                                        ]
                                        []
                                )
                                (FormError.getErrorForField "email" model.formError)
                                Nothing
                            , Bulma.formControl
                                (\hasError ->
                                    input
                                        [ classList [ ( "input", True ), ( "is-danger", hasError ) ]
                                        , style "text-align" "center"
                                        , placeholder "password"
                                        , type_ "password"
                                        , onInput EnteredPassword
                                        , value model.form.password
                                        ]
                                        []
                                )
                                (FormError.getErrorForField "password" model.formError)
                                Nothing
                            , button
                                [ class "button is-success is-fullwidth"
                                , onClick SubmittedForm
                                ]
                                [ text "Log in" ]
                            ]
                        ]
                    ]
                ]
            ]
    }



-- UPDATE


type Msg
    = SubmittedForm
    | EnteredEmail String
    | EnteredPassword String
    | CompletedLogin (Result (Core.HttpError FormError.Error) User)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubmittedForm ->
            case validate model.form of
                Ok validForm ->
                    ( { model | formError = FormError.empty }
                    , login validForm CompletedLogin
                    )

                Err formError ->
                    ( { model | formError = formError }
                    , Cmd.none
                    )

        EnteredEmail email ->
            updateForm (\form -> { form | email = email }) model

        EnteredPassword password ->
            updateForm (\form -> { form | password = password }) model

        CompletedLogin (Err httpLoginError) ->
            ( { model | formError = FormError.fromHttpError httpLoginError }
            , Cmd.none
            )

        CompletedLogin (Ok user) ->
            let
                navKey =
                    Session.navKey model.session
            in
            ( { model | session = Session.LoggedIn navKey user }
            , Route.replaceUrl navKey Route.Home
            )


{-| Helper function for `update`. Updates the form and returns Cmd.none.
-}
updateForm : (Form -> Form) -> Model -> ( Model, Cmd Msg )
updateForm transform model =
    ( { model | form = transform model.form }, Cmd.none )



-- FORM


{-| Marks that we've trimmed the form's fields, so we don't accidentally send it to the server
without having trimmed it.
-}
type TrimmedForm
    = Trimmed Form


{-| Trim the form and validate its fields. If there are errors, report them.
-}
validate : Form -> Result FormError.Error TrimmedForm
validate form =
    let
        trimmedForm =
            trimFields form

        loginError =
            (FormError.fromFieldErrors << FormError.fieldErrorsFromList)
                [ ( "email"
                  , if String.isEmpty form.email then
                        Just [ "email can't be blank" ]

                    else
                        Nothing
                  )
                , ( "password"
                  , if String.isEmpty form.password then
                        Just [ "password can't be blank" ]

                    else
                        Nothing
                  )
                ]
    in
    if FormError.hasError loginError then
        Err loginError

    else
        Ok trimmedForm


{-| Trim fields prior to submission.
-}
trimFields : Form -> TrimmedForm
trimFields form =
    Trimmed
        { email = String.trim form.email
        , password = String.trim form.password
        }



-- HTTP


login : TrimmedForm -> (Result.Result (Core.HttpError FormError.Error) User -> msg) -> Cmd.Cmd msg
login (Trimmed form) =
    Api.login { email = form.email, password = form.password }
