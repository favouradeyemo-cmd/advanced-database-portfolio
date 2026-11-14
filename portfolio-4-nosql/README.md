# Portfolio 4: NoSQL and Advanced Data Models

## Goal
Model part of the CityReads Library in a **NoSQL** database (MongoDB), show it working, and explain when NoSQL is a better fit than SQL and when it isn't.

## What I moved to NoSQL, and why
I moved the **book catalogue**: the information members browse and search.

The catalogue is a poor fit for fixed SQL tables, because **different types of books have different details**:

| Item type | Details only this type has |
|---|---|
| Novel | genre, themes, awards |
| Textbook | edition, subject, level, topics |
| Drama | number of acts, characters |
| E-book | file size, digital licences (instead of copies) |
| Audiobook | narrator, duration |

In PostgreSQL, the `books` table would need a column for every one of these details. Most of them would be empty (NULL) for most books, and adding a new item type (e.g. magazines) would mean changing the table structure. In MongoDB, each book is a **document** that holds only the fields it needs, and new types can be added at any time.

I kept **loans and fines in PostgreSQL**. They need strict transactions and locking (see Portfolio 3) and fixed rules (constraints). Using two different databases, each for the job it does best, is called **polyglot persistence**.


## The data model
**Database:** `cityreads` · **Collection:** `catalogue` · **Type:** document store (MongoDB)

Example document (a textbook):
```json
{
  "isbn": "9780078022159",
  "title": "Database System Concepts",
  "category": "Textbook",
  "format": "print",
  "published_year": 2019,
  "author": { "name": "Abraham Silberschatz", "country": "USA" },
  "edition": 7,
  "subject": "Computer Science",
  "level": "Postgraduate",
  "topics": ["SQL", "transactions", "indexing", "NoSQL"],
  "copies": { "total": 3, "available": 1 },
  "reviews": [
    { "member": "Emeka Obi", "rating": 4, "comment": "Dense but complete." }
  ]
}




