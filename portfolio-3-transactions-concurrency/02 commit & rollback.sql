-- ---------- DEMO 1: COMMIT (changes are saved) ----------
-- Adaeze borrows "Things Fall Apart".

BEGIN;
    UPDATE books
    SET available_copies = available_copies - 1
    WHERE isbn = '9780385474542';                                   

    INSERT INTO loans (book_id, member_id, borrow_date, due_date)
    VALUES ((SELECT book_id   FROM books   WHERE isbn  = '9780385474542'),
            (SELECT member_id FROM members WHERE email = 'adaeze@example.com'),
            CURRENT_DATE, CURRENT_DATE + 14);
COMMIT;

-- Check: copies went down by 1 and the new loan exists
SELECT b.title, b.available_copies, m.full_name, l.borrow_date
FROM loans l
JOIN books b   ON b.book_id = l.book_id
JOIN members m ON m.member_id = l.member_id
WHERE b.isbn = '9780385474542'
ORDER BY l.loan_id DESC
LIMIT 1;


-- ---------- DEMO 2: ROLLBACK (changes are cancelled) ----------
-- The librarian starts lending "Arrow of God", then the member changes
-- their mind. ROLLBACK cancels everything done since BEGIN.

-- 2A. Before: note the available copies
SELECT title, available_copies FROM books WHERE isbn = '9780385014809';

-- 2B. Start the change, then cancel it
BEGIN;
    UPDATE books
    SET available_copies = available_copies - 1
    WHERE isbn = '9780385014809';                                   

   
    SELECT title, available_copies AS during_transaction
    FROM books WHERE isbn = '9780385014809';
ROLLBACK;

-- 2C. After: available copies are back to the original number
SELECT title, available_copies AS after_rollback
FROM books WHERE isbn = '9780385014809';

-- ---------- DEMO 3: AUTOMATIC ROLLBACK ON ERROR
-- Someone tries to borrow "The Last Copy" using an email that is NOT a member.

-- 3A. Before
SELECT title, available_copies FROM books WHERE isbn = '9789999999999'; 

-- 3B. The failing borrow
SELECT borrow_book('9789999999999', 'not.a.member@example.com');

-- 3C. After: still 1. The copy was put back automatically,
-- because the whole function is one transaction.
SELECT title, available_copies FROM books WHERE isbn = '9789999999999';