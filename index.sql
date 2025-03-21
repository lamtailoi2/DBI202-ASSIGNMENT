use DB_ASSIGNMENT

-- Drop tables in order to avoid foreign key dependency issues:
DROP TABLE IF EXISTS Borrow;
DROP TABLE IF EXISTS Edition;
DROP TABLE IF EXISTS BookAuthor;
DROP TABLE IF EXISTS Book;
DROP TABLE IF EXISTS Author;
DROP TABLE IF EXISTS BookType;
DROP TABLE IF EXISTS Reader;
DROP TABLE IF EXISTS BorrowAudit;

-- 1. BookType Table
--    Stores different book types (historical, political, economic, etc.)
CREATE TABLE BookType (
    type_code INT IDENTITY(1,1) PRIMARY KEY,    
    type_name VARCHAR(100) NOT NULL
);

-- 2. Author Table
--    Stores information about authors
CREATE TABLE Author (
    author_code VARCHAR(6) CHECK(author_code LIKE 'AT%') PRIMARY KEY,     
    author_name VARCHAR(200) NOT NULL,
    year_of_birth INT                 
);

-- 3. Book Table
--    Stores general information about each book
CREATE TABLE Book (
    book_id VARCHAR(6) CHECK(book_id LIKE 'BK%') PRIMARY KEY,          -- Could be IDENTITY
    type_code INT NOT NULL,           -- FK referencing BookType
    title NVARCHAR(300) NOT NULL,

    CONSTRAINT FK_Book_BookType 
        FOREIGN KEY (type_code) 
        REFERENCES BookType(type_code)
);

CREATE TABLE BookAuthor (
     book_id VARCHAR(6) CHECK(book_id LIKE 'BK%') NOT NULL,
	 author_code VARCHAR(6) CHECK(author_code LIKE 'AT%')  NOT NULL,

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
    book_id VARCHAR(6) CHECK(book_id LIKE 'BK%') NOT NULL,
    edition_number INT NOT NULL CHECK(edition_number > 0),      
    edition_year INT NOT NULL CHECK(edition_year > 0),       
    paper_size VARCHAR(50),           
    number_of_pages INT CHECK(number_of_pages > 0),
    publisher VARCHAR(200),
    price DECIMAL(10,2) CHECK(price > 0),
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
    card_number VARCHAR(6) CHECK(card_number like 'R%') PRIMARY KEY,      
    date_of_issue DATE,
    reader_name NVARCHAR(200),
    occupation VARCHAR(100),
    gender CHAR(1) CHECK (gender IN ('M', 'F'))                     
);

-- 7. Borrow Table
--    Implements the many-to-many relationship between Readers and Books
--   Also stores date of borrowing and date of return

