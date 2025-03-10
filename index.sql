use DB_ASSIGNMENT

-- Drop tables in order to avoid foreign key dependency issues:
DROP TABLE IF EXISTS Borrow;
DROP TABLE IF EXISTS Edition;
DROP TABLE IF EXISTS BookAuthor;
DROP TABLE IF EXISTS Book;
DROP TABLE IF EXISTS Author;
DROP TABLE IF EXISTS BookType;
DROP TABLE IF EXISTS Reader;

-- 1. BookType Table
--    Stores different book types (historical, political, economic, etc.)
CREATE TABLE BookType (
    type_code INT PRIMARY KEY,    
    type_name VARCHAR(100) NOT NULL
);

-- 2. Author Table
--    Stores information about authors
CREATE TABLE Author (
    author_code INT PRIMARY KEY,     
    author_name VARCHAR(200) NOT NULL,
    year_of_birth INT                 
);

-- 3. Book Table
--    Stores general information about each book
CREATE TABLE Book (
    book_id INT PRIMARY KEY,          -- Could be IDENTITY
    type_code INT NOT NULL,           -- FK referencing BookType
    title NVARCHAR(300) NOT NULL,

    CONSTRAINT FK_Book_BookType 
        FOREIGN KEY (type_code) 
        REFERENCES BookType(type_code)
);

CREATE TABLE BookAuthor (
    book_id INT NOT NULL,
    author_code INT NOT NULL,

    CONSTRAINT PK_BookAuthor
        PRIMARY KEY (book_id, author_code),

    CONSTRAINT FK_BookAuthor_Book
        FOREIGN KEY (book_id) 
        REFERENCES Book(book_id),

    CONSTRAINT FK_BookAuthor_Author
        FOREIGN KEY (author_code) 
        REFERENCES Author(author_code)
);

-- 5. Edition Table
--    Each book can have multiple editions (1st, 2nd, 3rd, ...)
CREATE TABLE Edition (
    book_id INT NOT NULL,
    edition_number INT NOT NULL,      
    edition_year INT NOT NULL,       
    paper_size VARCHAR(50),           
    number_of_pages INT,
    publisher VARCHAR(200),
    price DECIMAL(10,2),
    with_cd BIT,                      -- 1 = with CD, 0 = without CD

    -- Composite primary key:
    CONSTRAINT PK_Edition
        PRIMARY KEY (book_id, edition_number),

    CONSTRAINT FK_Edition_Book
        FOREIGN KEY (book_id) 
        REFERENCES Book(book_id)
);

-- 6. Reader Table
--    Stores information about each library reader

CREATE TABLE Reader (
    card_number INT PRIMARY KEY,      
    date_of_issue DATE,
    reader_name NVARCHAR(200),
    occupation VARCHAR(100),
    gender CHAR(1) CHECK (gender IN ('M', 'F'))                     
);

-- 7. Borrow Table
--    Implements the many-to-many relationship between Readers and Books
--   Also stores date of borrowing and date of return

CREATE TABLE Borrow (
    book_id INT NOT NULL,
    card_number INT NOT NULL,
    date_of_borrowing DATE NOT NULL,
    date_of_return DATE NULL,

    CONSTRAINT PK_Borrow
        PRIMARY KEY (book_id, card_number, date_of_borrowing),

    CONSTRAINT FK_Borrow_Book
        FOREIGN KEY (book_id) 
        REFERENCES Book(book_id),

    CONSTRAINT FK_Borrow_Reader
        FOREIGN KEY (card_number) 
        REFERENCES Reader(card_number)
);



----------------------------------------------------------------------------------------------------
--                                          Insert Value                                        --
----------------------------------------------------------------------------------------------------

-- Insert data into BookType
INSERT INTO BookType (type_code, type_name)
VALUES 
    (1, 'Historical'),
    (2, 'Political'),
    (3, 'Economic'),
    (4, 'Literary'),
    (5, 'Technical');
GO

-- Insert data into Author
INSERT INTO Author (author_code, author_name, year_of_birth)
VALUES 
    (101, 'George Orwell', 1903),
    (102, 'Jane Austen', 1775),
    (103, 'Karl Marx', 1818),
    (104, 'William Shakespeare', 1564),
    (105, 'Isaac Newton', 1643);
GO

-- Insert data into Book
INSERT INTO Book (book_id, type_code, title)
VALUES 
    (1001, 4, '1984'),
    (1002, 4, 'Pride and Prejudice'),
    (1003, 2, 'The Communist Manifesto'),
    (1004, 4, 'Hamlet'),
    (1005, 5, 'Principia Mathematica'),
	(1006, 4, 'Romeo and Juliet');
