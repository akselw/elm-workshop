module Page.Articles exposing
    ( Model
    , Msg
    , init
    , update
    , viewDocument
    )

import Api
import ArticleId
import ArticleSummary exposing (ArticleSummary)
import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Http
import LogElement
import MarkdownString
import ViewElements.Container as Container
import ViewElements.Header as Header



--- MODEL ---


type Model
    = Loading
    | Failure Http.Error
    | Success SuccessModel


type alias SuccessModel =
    { articles : List ArticleSummary }



--- UPDATE ---


type Msg
    = FetchedArticles (Result Http.Error (List ArticleSummary))
    | ErrorLogged (Result Http.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchedArticles result ->
            case result of
                Ok articles ->
                    ( Success { articles = articles }, Cmd.none )

                Err error ->
                    ( Failure error
                    , error
                        |> LogElement.fromHttpError "Get articles"
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
            [ viewContent model
            ]
        ]
    ]


viewContent : Model -> Html Msg
viewContent model =
    case model of
        Loading ->
            text "Spinner"

        Failure error ->
            text "error"

        Success successModel ->
            viewSuccess successModel


viewSuccess : SuccessModel -> Html Msg
viewSuccess successModel =
    viewArticles successModel.articles


viewArticles : List ArticleSummary -> Html Msg
viewArticles articles =
    ul []
        (List.map viewArticle articles)


viewArticle : ArticleSummary -> Html Msg
viewArticle article =
    li []
        [ a [ href ("/article/" ++ (ArticleSummary.id >> ArticleId.toString) article) ]
            [ article
                |> ArticleSummary.title
                |> MarkdownString.toHtml
            ]
        ]



--- INIT ---


init : ( Model, Cmd Msg )
init =
    ( Loading, Api.getArticles FetchedArticles )