CREATE TABLE Borrow (
    book_id VARCHAR(6) CHECK(book_id LIKE 'BK%') NOT NULL,
    card_number VARCHAR(6) CHECK(card_number like 'R%') NOT NULL,
    date_of_borrowing DATE NOT NULL,
    date_of_return DATE NULL 

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

INSERT INTO BookType (type_name)
VALUES
    ('Historical'),
    ('Political'),
    ('Economic'),
    ('Fiction'),
    ('Science');


INSERT INTO Author (author_code, author_name, year_of_birth)
VALUES
    ('AT0001', 'Author One', 1940),
    ('AT0002', 'Author Two', 1950),
    ('AT0003', 'Author Three', 1960),
    ('AT0004', 'Author Four', 1970),
    ('AT0005', 'Author Five', 1980);


INSERT INTO Book (book_id, type_code, title)
VALUES
    ('BK0001', 1, 'The Dawn of History'),
    ('BK0002', 2, 'Political Paradigms'),
    ('BK0003', 3, 'Economic Essentials'),
    ('BK0004', 4, 'Fictional Realms'),
    ('BK0005', 5, 'Scientific Discoveries'),
    ('BK0006', 1, 'Ancient Civilizations'),
    ('BK0007', 2, 'Modern Governance'),
    ('BK0008', 3, 'Market Forces'),
    ('BK0009', 4, 'Fantasy Worlds'),
    ('BK0010', 5, 'Innovations in Science');


INSERT INTO Reader (card_number, date_of_issue, reader_name, occupation, gender)
VALUES
    ('R0001', '2025-03-15', 'Reader One', 'Student', 'F'),
    ('R0002', '2025-03-16', 'Reader Two', 'Teacher', 'M'),
    ('R0003', '2025-03-17', 'Reader Three', 'Engineer', 'M'),
    ('R0004', '2025-03-18', 'Reader Four', 'Doctor', 'F'),
    ('R0005', '2025-03-19', 'Reader Five', 'Artist', 'F');


INSERT INTO BookAuthor (book_id, author_code)
VALUES
    ('BK0001', 'AT0001'),
    ('BK0002', 'AT0002'),
    ('BK0003', 'AT0003'),
    ('BK0004', 'AT0004'),
    ('BK0005', 'AT0005'),
    ('BK0006', 'AT0001'),
    ('BK0007', 'AT0002'),
    ('BK0008', 'AT0003'),
    ('BK0009', 'AT0004'),
    ('BK0010', 'AT0005');

INSERT INTO Edition (book_id, edition_number, edition_year, paper_size, number_of_pages, publisher, price, with_cd)
VALUES
    ('BK0001', 1, 2000, 'A4', 250, 'History Press', 19.99, 0),
    ('BK0002', 1, 2005, 'A4', 300, 'Politics House', 24.99, 0),
    ('BK0003', 1, 2010, 'A4', 320, 'Econ Publishers', 29.99, 1),
    ('BK0004', 1, 2015, 'Letter', 280, 'Fiction Works', 22.99, 0),
    ('BK0005', 1, 2020, 'A4', 350, 'Science Hub', 34.99, 1),
    ('BK0006', 1, 2001, 'A4', 260, 'History Press', 20.99, 0),
    ('BK0007', 1, 2006, 'A4', 310, 'Politics House', 25.99, 0),
    ('BK0008', 1, 2011, 'A4', 330, 'Econ Publishers', 30.99, 1),
    ('BK0009', 1, 2016, 'Letter', 290, 'Fiction Works', 23.99, 0),
    ('BK0010', 1, 2021, 'A4', 360, 'Science Hub', 35.99, 1);


INSERT INTO Borrow (book_id, card_number, date_of_borrowing, date_of_return)
VALUES 
    ('BK0001', 'R0001', '2025-03-20', NULL),
    ('BK0002', 'R0002', '2025-03-21', '2025-03-28'),
    ('BK0003', 'R0003', '2025-03-22', '2025-03-29'),
    ('BK0004', 'R0004', '2025-03-23', NULL),
    ('BK0005', 'R0005', '2025-03-24', '2025-03-30');


----------------------------------------------------------------------------------------------------
--                                          SQL STATEMENTS                                       --
----------------------------------------------------------------------------------------------------

-- List All Books with Their Book Type
SELECT b.book_id,
       b.title,
       bt.type_name
FROM Book b
JOIN BookType bt ON b.type_code = bt.type_code;

-- List All Authors and the Books They Authored
SELECT a.author_name,
       b.title
FROM Author a
JOIN BookAuthor ba ON a.author_code = ba.author_code
JOIN Book b ON ba.book_id = b.book_id;


-- Display Borrow Records with Reader Names and Book Titles
SELECT r.reader_name,
       b.title,
       br.date_of_borrowing,
       br.date_of_return
FROM Borrow br
JOIN Reader r ON br.card_number = r.card_number
JOIN Book b ON br.book_id = b.book_id;

-- Show All Editions for a Specific Book
SELECT *
FROM Edition
WHERE book_id = 'BK0001';

-- Count the Number of Books Borrowed by Each Reader
SELECT r.reader_name,
       COUNT(br.book_id) AS total_borrowed
FROM Borrow br
JOIN Reader r ON br.card_number = r.card_number
GROUP BY r.reader_name;


----------------------------------------------------------------------------------------------------
--                                          TRIGGER                                               --
----------------------------------------------------------------------------------------------------

CREATE TABLE BorrowAudit
(
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    book_id VARCHAR(6),
    card_number VARCHAR(6),
    date_of_borrowing DATE,
    date_of_return DATE,
    ActionType VARCHAR(10),  -- 'INSERT', 'UPDATE' hoặc 'DELETE'
    AuditDate DATETIME DEFAULT GETDATE()
);
GO

CREATE TRIGGER trg_AuditBorrow
ON Borrow
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Log new records inserted
    INSERT INTO BorrowAudit (book_id, card_number, date_of_borrowing, date_of_return, ActionType)
    SELECT book_id, card_number, date_of_borrowing, date_of_return, 'INSERT'
    FROM inserted
    WHERE NOT EXISTS (
        SELECT 1 FROM deleted 
        WHERE inserted.book_id = deleted.book_id 
          AND inserted.card_number = deleted.card_number 
          AND inserted.date_of_borrowing = deleted.date_of_borrowing
    );

    -- Log records deleted
    INSERT INTO BorrowAudit (book_id, card_number, date_of_borrowing, date_of_return, ActionType)
    SELECT book_id, card_number, date_of_borrowing, date_of_return, 'DELETE'
    FROM deleted
    WHERE NOT EXISTS (
        SELECT 1 FROM inserted 
        WHERE inserted.book_id = deleted.book_id 
          AND inserted.card_number = deleted.card_number 
          AND inserted.date_of_borrowing = deleted.date_of_borrowing
    );

    -- Log records updated (both inserted and deleted exist)
    INSERT INTO BorrowAudit (book_id, card_number, date_of_borrowing, date_of_return, ActionType)
    SELECT i.book_id, i.card_number, i.date_of_borrowing, i.date_of_return, 'UPDATE'
    FROM inserted i
    INNER JOIN deleted d ON i.book_id = d.book_id 
                         AND i.card_number = d.card_number 
                         AND i.date_of_borrowing = d.date_of_borrowing;
END;
GO

----------------------------------------------------------------------------------------------------
--                                          STORE PROCDURE                                               --
----------------------------------------------------------------------------------------------------

CREATE PROCEDURE sp_delete_book
    @book_id VARCHAR(6)
AS
BEGIN
    SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM Book WHERE book_id = @book_id)
    BEGIN
        PRINT 'Book ID does not exist.';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Delete records from the Borrow table related to the book
        DELETE FROM Borrow
        WHERE book_id = @book_id;

        -- Delete records from the Edition table related to the book
        DELETE FROM Edition
        WHERE book_id = @book_id;

        -- Delete records from the BookAuthor table related to the book
        DELETE FROM BookAuthor
        WHERE book_id = @book_id;

        -- Delete the book record from the Book table
        DELETE FROM Book
        WHERE book_id = @book_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Report error
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO


CREATE PROCEDURE sp_borrow_book
    @book_id VARCHAR(6),
    @card_number VARCHAR(6)
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the book exists
    IF NOT EXISTS (SELECT 1 FROM Book WHERE book_id = @book_id)
    BEGIN
        PRINT 'Book ID does not exist.';
        RETURN;
    END

    -- Check if the reader exists
    IF NOT EXISTS (SELECT 1 FROM Reader WHERE card_number = @card_number)
    BEGIN
        PRINT 'Reader card number does not exist.';
        RETURN;
    END

    -- Check if the user has already borrowed the book (regardless of the borrowing date)
    IF EXISTS (SELECT 1 FROM Borrow WHERE book_id = @book_id AND card_number = @card_number)
    BEGIN
        PRINT 'User has already borrowed this book.';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert a new borrowing record with the current date as the borrowing date
        INSERT INTO Borrow (book_id, card_number, date_of_borrowing)
        VALUES (@book_id, @card_number, GETDATE());

        COMMIT TRANSACTION;
        PRINT 'Book borrowed successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        PRINT 'An error occurred while borrowing the book.';
    END CATCH
END;




