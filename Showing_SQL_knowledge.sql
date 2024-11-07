-- BLOCK START: CREATING TABLES

CREATE TABLE Books (
	book_id INT PRIMARY KEY UNIQUE,
    title VARCHAR(50),
    author_id INT,
    genre VARCHAR(50),
    publication_year YEAR,
    copies_available INT,
    CONSTRAINT authot_id_fk FOREIGN KEY (author_id) REFERENCES Authors (author_id)
    
);

CREATE TABLE Authors (
	author_id INT PRIMARY KEY UNIQUE,
    a_name VARCHAR(50),
    nationality VARCHAR(30)
    
);

CREATE TABLE Members (
	member_id INT PRIMARY KEY UNIQUE,
    m_name VARCHAR(50),
    membership_date_joined DATE,
    contact_number VARCHAR(50),
    email VARCHAR(50) 
    
);

CREATE TABLE Borrowings (
	borrowing_id INT PRIMARY KEY UNIQUE,
	book_id INT, 
	member_id INT, 
	borrow_date DATE,
	return_date DATE,
    CONSTRAINT book_id_fk FOREIGN KEY (book_id) REFERENCES Books (book_id),
    CONSTRAINT member_id_fk FOREIGN KEY (member_id) REFERENCES Members (member_id)
    
);

CREATE TABLE Book_categories (
	category_id INT PRIMARY KEY UNIQUE,
	category_name VARCHAR(30)
    
);

CREATE TABLE Staff (
	staff_id INT PRIMARY KEY UNIQUE,
	s_name VARCHAR(50),
	role VARCHAR(50),
	employment_date DATE
    
);

-- BLOCK END: CREATING TABLES

-- BLOCK START: ADDING VALUES

INSERT INTO books
VALUES  (1, "To Kill a Mockingbird", 1, 'Fiction', 1960, 3),
		(2, "1984", 2, 'Dystopian', 1949, 4),
		(3, "Pride and Prejudice", 3, 'Romance', 1913, 5),
		(4, "The Great Gatsby", 4, 'Fiction', 1925, 2),
		(5, "Moby Dick", 5, 'Adventure', 1951, 2),
		(6, "War and Peace", 6, 'Historical', 1969, 1);

INSERT INTO authors
VALUES  (1,	'Harper Lee', 'American'),
		(2,	'George Orwell', 'British'),
		(3,	'Jane Austen', 'British'),
		(4,	'F. Scott Fitzgerald', 'American'),
		(5,	'Herman Melville', 'American'),
		(6,	'Leo Tolstoy', 'Russian');

INSERT INTO members
VALUES  (1, 'Alice Johnson', '2023-01-15', 1234567890, 'alice.j@example.com'),
		(2, 'Bob Smith', '2023-03-22', 0987654321, 'bob.smith@example.com'),
		(3, 'Carol White', '2023-05-10', 5551234567, 'carol.w@example.com'),
		(4, 'Dave Black', '2023-07-08', 5557654321, 'dave.b@example.com'),
		(5, 'Eve Brown', '2023-09-17', 1235556789, 'eve.b@example.com');

INSERT INTO borrowings
VALUES  (1, 1, 2, '2024-01-10', '2024-01-20'),
		(2, 3, 1, '2024-02-05', NULL),
		(3, 4, 3, '2024-02-18', '2024-02-28'),
		(4, 2, 5, '2024-03-01', '2024-03-11'),
		(5, 5, 4, '2024-04-05', NULL);       
        
INSERT INTO book_categories
VALUES  (1, 'Fiction'),
		(2, 'Dystopian'),
		(3, 'Romance'),
		(4, 'Adventure'),
		(5, 'Historical');          
        
INSERT INTO staff
VALUES  (1, 'Sarah Green', 'Librarian', '2022-08-12'),
		(2, 'John Blue', 'Assistant', '2023-01-09'),
		(3, 'Emma Gray', 'Librarian', '2023-11-04');             

-- BLOCK END: ADDING VALUES      

-- BLOCK START: QUERIES
 
-- 1. Here we will list all the books by the author - F. Scott Fitzgerald
SELECT bks.title AS 'Books title', bks.author_id, bks.genre AS 'Genre', 
a.a_name AS 'Authors name', a.nationality AS 'Authors Nationality'
FROM books AS bks
INNER JOIN authors AS a ON a.author_id = bks.author_id
WHERE bks.author_id = 4
ORDER BY bks.publication_year ASC;
    
-- 2. Here we will get the total amount of borrowed books by each member.
SELECT m.member_id, m.m_name AS 'Members name', m.contact_number AS 'Members contact number', 
m.email AS 'Members email', COUNT(b.borrowing_id) AS 'Books borrowed'
FROM members AS m
INNER JOIN borrowings AS b ON b.member_id = m.member_id
GROUP BY m.member_id, m.m_name, m.contact_number, m.email;

-- 3. Here we will find all books currently borrowed with the borrowing date.
SELECT bor.borrowing_id AS 'Borrowing ID', bor.book_id AS 'Book ID', bor.borrow_date AS 'Got borrowed', 
bks.title AS 'Title', bks.genre as 'Genre'
FROM borrowings AS bor
INNER JOIN books AS bks ON bks.book_id = bor.book_id
WHERE bor.return_date IS NULL
GROUP BY bor.borrowing_id, bor.book_id, bor.borrow_date, bks.title, bks.genre
ORDER BY bor.borrow_date ASC;


-- 4. Here we will create a triger to update info on borrowed/returned books.

DELIMITER //

CREATE TRIGGER bor_ret_books
BEFORE UPDATE ON borrowings
FOR EACH ROW
BEGIN
    -- If a book is being borrowed (new borrow date added), decrease copies
    IF OLD.borrow_date IS NULL AND NEW.borrow_date IS NOT NULL THEN
        UPDATE books
        SET copies_available = copies_available - 1
        WHERE book_id = NEW.book_id;
    
    -- If a book is being returned (new return date added), increase copies
    ELSEIF OLD.return_date IS NULL AND NEW.return_date IS NOT NULL THEN
        UPDATE books
        SET copies_available = copies_available + 1
        WHERE book_id = NEW.book_id;
    END IF;
END//

DELIMITER ;

-- BLOCK END: QUERIES
