module ViewElements.Header exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


header : Html msg
header =
    div [ class "header" ]
        [ a [ href "/" ]
            [ h1 []
                [ text "Article site"
                ]
            ]
        ]
