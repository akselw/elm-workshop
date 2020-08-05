module Page.Article exposing (Model, Msg, init, update, viewDocument)

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
import ViewElements.Button as Button
import ViewElements.Container as Container
import ViewElements.Header as Header
import ViewElements.Textarea as Textarea



--- MODEL ---


type Model
    = Loading
    | Failure Http.Error
    | LoadingComments Article
    | Success SuccessModel


type alias SuccessModel =
    { article : Article
    , comments : List Comment
    , newCommentState : NewCommentState
    }


type NewCommentState
    = WritingComment String
    | SavingComment String
    | ErrorSavingComment String Http.Error



--- UPDATE ---


type Msg
    = FetchedArticle (Result Http.Error Article)
    | FetchedComments (Result Http.Error (List Comment))
    | CommentUpdated String
    | PostCommentButtonClicked
    | SavingCommentFinished (Result Http.Error (List Comment))
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
                        |> Api.getNestedComments FetchedComments
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
                                , newCommentState = WritingComment ""
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

        CommentUpdated string ->
            case model of
                Success successModel ->
                    case successModel.newCommentState of
                        WritingComment _ ->
                            ( Success { successModel | newCommentState = WritingComment string }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        PostCommentButtonClicked ->
            case model of
                Success successModel ->
                    case successModel.newCommentState of
                        WritingComment commentBoxText ->
                            ( Success { successModel | newCommentState = SavingComment commentBoxText }
                            , Api.createCommentOnArticle SavingCommentFinished (Article.id successModel.article) commentBoxText
                            )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SavingCommentFinished result ->
            case model of
                Success successModel ->
                    case successModel.newCommentState of
                        SavingComment commentBoxText ->
                            case result of
                                Ok comments ->
                                    ( Success
                                        { successModel
                                            | comments = comments
                                            , newCommentState = WritingComment ""
                                        }
                                    , Cmd.none
                                    )

                                Err error ->
                                    ( Success { successModel | newCommentState = ErrorSavingComment commentBoxText error }
                                    , error
                                        |> LogElement.fromHttpError "Post comment on article"
                                        |> Maybe.map (Api.writeToServerLog ErrorLogged)
                                        |> Maybe.withDefault Cmd.none
                                    )

                        _ ->
                            ( model, Cmd.none )

                _ ->
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
    , viewComments successModel
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


viewComments : SuccessModel -> Html Msg
viewComments model =
    div [ class "comment-section" ]
        [ h2 []
            [ model.comments
                |> numberOfComments
                |> numberOfCommentsString
                |> text
            ]
        , div [ class "comments" ]
            (List.map viewComment model.comments)
        , viewWriteComment model
        ]


numberOfCommentsString : Int -> String
numberOfCommentsString numberOfComments_ =
    if numberOfComments_ == 0 then
        "No comments"

    else if numberOfComments_ == 1 then
        "1 comment"

    else
        String.fromInt numberOfComments_ ++ " comments"


numberOfComments : List Comment -> Int
numberOfComments comments =
    comments
        |> List.map (\comment -> 1 + numberOfComments (Comment.subcomments comment))
        |> List.sum


viewComment : Comment -> Html Msg
viewComment comment =
    div [ class "comment" ]
        [ div [ class "comment-username" ]
            [ text (Comment.username comment) ]
        , div [ class "comment-text" ]
            [ text (Comment.text comment) ]
        , if (Comment.subcomments >> List.isEmpty) comment then
            text ""

          else
            div [ class "subcomments" ]
                (comment
                    |> Comment.subcomments
                    |> List.map viewComment
                )
        ]


viewWriteComment : SuccessModel -> Html Msg
viewWriteComment { newCommentState } =
    case newCommentState of
        WritingComment commentBoxText ->
            div [ class "write-new-comment" ]
                [ Textarea.textarea { label = "Add comment", onInput = CommentUpdated } commentBoxText
                    |> Textarea.toHtml
                , Container.buttonRow
                    [ Button.button PostCommentButtonClicked "Post"
                        |> Button.toHtml
                    ]
                ]

        _ ->
            text ""



--- INIT ---


init : ArticleId -> ( Model, Cmd Msg )
init articleId =
    ( Loading, Api.getArticle FetchedArticle articleId )
