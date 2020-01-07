---
title: "Let's Code: An ORM Query Builder"
date: 2020-01-07T13:00:00+01:00
---

_In this guide we will be building a toy ORM Query builder in Python_

# What is an ORM?

The majority of modern software engineering projects suffer a common problem
that results from using two popular technologies: object-oriented programming
languages and relational databases. This problem is called the
**object-relational impedance mismatch**.

That's quite the mouthful, but the idea is actually quite straightforward: we
want to be able to store the state of entities represented in our
object-oriented programs in relational databases but the way that these
technologies represent these entities is not similar enough to automatically
translate between the two.

This will become clearer if we look at an example. Imagine we are creating a
blogging engine and we want to represent a blog post and all its comments. In an
object-oriented programming language we might represent these entites with the
following classes:

```python
class User:
    def __init__(self, id, username):
        self.id = id
        self.username = username

class Post:
    def __init__(self, id, posted_at, author, title, content, comments):
        self.id = id
        self.posted_at = posted_at
        self.author = author
        self.title = title
        self.content = content
        self.comments = comments

class Comment:
    def __init__(self, id, posted_at, author, content):
        self.id = id
        self.posted_at = posted_at
        self.author = author
        self.content = content
```

This would allow us to represent data in the blog as follows:

```python
alice = User(id=0, username='alice')
bob = User(id=1, username='bob')

comment_1 = Comment(
    id=0,
    posted_at=datetime(2020, 1, 1),
    author=bob,
    content='First!',
)
comment_2 = Comment(
    id=0,
    posted_at=datetime(2020, 1, 2),
    author=bob,
    content='Second!',
)

blog_post = Post(
    id=0,
    posted_at=datetime(2020, 1, 1),
    author=alice,
    title='My first blog post',
    content='Here\'s my first blog post - hope you like it!',
    comments = [comment_1, comment_2],
)
```

If we wanted to store the same data in a relational database we would have to
set up the following schema (in this example, we are using
[sqlite](https://www.sqlite.org/index.html)):

```sql
CREATE TABLE user (
    id INTEGER PRIMARY KEY,
    username TEXT NOT NULL
);

CREATE TABLE post (
    id INTEGER PRIMARY KEY,
    posted_at TEXT NOT NULL,
    author_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,

    FOREIGN KEY(author_id) REFERENCES user(id)
);

CREATE TABLE comment (
    id INTEGER PRIMARY KEY,
    post_id INTEGER NOT NULL,
    posted_at TEXT NOT NULL,
    author_id INTEGER NOT NULL,
    content TEXT NOT NULL,

    FOREIGN KEY(post_id) REFERENCES post(id),
    FOREIGN KEY(author_id) REFERENCES user(id)
);
```

This would allow us to store data as follows:

```sql
INSERT INTO user VALUES (0, 'alice');
INSERT INTO user VALUES (1, 'bob');

INSERT INTO post VALUES (0, '2020-01-01', 0, 'My first blog post', 'Here''s my first blog post - hope you like it!');

INSERT INTO comment VALUES(0, 0, '2020-01-01', 1, 'First!');
INSERT INTO comment VALUES(1, 0, '2020-01-02', 1, 'Second!');
```

If you take a look at the examples above you will notice that our entites are represented slightly differently. For example, the blog post class holds a reference to all its comments but records in the blog post table are referenced by records in the comments table.

If we want to be able to store our Python blog post objects in our database we would need to:

- Write and apply the table schema for each object type
- Modify the fields and relationships so that they can be modelled by relations (such as inverting the post/comment relationship)
- Write SQL queries to create/read/update/delete objects as they change in our program
- Translate between incompatible data types (for example, our python class uses a Datetime object for the `posted_at` field but sqlite uses a specially formatted string)
- And much more besides!

Worst of all, larger applications will have a wide variety of entities they need to represent and **we will have to do this work for each entity in our application**.

What if we could write a program to automatically create a mapping between the object-oriented and relational representation of the entities in our program? This is an **Object Relational Mapper** (**ORM**)).