GO

-- Insert data into BookAuthor (Many-to-Many)
INSERT INTO BookAuthor (book_id, author_code)
VALUES 
    (1001, 101), -- 1984 by George Orwell
    (1002, 102), -- Pride and Prejudice by Jane Austen
    (1003, 103), -- The Communist Manifesto by Karl Marx
    (1004, 104), -- Hamlet by William Shakespeare
    (1005, 105), -- Principia Mathematica by Isaac Newton
	(1006, 104); -- Romeo and Juliet by William Shakespeare
GO

-- Insert data into Edition
INSERT INTO Edition (book_id, edition_number, edition_year, paper_size, number_of_pages, publisher, price, with_cd)
VALUES 
    (1001, 1, 1949, 'A5', 328, 'Secker & Warburg', 15.99, 0),
    (1002, 1, 1813, 'B5', 432, 'T. Egerton', 12.50, 0),
    (1003, 1, 1848, 'A4', 56, 'Penguin Classics', 8.99, 0),
    (1004, 1, 1603, 'B5', 200, 'Globe Theatre', 18.00, 0),
    (1005, 1, 1687, 'A4', 512, 'Cambridge University Press', 25.00, 1),
	(1006, 1, 1597, 'B5', 280, 'First Folio', 19.99, 0),
    (1006, 2, 1601, 'B5', 285, 'First Folio Revised', 20.99, 0);
GO
-- Insert data into Reader
INSERT INTO Reader (card_number, date_of_issue, reader_name, occupation, gender)
VALUES 
    (2001, '2024-01-15', N'Nguyễn Văn A', 'Student', 'M'),
    (2002, '2024-02-20', N'Trần Văn B', 'Engineer', 'M'),
    (2003, '2024-03-10', N'Lê Thị C', 'Teacher', 'F'),
    (2004, '2024-04-05', N'Hoàng Văn D', 'Doctor', 'M'),
    (2005, '2024-05-22', N'Nguyễn Ngọc E', 'Librarian', 'F');
GO

-- Insert data into Borrow (Books borrowed by readers)
INSERT INTO Borrow (book_id, card_number, date_of_borrowing, date_of_return)
VALUES 
    (1001, 2001, '2025-02-01', '2025-02-15'),  
    (1002, 2002, '2025-02-05', '2025-02-20'), 
    (1003, 2003, '2025-02-07', NULL),          
    (1004, 2004, '2025-02-10', '2025-02-25'),  
    (1005, 2005, '2025-02-15', NULL);          
GO


----------------------------------------------------------------------------------------------------
--                                          SQL STATEMENTS                                        --
----------------------------------------------------------------------------------------------------

-- 1. List All Books with Their Types and Authors
SELECT 
    b.book_id,
    b.title,
    bt.type_name,
    a.author_name
FROM Book AS b
JOIN BookType AS bt
    ON b.type_code = bt.type_code
JOIN BookAuthor AS ba
    ON b.book_id = ba.book_id
JOIN Author AS a
    ON ba.author_code = a.author_code
ORDER BY b.book_id;

-- 2. List All Editions for a Specific Book (e.g., '1984')
SELECT 
    b.title,
    e.edition_number,
    e.edition_year,
    e.paper_size,
    e.number_of_pages,
    e.publisher,
    e.price,
    CASE WHEN e.with_cd = 1 THEN 'Yes' ELSE 'No' END AS with_cd
FROM Edition AS e
JOIN Book AS b
    ON e.book_id = b.book_id
WHERE b.title = 'Romeo and Juliet';

-- 3. List Readers and the Books They Have Borrowed
SELECT 
    r.card_number,
    r.reader_name,
    b.title,
    br.date_of_borrowing,
    br.date_of_return
FROM Borrow AS br
JOIN Reader AS r
    ON br.card_number = r.card_number
JOIN Book AS b
    ON br.book_id = b.book_id
ORDER BY br.date_of_borrowing DESC;

-- 5. List the Number of Books per Book Type
SELECT 
    bt.type_name,
    COUNT(b.book_id) AS number_of_books
FROM BookType AS bt
LEFT JOIN Book AS b
    ON bt.type_code = b.type_code
GROUP BY bt.type_name;


-- 6. List the book is not borrowed
SELECT 
	b.book_id,
	b.type_code,
	b.title
FROM Book b 
LEFT JOIN Borrow br
	ON b.book_id = br.book_id
WHERE br.card_number IS NULL

----------------------------------------------------------------------------------------------------
--                                            TRIGGERS                                            --
----------------------------------------------------------------------------------------------------

