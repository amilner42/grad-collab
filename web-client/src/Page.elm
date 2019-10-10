module Page exposing (HighlightableTab(..), view)

{-| This allows you to insert a page, providing the navbar outline common to all pages.
-}

import Api.Core exposing (Cred)
import Asset
import Browser exposing (Document)
import Html exposing (Html, a, button, div, i, img, li, nav, p, span, strong, text, ul)
import Html.Attributes exposing (class, classList, href)
import Html.Events exposing (onClick)
import Route exposing (Route)
import Session exposing (Session)
import Viewer exposing (Viewer)


type alias RenderPageConfig msg =
    { mobileNavbarOpen : Bool
    , toggleMobileNavbar : msg
    , maybeViewer : Maybe Viewer
    , activeTab : Maybe HighlightableTab
    }


type HighlightableTab
    = Home
    | Browse
    | Create
    | Login
    | Register


{-| Take a page's Html and frames it with a navbar.
-}
view :
    RenderPageConfig msg
    -> { title : String, content : Html pageMsg }
    -> (pageMsg -> msg)
    -> Document msg
view navConfig { title, content } toMsg =
    { title = title
    , body = viewNavbar navConfig :: List.map (Html.map toMsg) [ content ]
    }


{-| Render the navbar.

Will have log-in/sign-up or logout buttons according to whether there is a `Viewer`.

-}
viewNavbar : RenderPageConfig msg -> Html msg
viewNavbar { mobileNavbarOpen, toggleMobileNavbar, maybeViewer, activeTab } =
    nav [ class "navbar is-info" ]
        [ div
            [ class "navbar-brand" ]
            [ div
                [ classList
                    [ ( "navbar-burger", True )
                    , ( "is-active", mobileNavbarOpen )
                    ]
                , onClick toggleMobileNavbar
                ]
                [ span [] [], span [] [], span [] [] ]
            ]
        , div
            [ classList
                [ ( "navbar-menu", True )
                , ( "is-active", mobileNavbarOpen )
                ]
            ]
            [ div
                [ class "navbar-start" ]
                [ a
                    [ classList
                        [ ( "navbar-item", True )
                        , ( "is-active", activeTab == Just Home )
                        ]
                    , Route.href Route.Home
                    ]
                    [ text "Home" ]
                , a
                    [ classList
                        [ ( "navbar-item", True )
                        , ( "is-active", activeTab == Just Browse )
                        ]
                    , Route.href Route.Browse
                    ]
                    [ text "Browse" ]
                , a
                    [ classList
                        [ ( "navbar-item", True )
                        , ( "is-active", activeTab == Just Create )
                        ]
                    , Route.href Route.Create
                    ]
                    [ text "Create" ]
                ]
            , div
                [ class "navbar-end" ]
                (case maybeViewer of
                    Nothing ->
                        [ a
                            [ classList
                                [ ( "navbar-item", True )
                                , ( "is-active", activeTab == Just Register )
                                ]
                            , Route.href Route.Register
                            ]
                            [ text "Sign up" ]
                        , a
                            [ classList
                                [ ( "navbar-item", True )
                                , ( "is-active", activeTab == Just Login )
                                ]
                            , Route.href Route.Login
                            ]
                            [ text "Log in" ]
                        ]

                    Just viewer ->
                        [ a
                            [ class "navbar-item", Route.href Route.Logout ]
                            [ text <| "Log out, " ++ Viewer.getEmail viewer ]
                        ]
                )
            ]
        ]
