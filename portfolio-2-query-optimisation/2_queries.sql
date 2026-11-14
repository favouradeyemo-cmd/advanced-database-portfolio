-- Q1. Which books does member 123 currently have? (librarian at the desk)
SELECT b.title, l.borrow_date, l.due_date
FROM loans l
JOIN books b ON b.book_id = l.book_id
WHERE l.member_id = 123
  AND l.return_date IS NULL;

-- Q2. Overdue books: not returned and past the due date (daily reminder list)
SELECT m.full_name, m.phone, b.title, l.due_date,
       CURRENT_DATE - l.due_date AS days_overdue
FROM loans l
JOIN members m ON m.member_id = l.member_id
JOIN books b   ON b.book_id   = l.book_id
WHERE l.return_date IS NULL
  AND l.due_date < CURRENT_DATE
ORDER BY days_overdue DESC
LIMIT 20;

-- Q3. Top 10 most borrowed books (helps decide which books to buy more copies of)
SELECT b.title, a.full_name AS author, COUNT(*) AS times_borrowed
FROM loans l
JOIN books b   ON b.book_id   = l.book_id
JOIN authors a ON a.author_id = b.author_id
GROUP BY b.title, a.full_name
ORDER BY times_borrowed DESC
LIMIT 10;

-- Q4. Members who owe the most in unpaid fines
SELECT m.full_name, m.email, SUM(f.amount) AS total_unpaid
FROM fines f
JOIN loans l   ON l.loan_id   = f.loan_id
JOIN members m ON m.member_id = l.member_id
WHERE f.paid = FALSE
GROUP BY m.full_name, m.email
ORDER BY total_unpaid DESC
LIMIT 10;

-- Q5. Catalogue search: books with "Fall" in the title, with copies available
SELECT b.title, a.full_name AS author, b.category, b.available_copies
FROM books b
JOIN authors a ON a.author_id = b.author_id
WHERE b.title ILIKE '%fall%'
  AND b.available_copies > 0;

-- Q6. Number of loans per month in 2025
SELECT TO_CHAR(borrow_date, 'YYYY-MM') AS month, COUNT(*) AS loans
FROM loans
WHERE borrow_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY month
ORDER BY month;