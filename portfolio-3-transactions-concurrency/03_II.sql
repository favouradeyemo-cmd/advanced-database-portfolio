
-- ===== PART 1: THE PROBLEM (no lock) – "lost update" =====

-- STEP 1 (A): start, and read how many copies are left
BEGIN;
SELECT available_copies FROM books WHERE isbn = '9789999999999';


UPDATE books SET available_copies = 0 WHERE isbn = '9789999999999';
INSERT INTO loans (book_id, member_id, borrow_date, due_date)
VALUES ((SELECT book_id   FROM books   WHERE isbn  = '9789999999999'),
        (SELECT member_id FROM members WHERE email = 'adaeze@example.com'),
        CURRENT_DATE, CURRENT_DATE + 14);
COMMIT;


SELECT b.title, b.total_copies, b.available_copies, COUNT(l.loan_id) AS loans_recorded
FROM books b
LEFT JOIN loans l ON l.book_id = b.book_id
WHERE b.isbn = '9789999999999'
GROUP BY b.title, b.total_copies, b.available_copies;

BEGIN;
SELECT available_copies FROM books WHERE isbn = '9789999999999' FOR UPDATE;

UPDATE books SET available_copies = available_copies - 1 WHERE isbn = '9789999999999';
INSERT INTO loans (book_id, member_id, borrow_date, due_date)
VALUES ((SELECT book_id   FROM books   WHERE isbn  = '9789999999999'),
        (SELECT member_id FROM members WHERE email = 'adaeze@example.com'),
        CURRENT_DATE, CURRENT_DATE + 14);
COMMIT;

SELECT b.title, b.total_copies, b.available_copies, COUNT(l.loan_id) AS loans_recorded
FROM books b
LEFT JOIN loans l ON l.book_id = b.book_id
WHERE b.isbn = '9789999999999'
GROUP BY b.title, b.total_copies, b.available_copies;

-- q3-b

-- ===== PART 1: THE PROBLEM (no lock) – "lost update" =====

-- STEP 2 (B): at the same moment, the Kano librarian checks the same book
BEGIN;
SELECT available_copies FROM books WHERE isbn = '9789999999999';

UPDATE books SET available_copies = 0 WHERE isbn = '9789999999999';
INSERT INTO loans (book_id, member_id, borrow_date, due_date)
VALUES ((SELECT book_id   FROM books   WHERE isbn  = '9789999999999'),
        (SELECT member_id FROM members WHERE email = 'tunde@example.com'),
        CURRENT_DATE, CURRENT_DATE + 14);
COMMIT;


BEGIN;
SELECT available_copies FROM books WHERE isbn = '9789999999999' FOR UPDATE;

ROLLBACK;

SELECT borrow_book('9789999999999', 'adaeze@example.com');  
SELECT borrow_book('9789999999999', 'tunde@example.com'); 