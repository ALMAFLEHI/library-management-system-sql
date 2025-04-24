-- =========================================
-- LIBRARY MANAGEMENT SYSTEM (SQL PROJECT)
-- Author: Mohammed Almaflehi
-- Purpose: Internship / GitHub Portfolio
-- Tool: SQL Server Management Studio (SSMS)
-- =========================================

-- DATABASE CREATION
DROP DATABASE IF EXISTS libraryDB;
CREATE DATABASE libraryDB;
GO
USE libraryDB;
GO

-- =========================================
-- 1. TABLE CREATION (DDL)
-- =========================================

CREATE TABLE Author (
  AuthorID NVARCHAR(50) PRIMARY KEY,
  Name NVARCHAR(50) NOT NULL,
  Description NVARCHAR(MAX)
);

CREATE TABLE Publisher (
  PublisherID NVARCHAR(50) PRIMARY KEY,
  Name NVARCHAR(50) NOT NULL,
  Email NVARCHAR(50) NOT NULL,
  Phone NVARCHAR(20) NOT NULL,
  Address NVARCHAR(100) NOT NULL
);

CREATE TABLE ISBN (
  ISBNID NVARCHAR(50) PRIMARY KEY,
  PublisherID NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES Publisher(PublisherID),
  Edition NVARCHAR(50)
);

CREATE TABLE Book (
  BookID NVARCHAR(50) PRIMARY KEY,
  ISBNID NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES ISBN(ISBNID),
  Name NVARCHAR(200) NOT NULL,
  Description NVARCHAR(MAX),
  Publish_Date DATE NOT NULL,
  Genre NVARCHAR(50),
  Age_restriction INT NOT NULL,
  Category NVARCHAR(50) NOT NULL,
  ColorTag NVARCHAR(50)
);

CREATE TABLE Authorship (
  AuthorshipID NVARCHAR(50) PRIMARY KEY,
  ISBNID NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES ISBN(ISBNID),
  AuthorID NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES Author(AuthorID)
);

CREATE TABLE Book_copy (
  CopyID NVARCHAR(50) PRIMARY KEY,
  BookID NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES Book(BookID),
  Cover_type NVARCHAR(50) NOT NULL
);

CREATE TABLE Member (
  MemberID NVARCHAR(50) PRIMARY KEY,
  Name NVARCHAR(50) NOT NULL,
  Email NVARCHAR(50) NOT NULL,
  Phone NVARCHAR(20) NOT NULL,
  Membership_status NVARCHAR(100) NOT NULL
);

CREATE TABLE Loan (
  LoanID NVARCHAR(50) PRIMARY KEY,
  CopyID NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES Book_copy(CopyID),
  MemberID NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES Member(MemberID),
  Loan_date DATE NOT NULL,
  DueDate DATE NOT NULL,
  ReturnDate DATE,
  Price DECIMAL(10,2) NOT NULL,
  Price_currency NVARCHAR(3) NOT NULL,
  Status NVARCHAR(20) NOT NULL DEFAULT 'Loaned'
);

CREATE TABLE Reservation (
  ReservationID NVARCHAR(50) PRIMARY KEY,
  MemberID NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES Member(MemberID),
  BookID NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES Book(BookID),
  Date DATE NOT NULL
);

-- =========================================
-- 2. VIEW (Available Books)
-- =========================================

CREATE VIEW AvailableBooksView AS
SELECT b.BookID, b.Name AS BookName, b.Category, b.ColorTag
FROM Book b
JOIN Book_copy bc ON b.BookID = bc.BookID
LEFT JOIN Loan l ON bc.CopyID = l.CopyID
WHERE l.LoanID IS NULL OR l.Status = 'Returned';

-- =========================================
-- 3. STORED PROCEDURES
-- =========================================

