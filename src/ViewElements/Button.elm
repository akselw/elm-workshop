module ViewElements.Button exposing (Button, button, toHtml)

import Html exposing (..)
import Html.Attributes exposing (class)


type Button msg
    = Button
        { onClick : msg
        , text : String
        }


button : msg -> String -> Button msg
button onClick text =
    Button
        { onClick = onClick
        , text = text
        }



--- HTML ----


toHtml : Button msg -> Html msg
toHtml (Button options) =
    Html.button [ class "button" ]
        [ text options.text ]
