module ListUtil exposing (filterByBool)


filterByBool : List ( Bool, t ) -> List t
filterByBool =
    List.filterMap
        (\( keep, val ) ->
            if keep then
                Just val

            else
                Nothing
        )