-- Borrow a Book Procedure
CREATE PROCEDURE BorrowBook
  @LoanID NVARCHAR(50),
  @CopyID NVARCHAR(50),
  @MemberID NVARCHAR(50),
  @LoanDate DATE,
  @DueDate DATE,
  @Price DECIMAL(10,2),
  @Currency NVARCHAR(3)
AS
BEGIN
  INSERT INTO Loan (LoanID, CopyID, MemberID, Loan_date, DueDate, Price, Price_currency, Status)
  VALUES (@LoanID, @CopyID, @MemberID, @LoanDate, @DueDate, @Price, @Currency, 'Loaned');
END;
GO

-- Return a Book Procedure
CREATE PROCEDURE ReturnBook
  @LoanID NVARCHAR(50),
  @ReturnDate DATE
AS
BEGIN
  UPDATE Loan
  SET ReturnDate = @ReturnDate,
      Status = 'Returned'
  WHERE LoanID = @LoanID;
END;
GO

-- =========================================
-- 4. TRIGGER
-- =========================================

-- If member returns late 3 times, mark as Inactive
CREATE TRIGGER trg_MarkInactiveAfterOverdue
ON Loan
AFTER UPDATE
AS
BEGIN
  UPDATE m
  SET Membership_status = 'Inactive'
  FROM Member m
  WHERE m.MemberID IN (
    SELECT MemberID
    FROM Loan
    WHERE ReturnDate > DueDate
    GROUP BY MemberID
    HAVING COUNT(*) >= 3
  );
END;
GO

-- =========================================
-- 5. ANALYTICAL QUERIES
-- =========================================

-- Q1: Books available for loan, excluding 'Reference' category
SELECT DISTINCT b.Name AS BookName, b.Description, b.Category,
  CASE b.Category
    WHEN 'Fiction' THEN 'General fiction including novels and stories.'
    WHEN 'Dystopian' THEN 'Imagined society with suffering or injustice.'
    WHEN 'Science Fiction' THEN 'Future science/tech and space travel.'
    WHEN 'Horror' THEN 'Fiction evoking dread or fear.'
    WHEN 'Young Adult' THEN 'Targeted for readers aged 12-18.'
    WHEN 'Historical Fiction' THEN 'Set in the past, based on real events.'
    ELSE 'Other'
  END AS CategoryDescription
FROM Book b
JOIN Book_copy bc ON b.BookID = bc.BookID
LEFT JOIN Loan l ON bc.CopyID = l.CopyID
WHERE (l.LoanID IS NULL OR l.Status = 'Returned') AND b.Category <> 'Reference'
ORDER BY b.Name;

-- Q2: Active members and their borrowed books in 2024
SELECT 
  SUBSTRING(m.Name, 1, CHARINDEX(' ', m.Name) - 1) AS FirstName,
  SUBSTRING(m.Name, CHARINDEX(' ', m.Name) + 1, LEN(m.Name)) AS LastName,
  b.Name AS BookName,
  l.Loan_date
FROM Member m
JOIN Loan l ON m.MemberID = l.MemberID
JOIN Book_copy bc ON l.CopyID = bc.CopyID
JOIN Book b ON bc.BookID = b.BookID
WHERE m.Membership_status = 'Active' AND YEAR(l.Loan_date) = 2024
ORDER BY l.Loan_date;

-- Q3: Members with more than 2 overdue returns
SELECT 
  SUBSTRING(m.Name, 1, CHARINDEX(' ', m.Name) - 1) AS FirstName,
  SUBSTRING(m.Name, CHARINDEX(' ', m.Name) + 1, LEN(m.Name)) AS LastName,
  m.Phone,
  COUNT(*) AS OverdueCount,
  SUM(l.Price) AS TotalDueAmount
FROM Member m
JOIN Loan l ON m.MemberID = l.MemberID
WHERE l.ReturnDate IS NULL OR l.ReturnDate > l.DueDate
GROUP BY m.MemberID, m.Name, m.Phone
HAVING COUNT(*) > 2
ORDER BY OverdueCount DESC;

