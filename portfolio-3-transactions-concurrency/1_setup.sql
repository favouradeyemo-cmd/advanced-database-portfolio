DELETE FROM fines WHERE loan_id IN
    (SELECT loan_id FROM loans WHERE book_id IN (SELECT book_id FROM books WHERE isbn = '9789999999999'));
DELETE FROM loans WHERE book_id IN (SELECT book_id FROM books WHERE isbn = '9789999999999');
DELETE FROM books WHERE isbn = '9789999999999';

-- The demo book: 1 copy in total, 1 available
INSERT INTO books (title, isbn, author_id, category, published_year, total_copies, available_copies)
VALUES ('The Last Copy', '9789999999999',
        (SELECT author_id FROM authors WHERE full_name = 'Chinua Achebe'),
        'Fiction', 2026, 1, 1);

CREATE OR REPLACE FUNCTION borrow_book(p_isbn TEXT, p_email TEXT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_book_id   INT;
    v_available INT;
    v_member_id INT;
BEGIN
    -- Step 1: find the book and LOCK its row (FOR UPDATE),
    -- so nobody else can change it until we finish
    SELECT book_id, available_copies INTO v_book_id, v_available
    FROM books WHERE isbn = p_isbn
    FOR UPDATE;

    IF v_book_id IS NULL THEN
        RAISE EXCEPTION 'Book with ISBN % not found', p_isbn;
    END IF;
    IF v_available = 0 THEN
        RAISE EXCEPTION 'Sorry, no copies of this book are available';
    END IF;

    -- Step 2: take one copy off the shelf
    UPDATE books SET available_copies = available_copies - 1
    WHERE book_id = v_book_id;

    -- Step 3: record the loan (fails if the member does not exist)
    SELECT member_id INTO v_member_id FROM members WHERE email = p_email;
    INSERT INTO loans (book_id, member_id, borrow_date, due_date)
    VALUES (v_book_id, v_member_id, CURRENT_DATE, CURRENT_DATE + 14);

    RETURN 'Book borrowed successfully';
END;
$$;

SELECT title, isbn, total_copies, available_copies FROM books WHERE isbn = '9789999999999';