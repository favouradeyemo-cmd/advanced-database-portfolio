Portfolio 1: Database Design and Modelling
Case study: CityReads Library Management System

CityReads is a public library that lends books to registered members.

Users of the database: librarians (lend and receive books), admin staff (register members, add books, manage fines) and members (search the catalogue, view their loans).
Main data stored: authors, books, members, loans and fines.
Key operations: register members, add books, borrow a book, return a book, charge a late fine, search the catalogue.

Files in this folder
1_creatingtables.sql
2_inputting data into the tables.sql
diagram.png	The db diagram image
screenshots - Proof that the scripts ran

Entities and relationships
Relationship	  Type	       Meaning
Author → Books	One-to-many	  One author can write many books
Book → Loans	One-to-many	  One book can be borrowed many times
Member → Loans	One-to-many	  One member can have many loans
Loan → Fine	    One-to-one 	  A loan gets at most one fine, only if returned late

Keys
Primary keys (unique ID for each row): author_id, book_id, member_id, loan_id, fine_id.
Foreign keys (links between tables):
books.author_id → authors
loans.book_id → books
loans.member_id → members
fines.loan_id → loans


Test: I tried to insert a book with 5 available copies but only 1 total copy. PostgreSQL rejected it with violates check constraint "books_check". 
