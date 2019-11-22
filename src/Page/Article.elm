module Page.Article exposing (Model, Msg, init, update, viewDocument)

--- MODEL ---

import Api
import Article exposing (Article)
import ArticleId exposing (ArticleId)
import Browser exposing (Document)
import Comment exposing (Comment)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import LogElement
import MarkdownString exposing (Markdown)
import ViewElements.Container as Container
import ViewElements.Header as Header


type Model
    = Loading
    | Failure Http.Error
    | LoadingComments Article
    | Success SuccessModel


type alias SuccessModel =
    { article : Article
    , comments : List Comment
    }



--- UPDATE ---


type Msg
    = FetchedArticle (Result Http.Error Article)
    | FetchedComments (Result Http.Error (List Comment))
    | ErrorLogged (Result Http.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchedArticle result ->
            case result of
                Ok article ->
                    ( LoadingComments article
                    , article
                        |> Article.id
                        |> Api.getComments FetchedComments
                    )

                Err error ->
                    ( Failure error
                    , error
                        |> LogElement.fromHttpError "Get article"
                        |> Maybe.map (Api.writeToServerLog ErrorLogged)
                        |> Maybe.withDefault Cmd.none
                    )

        FetchedComments result ->
            case result of
                Ok comments ->
                    case model of
                        LoadingComments article ->
                            ( Success
                                { article = article
                                , comments = comments
                                }
                            , Cmd.none
                            )

                        Success successModel ->
                            ( Success { successModel | comments = comments }
                            , Cmd.none
                            )

                        _ ->
                            ( model, Cmd.none )

                Err error ->
                    ( model, Cmd.none )

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

        LoadingComments _ ->
            [ text "" ]

        Failure _ ->
            [ text "error" ]

        Success successModel ->
            viewSuccess successModel


viewSuccess : SuccessModel -> List (Html Msg)
viewSuccess successModel =
    [ viewArticle successModel.article
    , viewComments successModel.comments
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


viewComments : List Comment -> Html Msg
viewComments comments =
    div [ class "comment-section" ]
        [ h2 []
            [ comments
                |> List.length
                |> numberOfCommentsString
                |> text
            ]
        , div [ class "comments" ]
            (List.map viewComment comments)
        ]


numberOfCommentsString : Int -> String
numberOfCommentsString numberOfComments =
    if numberOfComments == 0 then
        "No comments"

    else if numberOfComments == 1 then
        "1 comment"

    else
        String.fromInt numberOfComments ++ " comments"


viewComment : Comment -> Html Msg
viewComment comment =
    div [ class "comment" ]
        [ div [ class "comment-username" ]
            [ text (Comment.username comment) ]
        , div [ class "comment-text" ]
            [ text (Comment.text comment) ]
        , div [ class "subcomments" ]
            []
        ]



--- INIT ---


init : ArticleId -> ( Model, Cmd Msg )
init articleId =
    ( Loading, Api.getArticle FetchedArticle articleId )
