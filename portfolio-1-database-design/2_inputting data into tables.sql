-- Inserting Data into the TABLE

INSERT INTO authors (full_name, country) VALUES
('Chinua Achebe', 'Nigeria'),
('Chimamanda Ngozi Adichie', 'Nigeria'),
('Wole Soyinka', 'Nigeria'),
('Abraham Silberschatz', 'USA');

INSERT INTO books (title, isbn, author_id, category, published_year, total_copies, available_copies) VALUES
('Things Fall Apart',          '9780385474542', 1, 'Fiction',  1958, 5, 4),
('Arrow of God',               '9780385014809', 1, 'Fiction',  1964, 3, 3),
('Half of a Yellow Sun',       '9781400095209', 2, 'Fiction',  2006, 4, 3),
('Purple Hibiscus',            '9781616202415', 2, 'Fiction',  2003, 2, 2),
('The Lion and the Jewel',     '9780192110664', 3, 'Drama',    1963, 2, 2),
('Database System Concepts',   '9780078022159', 4, 'Textbook', 2019, 3, 2);

INSERT INTO members (full_name, email, phone, join_date) VALUES
('Adaeze Okafor',  'adaeze@example.com',  '08031234567', '2026-01-10'),
('Tunde Bakare',   'tunde@example.com',   '08029876543', '2026-02-15'),
('Fatima Bello',   'fatima@example.com',  '07061112233', '2026-03-01'),
('Emeka Obi',      'emeka@example.com',   '09034445566', '2026-04-20');


INSERT INTO loans (book_id, member_id, borrow_date, due_date, return_date) VALUES
(1, 1, '2026-10-01', '2026-10-15', '2026-10-14'),   -- returned on time
(3, 2, '2026-10-05', '2026-10-19', '2026-10-25'),   -- returned 6 days late
(1, 3, '2026-11-01', '2026-11-15', NULL),           -- still borrowed
(3, 4, '2026-11-03', '2026-11-17', NULL),           -- still borrowed
(6, 1, '2026-11-05', '2026-11-19', NULL);           -- still borrowed


INSERT INTO fines (loan_id, amount, paid, issued_date) VALUES
(2, 600.00, FALSE, '2026-10-25');

INSERT INTO books(title,isbn,author_id,total_copies,available_copies) VALUES ('Test','123',1,1,5);