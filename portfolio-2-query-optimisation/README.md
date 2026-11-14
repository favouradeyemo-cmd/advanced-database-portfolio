# Portfolio 2: Query Processing and Optimisation

Goal is to Write useful queries for the CityReads Library, then show how an index makes slow queries faster, using execution plans (EXPLAIN ANALYZE) as evidence.


With only a handful of rows, every query is instant and an index makes no visible difference. Real libraries hold years of loan records, so I generated 500,000 loans across 2024–2026 to test performance under realistic load.

The six queries
Query	Business purpose	         SQL features used
Q1 – a member's current loans	                 Librarian checks what a member has before lending more	JOIN, WHERE, IS NULL
Q2 – overdue books	                             Daily reminder list for staff	3-table JOIN, date arithmetic, ORDER BY, LIMIT
Q3 – top 10 most borrowed books	                 Decide which titles need more copies	GROUP BY, COUNT, ORDER BY
Q4 – members with the most unpaid fines	         Follow up on debts	SUM, GROUP BY, filter on boolean
Q5 – catalogue search	                         Members search for available books by title	ILIKE pattern search
Q6 – loans per month in 2025	                Spot busy and quiet months for staffing	Date formatting, GROUP BY


Indexing experiment
What is an index?

An index works like the index at the back of a textbook. Without it, the database reads every row in the table to find what it needs (a Sequential Scan). With it, the database jumps straight to the matching rows (an Index Scan).

Key finding: PostgreSQL automatically indexes primary keys, but not foreign keys. So loans.member_id and loans.book_id had no index, even though the library looks loans up by member and by book all the time.


Indexes are not free:

Storage: each index took about 3.5 MB of disk space (see the index-size query in 03_index_experiment.sql).
Slower writes: every new loan must also update both indexes, so inserting rows is slightly slower.
Decision: the library reads loans far more often than it adds them, so the faster reads are worth the small cost. I did not index columns that are rarely searched.