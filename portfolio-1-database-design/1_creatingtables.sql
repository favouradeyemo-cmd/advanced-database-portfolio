-- Creating 5 table names: authors, books, members, loans, fines

CREATE TABLE authors (
    author_id   SERIAL PRIMARY KEY,
    full_name   VARCHAR(100) NOT NULL,
    country     VARCHAR(50)
);

CREATE TABLE books (
    book_id          SERIAL PRIMARY KEY,
    title            VARCHAR(200) NOT NULL,
    isbn             VARCHAR(13)  NOT NULL UNIQUE,
    author_id        INT          NOT NULL REFERENCES authors(author_id),
    category         VARCHAR(50),
    published_year   INT CHECK (published_year BETWEEN 1500 AND 2100),
    total_copies     INT NOT NULL CHECK (total_copies >= 0),
    available_copies INT NOT NULL CHECK (available_copies >= 0),
    CHECK (available_copies <= total_copies) 
);

CREATE TABLE members (
    member_id   SERIAL PRIMARY KEY,
    full_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    phone       VARCHAR(15),
    join_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    status      VARCHAR(10) NOT NULL DEFAULT 'active'
                CHECK (status IN ('active', 'suspended'))
);


CREATE TABLE loans (
    loan_id      SERIAL PRIMARY KEY,
    book_id      INT  NOT NULL REFERENCES books(book_id),
    member_id    INT  NOT NULL REFERENCES members(member_id),
    borrow_date  DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date     DATE NOT NULL,
    return_date  DATE,                                  
    CHECK (due_date > borrow_date),
    CHECK (return_date IS NULL OR return_date >= borrow_date)
);

CREATE TABLE fines (
    fine_id      SERIAL PRIMARY KEY,
    loan_id      INT NOT NULL UNIQUE REFERENCES loans(loan_id),
    amount       NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    paid         BOOLEAN NOT NULL DEFAULT FALSE,
    issued_date  DATE NOT NULL DEFAULT CURRENT_DATE
);
