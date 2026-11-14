-- exp 1: a member's loans (Q1)

-- 1A. BEFORE: no index on loans.member_id
DROP INDEX IF EXISTS idx_loans_member_id;
EXPLAIN ANALYZE
SELECT b.title, l.borrow_date, l.due_date
FROM loans l
JOIN books b ON b.book_id = l.book_id
WHERE l.member_id = 123
  AND l.return_date IS NULL;

-- 2. Creating the index
CREATE INDEX idx_loans_member_id ON loans (member_id);
ANALYZE loans;

-- same query again
EXPLAIN ANALYZE
SELECT b.title, l.borrow_date, l.due_date
FROM loans l
JOIN books b ON b.book_id = l.book_id
WHERE l.member_id = 123
  AND l.return_date IS NULL;

-- EXPERIMENT 2: loan history of one book

--  BEFORE: no index on loans.book_id
DROP INDEX IF EXISTS idx_loans_book_id;
EXPLAIN ANALYZE
SELECT l.loan_id, l.member_id, l.borrow_date, l.return_date
FROM loans l
WHERE l.book_id = 42
ORDER BY l.borrow_date DESC;

-- Creating the index
CREATE INDEX idx_loans_book_id ON loans (book_id);
ANALYZE loans;

-- AFTER
EXPLAIN ANALYZE
SELECT l.loan_id, l.member_id, l.borrow_date, l.return_date
FROM loans l
WHERE l.book_id = 42
ORDER BY l.borrow_date DESC;

-- cost of indexing
SELECT indexrelname AS index_name,
       pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE relname = 'loans';