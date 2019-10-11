module FetchData exposing (FetchData(..), map)

{-| `FetchData` is like `RemoteData` but does not contain a `NotAsked` state for data that is requested immediately.
-}


type FetchData err val
    = Loading
    | Success val
    | Failure err


map : (val1 -> val2) -> FetchData err val1 -> FetchData err val2
map mapFn fetchData =
    case fetchData of
        Loading ->
            Loading

        Failure err ->
            Failure err

        Success val ->
            Success <| mapFn val