-- Prevent Duplicate Active Borrow Records
GO
CREATE TRIGGER trg_CheckDuplicateBorrow
ON Borrow
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT i.book_id, i.card_number
        FROM Borrow b
        INNER JOIN inserted i 
            ON b.book_id = i.book_id 
           AND b.card_number = i.card_number
        WHERE b.date_of_return IS NULL
        GROUP BY i.book_id, i.card_number
        HAVING COUNT(*) > 1
    )
    BEGIN
        RAISERROR('This book is already borrowed and not yet returned by the same reader.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- TEST
BEGIN TRY
    INSERT INTO Borrow (book_id, card_number, date_of_borrowing, date_of_return)
    VALUES (1003, 2003, '2025-03-01', NULL);
    PRINT 'Test FAILED: Duplicate active borrow record was inserted unexpectedly.';
END TRY
BEGIN CATCH
    PRINT 'Test PASSED: Duplicate active borrow record insertion prevented.';
    PRINT ERROR_MESSAGE();
END CATCH;
GO



-- 2. Ensure Edition Price Is Greater Than Zero
-- This trigger verifies that any inserted or updated edition has a positive price.
GO
CREATE TRIGGER trg_CheckEditionPrice
ON Edition
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM inserted WHERE price <= 0)
    BEGIN
         RAISERROR('Edition price must be greater than zero.', 16, 1);
         ROLLBACK TRANSACTION;
         RETURN;
    END
END;
GO

--Test
PRINT '--- Test Edition Price > 0 ---';
BEGIN TRY
    INSERT INTO Edition (book_id, edition_number, edition_year, paper_size, number_of_pages, publisher, price, with_cd)
    VALUES (1001, 2, 1950, 'A5', 320, 'Test Publisher', -5.00, 0);
    PRINT 'Test FAILED: Edition record with non-positive price was inserted unexpectedly.';
END TRY
BEGIN CATCH
    PRINT 'Test PASSED: Edition record insertion prevented due to non-positive price.';
    PRINT ERROR_MESSAGE();
END CATCH;
GO



-- 3. Validate Borrow Dates
-- This trigger ensures that the return date (if provided) is not earlier than the borrowing date in the Borrow table.
CREATE TRIGGER trg_CheckBorrowDates
ON Borrow
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
         SELECT 1
         FROM inserted
         WHERE date_of_return IS NOT NULL
           AND date_of_return < date_of_borrowing
    )
    BEGIN
         RAISERROR('Return date cannot be earlier than borrowing date.', 16, 1);
         ROLLBACK TRANSACTION;
         RETURN;
    END
END;
GO

-- Test
PRINT '--- Test Borrow Dates (return date earlier than borrowing date) ---';

BEGIN TRY
    INSERT INTO Borrow (book_id, card_number, date_of_borrowing, date_of_return)
    VALUES (1002, 2002, '2025-03-10', '2025-03-05');
    PRINT 'Test FAILED: Borrow record with invalid dates was inserted unexpectedly.';
END TRY
BEGIN CATCH
    PRINT 'Test PASSED: Borrow record with invalid dates was prevented.';
    PRINT ERROR_MESSAGE();
END CATCH;
GO



-- 4. Prevent delete not returned book on Borrow
-- Prevent deletion if an active borrow record (date_of_return IS NULL) is being remove.
CREATE TRIGGER trg_CheckBeforeDelete
ON Borrow
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 
        FROM deleted
        WHERE date_of_return IS NULL
    )
    BEGIN
        RAISERROR('Cannot delete a book not returned.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- Test
PRINT '--- Test Prevent Deletion of Active Borrow Record ---';

BEGIN TRY
    DELETE FROM Borrow
    WHERE book_id = 1003 
      AND card_number = 2003 
      AND date_of_borrowing = '2025-02-07';
    PRINT 'Test FAILED: Active borrow record was deleted unexpectedly.';
END TRY
BEGIN CATCH
    PRINT 'Test PASSED: Deletion of active borrow record prevented.';
    PRINT ERROR_MESSAGE();
END CATCH;
GO



----------------------------------------------------------------------------------------------------
--                                            STORE PROCEDURE                                     --
----------------------------------------------------------------------------------------------------


CREATE PROCEDURE sp_RemoveReturnedBorrowRecords
    @book_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify the book exists.
        IF NOT EXISTS (SELECT 1 FROM Book WHERE book_id = @book_id)
        BEGIN
            RAISERROR('Book not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Delete only the borrow records that have been returned.
        DELETE FROM Borrow
        WHERE book_id = @book_id
          AND date_of_return IS NOT NULL;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO
