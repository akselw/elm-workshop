module ViewElements.Button exposing (Button, button, toHtml, withSpinner)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


type Button msg
    = Button
        { onClick : msg
        , text : String
        , showSpinner : Bool
        }


button : msg -> String -> Button msg
button onClick text =
    Button
        { onClick = onClick
        , text = text
        , showSpinner = False
        }



--- OPTIONS ---


withSpinner : Button msg -> Button msg
withSpinner (Button options) =
    Button { options | showSpinner = True }



--- HTML ----


toHtml : Button msg -> Html msg
toHtml (Button options) =
    Html.button [ class "button", onClick options.onClick ]
        [ text options.text
        , if options.showSpinner then
            span [ class "button__spinner" ] []

          else
            text ""
        ]
