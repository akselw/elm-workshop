const express = require('express');
const Bundler = require('parcel-bundler');
const path = require('path');
const low = require('lowdb');
const FileSync = require('lowdb/adapters/FileSync');
const fs = require('fs');
const YAML = require('yaml');
const shortid = require('shortid');

const databaseExists = fs.existsSync(path.resolve(__dirname, 'db.json'));

const adapter = new FileSync('db.json');
const db = low(adapter);

const parseArticle = (text) => {
    const splitArticle = text.split('\n---\n');
    const metadata = YAML.parse(splitArticle[0]);
    const body = splitArticle[1];
    return {
        ...metadata,
        body: body
    };
};

const readArticles = (dirname) => {
    const filenames = fs.readdirSync(dirname);
    return filenames.map((filename) => {
        const file = fs.readFileSync(dirname + filename, 'utf-8');
        return parseArticle(file);
    });
};

db.defaults({ articles: [], comments: [] })
    .write();

const writeArticleToDB = (article, id) => {
    db.get('articles')
        .push({
            id: id,
            title: article.title,
            lead: article.lead || null,
            body: article.body
        })
        .write();
};

const writeArticlesToDB = (listOfArticles, firstArticleId) => {
    listOfArticles.forEach((article, index) => {
        if (index === 0) {
            writeArticleToDB(article, firstArticleId);
        } else {
            writeArticleToDB(article, shortid.generate());
        }
    });
};

if (!databaseExists) {
    console.log('[elm-workshop]: Creating database in db.json, and writing articles to it.');
    const articleId = shortid.generate();
    const firstCommentId = shortid.generate();
    const firstAnswerId = shortid.generate();
    const articles = readArticles('articles/');
    writeArticlesToDB(articles, articleId);
    db.get('comments')
        .push({
            id: firstCommentId,
            username: 'User 1',
            articleId: articleId,
            commentOnCommentWithId: null,
            text: 'Functional programming SUXXX!'
        })
        .push({
            id: firstAnswerId,
            username: 'User 2',
            articleId: articleId,
            commentOnCommentWithId: firstCommentId,
            text: 'No, you suck!!'
        })
        .push({
            id: shortid.generate(),
            username: 'User 3',
            articleId: articleId,
            commentOnCommentWithId: firstAnswerId,
            text: 'I like him!'
        })
        .push({
            id: shortid.generate(),
            username: 'User 4',
            articleId: articleId,
            commentOnCommentWithId: firstCommentId,
            text: 'I agree'
        })
        .push({
            id: shortid.generate(),
            username: 'User 5',
            articleId: articleId,
            commentOnCommentWithId: null,
            text: 'I like modifying global variables 😊'
        })
        .write();
    console.log(db.get('articles').value());
    console.log(db.get('comments').value());
} else {
    console.log('[elm-workshop]: Using existing database. Delete or rename db.json to start a database from scratch.');
}

const server = express();

const entryFile = path.join(__dirname, './src/index.html');
const bundler = new Bundler(entryFile, {});

const toUnnested = (comment) => {
    console.log({ comment });
    return ({
        id: comment.id,
        username: comment.username,
        text: comment.text
    });
};

const toNested = (comments) => {
    const topLevelComments = comments.filter((comment) => comment.commentOnCommentWithId === null);
    return topLevelComments.map((comment) => findSubcomments(comment, comments));

};

const findSubcomments = (comment, comments) => ({
    id: comment.id,
    username: comment.username,
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

const getComment = (articleId, commentId) => (
    db
        .get('comments')
        .filter({ articleId: articleId })
        .filter({ commentId : commentId })
        .value()
)

const createComment = (articleId, text, username, commentId) => {
    db.get('comments')
        .push({
            id: shortid.generate(),
            username: username || 'Guest user',
            articleId: articleId,
            commentOnCommentWithId: commentId || null,
            text: text
        })
        .write();
}

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

server.post('/api/article/:articleId/comments', express.json(), (req, res) => {
    const articleId = req.params.articleId;
    if (!articleId) {
        res.status(404).send('Not found');
        return;
    }
    const article = getArticle(articleId);

    if (article) {
        if (!req.body['text']) {
            res.status(400).send('Field "text" is required in body');
            return;
        }
        createComment(articleId, req.body['text'], req.body['username']);
        res.send(toNested(getCommentsForArticle(articleId)));

    } else {
        res.status(404).send('Not found');
    }
});


server.post('/api/article/:articleId/comments/:commentId/comments', express.json(), (req, res) => {
    const articleId = req.params.articleId;
    const commentId = req.params.commentId;
    if (!articleId || !commentId) {
        res.status(404).send('Not found');
        return;
    }
    const article = getArticle(articleId);
    const comment = getComment(articleId, commentId);

    if (article && comment) {
        if (!req.body['text']) {
            res.status(400).send('Field "text" is required in body');
            return;
        }
        createComment(articleId, req.body['text'], req.body['username'], commentId);
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
