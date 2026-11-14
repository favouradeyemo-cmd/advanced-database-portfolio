
-- 500 extra authors (total = 504)
INSERT INTO authors (full_name, country)
SELECT 'Author ' || g,
       (ARRAY['Nigeria','Ghana','Kenya','UK','USA'])[1 + (g % 5)]
FROM generate_series(1, 500) AS g;

-- 5,000 extra books (total = 5,006)
INSERT INTO books (title, isbn, author_id, category, published_year, total_copies, available_copies)
SELECT 'Book Title ' || g,
       (9780000000000 + g)::text,                                    
       a.ids[1 + (g % array_length(a.ids, 1))],                      
       (ARRAY['Fiction','Drama','Textbook','History','Science','Poetry'])[1 + (g % 6)],
       1950 + (g % 76),
       5, 5
FROM generate_series(1, 5000) AS g
CROSS JOIN (SELECT array_agg(author_id ORDER BY author_id) AS ids FROM authors) AS a;

-- 20,000 extra members (total = 20,004)
INSERT INTO members (full_name, email, phone, join_date)
SELECT 'Member ' || g,
       'member' || g || '@example.com',
       '080' || lpad(g::text, 8, '0'),
       DATE '2024-01-01' + (g % 900)
FROM generate_series(1, 20000) AS g;

-- 500,000 loans spread over 2024-2026
INSERT INTO loans (book_id, member_id, borrow_date, due_date, return_date)
SELECT book_id, member_id, borrow_date, borrow_date + 14,
       CASE WHEN r < 0.9 THEN borrow_date + (1 + floor(random() * 30))::int END
FROM (
    SELECT b.ids[1 + floor(random() * array_length(b.ids, 1))::int] AS book_id,
           m.ids[1 + floor(random() * array_length(m.ids, 1))::int] AS member_id,
           DATE '2024-01-01' + floor(random() * 1000)::int AS borrow_date,
           random() AS r
    FROM generate_series(1, 500000)
    CROSS JOIN (SELECT array_agg(book_id)   AS ids FROM books)   AS b
    CROSS JOIN (SELECT array_agg(member_id) AS ids FROM members) AS m
) AS s;

-- Fines for every late return
INSERT INTO fines (loan_id, amount, paid, issued_date)
SELECT loan_id, (return_date - due_date) * 100, random() < 0.5, return_date
FROM loans
WHERE return_date > due_date
  AND loan_id NOT IN (SELECT loan_id FROM fines);


-- Check the row counts
SELECT 'authors' AS table_name, COUNT(*) FROM authors
UNION ALL SELECT 'books',   COUNT(*) FROM books
UNION ALL SELECT 'members', COUNT(*) FROM members
UNION ALL SELECT 'loans',   COUNT(*) FROM loans
UNION ALL SELECT 'fines',   COUNT(*) FROM fines;
