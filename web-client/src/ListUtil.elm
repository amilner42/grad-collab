module ListUtil exposing (filterByBool, filterByMaybe)


filterByBool : List ( Bool, t ) -> List t
filterByBool =
    List.filterMap
        (\( keep, val ) ->
            if keep then
                Just val

            else
                Nothing
        )


filterByMaybe : List ( Maybe a, a -> t ) -> List t
filterByMaybe =
    List.filterMap (\( maybeVal, func ) -> Maybe.map func maybeVal)
