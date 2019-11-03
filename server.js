const express = require('express');
const Bundler = require('parcel-bundler');
const path = require('path');
const low = require('lowdb');
const FileSync = require('lowdb/adapters/FileSync');
const fs = require('fs');
const shortid = require('shortid');

const databaseExists = fs.existsSync(path.resolve(__dirname, 'db.json'));

const adapter = new FileSync('db.json');
const db = low(adapter);


db.defaults({ articles: [], comments: [] })
    .write();

if (!databaseExists) {
    console.log('INFO: Creating database in db.json, and writing articles to it.');
    const articleId = shortid.generate();
    const firstCommentId = shortid.generate();
    const firstAnswerId = shortid.generate();
    db.get('articles')
        .push({
            id: articleId,
            title: 'Lowdb is awesome',
            lead: 'Lowdb is a database library for node, which uses json as a database.',
            body: 'Lowdb is perfect for CLIs, small servers, Electron apps and npm packages in general.\n' +
                '\n' +
                'It supports Node, the browser and uses lodash API, so it\'s very simple to learn. Actually, if you know Lodash, you already know how to use lowdb 😉'
        })
        .write();
    db.get('comments')
        .push({
            id: firstCommentId,
            articleId: articleId,
            commentOnCommentWithId: null,
            text: 'LowDB SUXXX!'
        })
        .push({
            id: firstAnswerId,
            articleId: articleId,
            commentOnCommentWithId: firstCommentId,
            text: 'No, you suck!!'
        })
        .push({
            id: shortid.generate(),
            articleId: articleId,
            commentOnCommentWithId: firstAnswerId,
            text: 'I like him!'
        })
        .push({
            id: shortid.generate(),
            articleId: articleId,
            commentOnCommentWithId: firstCommentId,
            text: 'I agree'
        })
        .push({
            id: shortid.generate(),
            articleId: articleId,
            commentOnCommentWithId: null,
            text: 'I like modifying global variables 😊'
        })
        .write();
    console.log(db.get('articles').value());
    console.log(db.get('comments').value());
} else {
    console.log('INFO: Using existing database. Delete or rename db.json to start a database from scratch.');
}

const server = express();

const entryFile = path.join(__dirname, './src/index.html');
const bundler = new Bundler(entryFile, {});

const toUnnested = (comment) => {
    console.log({ comment });
    return ({
        id: comment.id,
        text: comment.text
    });
};

const toNested = (comments) => {
    const topLevelComments = comments.filter((comment) => comment.commentOnCommentWithId === null);
    return topLevelComments.map((comment) => findSubcomments(comment, comments));

};

const findSubcomments = (comment, comments) => ({
    id: comment.id,
    text: comment.text,
    comments: comments
        .filter((subcomment) => subcomment.commentOnCommentWithId === comment.id)
        .map((subcomment) => findSubcomments(subcomment, comments))
});


const getArticles = () => (
    db.get('articles')
        .value()
        .map((article => ({
            id: article.id,
            title: article.title,
            lead: article.lead
        })))
);

const getArticle = (articleId) => (
    db
        .get('articles')
        .find({ id: articleId })
        .value()
);

const getCommentsForArticle = (articleId) => (
    db
        .get('comments')
        .filter({ articleId: articleId })
        .values()
);

server.get('/api/articles', (req, res) => {
    res.send(getArticles());
});

server.get('/api/article/:articleId', express.json(), (req, res) => {
    const articleId = req.params.articleId;
    if (!articleId) {
        res.status(404).send('Not found');
        return;
    }
    const article = getArticle(articleId);

    if (article) {
        res.send(article);
    } else {
        res.status(404).send('Not found');
    }
});

server.get('/api/article/:articleId/comments', express.json(), (req, res) => {
    const articleId = req.params.articleId;
    if (!articleId) {
        res.status(404).send('Not found');
        return;
    }
    const article = getArticle(articleId);

    if (article) {
        res.send(getCommentsForArticle(articleId)
            .map(toUnnested));
    } else {
        res.status(404).send('Not found');
    }
});

server.get('/api/article/:articleId/nestedComments', express.json(), (req, res) => {
    const articleId = req.params.articleId;
    if (!articleId) {
        res.status(404).send('Not found');
        return;
    }
    const article = getArticle(articleId);

    if (article) {
        res.send(toNested(getCommentsForArticle(articleId)));
    } else {
        res.status(404).send('Not found');
    }
});

server.all(['/api', '/api/*'], (req, res) => {
    res.status(404).send('Not found');
});

server.post('/log', express.json(), (req, res) => {
    console.log({
        ...req.body,
        level: 'Error'
    });
    res.sendStatus(200);
});

server.use(bundler.middleware());

const port = process.env.PORT || 8080;
server.listen(port, () => {
    console.log('Server listening on port', port);
});
