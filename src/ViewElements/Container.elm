module ViewElements.Container exposing (buttonRow, mainContent)

import Html exposing (..)
import Html.Attributes exposing (..)


mainContent : List (Html msg) -> Html msg
mainContent children =
    div [ class "main-content-wrapper" ]
        [ div [ class "main-content" ]
            children
        ]


buttonRow : List (Html msg) -> Html msg
buttonRow buttons =
    div [ class "button-row" ]
        buttons