-- Q4: Most borrowed book per genre
WITH GenreLoanCount AS (
  SELECT b.Genre, b.BookID, COUNT(*) AS LoanCount
  FROM Book b
  JOIN Book_copy bc ON b.BookID = bc.BookID
  JOIN Loan l ON bc.CopyID = l.CopyID
  GROUP BY b.Genre, b.BookID
)
SELECT b.Name AS BookName, b.Description, g.Genre
FROM GenreLoanCount g
JOIN Book b ON g.BookID = b.BookID
WHERE g.LoanCount = (
  SELECT MAX(LoanCount) FROM GenreLoanCount WHERE Genre = g.Genre
)
ORDER BY g.Genre DESC;

-- Q5: Genre with the most books
SELECT TOP 1 Genre, COUNT(*) AS TotalBooks
FROM Book
GROUP BY Genre
ORDER BY TotalBooks DESC;

-- Q6: Reservations in 2023
SELECT COUNT(*) AS TotalReservations
FROM Reservation
WHERE YEAR(Date) = 2023;


-- =========================================
-- 6. SAMPLE DATA INSERTS (DML)
-- =========================================

-- Author
INSERT INTO Author (AuthorID, Name, Description) VALUES
('A01', 'George Orwell', 'Author of dystopian fiction'),
('A02', 'J.K. Rowling', 'Author of Harry Potter series');

-- Publisher
INSERT INTO Publisher (PublisherID, Name, Email, Phone, Address) VALUES
('P01', 'Penguin Books', 'contact@penguin.com', '+44-20-1234-5678', '80 Strand, London, UK'),
('P02', 'Bloomsbury', 'info@bloomsbury.com', '+44-20-9876-5432', '50 Bedford Square, London, UK');

-- ISBN
INSERT INTO ISBN (ISBNID, PublisherID, Edition) VALUES
('ISBN01', 'P01', '1st Edition'),
('ISBN02', 'P02', '2nd Edition');

-- Book
INSERT INTO Book (BookID, ISBNID, Name, Description, Publish_Date, Genre, Age_restriction, Category, ColorTag) VALUES
('B001', 'ISBN01', '1984', 'Dystopian novel', '1949-06-08', 'Dystopian', 16, 'Fiction', 'Gray'),
('B002', 'ISBN02', 'Harry Potter and the Sorcerer''s Stone', 'Fantasy novel', '1997-06-26', 'Fantasy', 10, 'Fiction', 'Yellow');

-- Authorship
INSERT INTO Authorship (AuthorshipID, ISBNID, AuthorID) VALUES
('AU01', 'ISBN01', 'A01'),
('AU02', 'ISBN02', 'A02');

-- Book Copy
INSERT INTO Book_copy (CopyID, BookID, Cover_type) VALUES
('C001', 'B001', 'Hardcover'),
('C002', 'B002', 'Paperback');

-- Member
INSERT INTO Member (MemberID, Name, Email, Phone, Membership_status) VALUES
('M001', 'Alice Smith', 'alice@example.com', '0123456789', 'Active'),
('M002', 'Bob Johnson', 'bob@example.com', '0987654321', 'Active');

-- Loan
INSERT INTO Loan (LoanID, CopyID, MemberID, Loan_date, DueDate, ReturnDate, Price, Price_currency, Status) VALUES
('L001', 'C001', 'M001', '2024-04-01', '2024-04-15', '2024-04-10', 10.00, 'MYR', 'Returned'),
('L002', 'C002', 'M002', '2024-04-05', '2024-04-19', NULL, 15.00, 'MYR', 'Loaned');

-- Reservation
INSERT INTO Reservation (ReservationID, MemberID, BookID, Date) VALUES
('R001', 'M001', 'B002', '2024-04-20'),
('R002', 'M002', 'B001', '2024-04-21');