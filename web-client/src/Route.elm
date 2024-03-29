module Route exposing (Route(..), fromUrl, href, pushUrl, replaceUrl, routeToString)

{-| A type to represent possible routes with helper functions.
-}

import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)



-- ROUTING


{-| All website routes.

NOTE: Root will just redirect to whatever other page is currently set as the route.

-}
type Route
    = Root
    | Home
    | Login
    | Logout
    | Account
    | Register
    | CreateTask
    | Browse
    | BrowseTaskRequest String


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Login (s "login")
        , Parser.map Logout (s "logout")
        , Parser.map Account (s "account")
        , Parser.map Register (s "register")
        , Parser.map CreateTask (s "create" </> s "task")
        , Parser.map Browse (s "browse")
        , Parser.map BrowseTaskRequest (s "browse" </> s "task" </> string)
        ]



-- PUBLIC HELPERS


{-| A href that takes a Route instead of a url.
-}
href : Route -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)


{-| A replaceUrl that takes a Route instead of a url.
-}
replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)


{-| A pushUrl that takes a Route instead of a url.
-}
pushUrl : Nav.Key -> Route -> Cmd msg
pushUrl key route =
    Nav.pushUrl key (routeToString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Parser.parse parser


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Home ->
                    []

                Root ->
                    []

                Login ->
                    [ "login" ]

                Logout ->
                    [ "logout" ]

                Account ->
                    [ "account" ]

                Register ->
                    [ "register" ]

                CreateTask ->
                    [ "create", "task" ]

                Browse ->
                    [ "browse" ]

                BrowseTaskRequest id ->
                    [ "browse", "task", id ]
    in
    "#/" ++ String.join "/" pieces
