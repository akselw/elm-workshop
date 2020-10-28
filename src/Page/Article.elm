module Page.Article exposing (Model, Msg, init, update, viewDocument)

import Api
import Article exposing (Article)
import ArticleId exposing (ArticleId)
import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import LogElement
import MarkdownString exposing (Markdown)
import ViewElements.Button as Button
import ViewElements.Container as Container
import ViewElements.Header as Header
import ViewElements.Textarea as Textarea



--- MODEL ---


type Model
    = Loading
    | Failure Http.Error
    | Success SuccessModel


type alias SuccessModel =
    { article : Article
    }



--- UPDATE ---


type Msg
    = FetchedArticle (Result Http.Error Article)
    | ErrorLogged (Result Http.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchedArticle result ->
            case result of
                Ok article ->
                    ( Success { article = article }, Cmd.none )

                Err error ->
                    ( Failure error
                    , error
                        |> LogElement.fromHttpError "Get article"
                        |> Maybe.map (Api.writeToServerLog ErrorLogged)
                        |> Maybe.withDefault Cmd.none
                    )

        ErrorLogged result ->
            ( model, Cmd.none )



--- VIEW ---


viewDocument : Model -> Document Msg
viewDocument model =
    { title = "Articles"
    , body = view model
    }


view : Model -> List (Html Msg)
view model =
    [ div [ class "app" ]
        [ Header.header
        , Container.mainContent
            (viewContent model)
        ]
    ]


viewContent : Model -> List (Html Msg)
viewContent model =
    case model of
        Loading ->
            [ text "" ]

        Failure _ ->
            [ text "error" ]

        Success successModel ->
            viewSuccess successModel


viewSuccess : SuccessModel -> List (Html Msg)
viewSuccess successModel =
    [ viewArticle successModel.article
    ]


viewArticle : Article -> Html Msg
viewArticle article =
    div [ class "article" ]
        [ h2 []
            [ article
                |> Article.title
                |> MarkdownString.toHtml
            ]
        , article
            |> Article.lead
            |> Maybe.map viewLead
            |> Maybe.withDefault (text "")
        , article
            |> Article.body
            |> MarkdownString.toHtml
        ]


viewLead : Markdown -> Html msg
viewLead markdownContent =
    div [ class "lead" ]
        [ MarkdownString.toHtml markdownContent ]



--- INIT ---


init : ArticleId -> ( Model, Cmd Msg )
init articleId =
    ( Loading, Api.getArticle FetchedArticle articleId )
