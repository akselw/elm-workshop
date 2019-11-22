module ViewElements.Container exposing (mainContent)

import Html exposing (..)
import Html.Attributes exposing (..)


mainContent : List (Html msg) -> Html msg
mainContent children =
    div [ class "main-content-wrapper" ]
        [ div [ class "main-content" ]
            children
        ]
