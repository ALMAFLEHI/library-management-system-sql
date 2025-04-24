# 📚 Library Management System (SQL Server Project)

A fully functional SQL Server database project designed to demonstrate database design, data manipulation, and analytical querying skills. This project is structured for professional presentation on GitHub and internship portfolios.

---

## 🔧 Technologies Used
- Microsoft SQL Server 2022
- SQL Server Management Studio (SSMS)
- T-SQL (DDL, DML, Views, Procedures, Triggers)

---

## 📁 Project Structure
- `library_management_system.sql`: Single SQL file with complete DDL, DML, stored procedures, views, triggers, and analytics.
- `README.md`: Documentation, setup instructions, and query samples.

---

## ⚙️ How to Run
1. Open SSMS and connect to your local server.
2. Copy the contents of `library_management_system.sql` into a new query window.
3. Run the script to:
   - Create the database and all tables
   - Insert sample data
   - Create views, procedures, triggers
   - Test analytical queries

---

## 🧠 Features
- 📚 **Normalized Tables**: Includes Author, Publisher, Book, ISBN, Members, and Loans.
- 👁 **Views**: `AvailableBooksView` to track all available (not loaned) books.
- 🔄 **Stored Procedures**:
  - `BorrowBook` to log a new loan
  - `ReturnBook` to update return date and loan status
- ⚠ **Trigger**: Auto-deactivates members with 3 or more overdue returns.
- 📊 **Analytics**: Insightful queries on loans, overdue books, genres, and reservations.

---

## 📌 Query Samples
### 1. Books Available for Loan
```sql
SELECT * FROM AvailableBooksView;
```

### 2. Most Borrowed Book per Genre
```sql
-- Returns the most loaned book in each genre
WITH GenreLoanCount AS (...)
SELECT ...
```

### 3. Members With Overdue Returns
```sql
SELECT *
FROM Loan
WHERE ReturnDate IS NULL AND DueDate < GETDATE();
```

---

## 📸 Screenshots (Insert in your GitHub later)
- 📷 Screenshot 1: ![image](https://github.com/user-attachments/assets/58922110-e1d5-43f7-95ac-1ba87c6ca5a8)

- 📷 Screenshot 2: ![image](https://github.com/user-attachments/assets/bcc2ebc7-73b2-487a-b641-c0c47e9d0f09)

- 📷 Screenshot 3: ![image](https://github.com/user-attachments/assets/a58f35d2-9217-4c38-bbec-d3cd0369bf95)


---

## 📌 Notes
- Test data is simplified for demonstration.
- You may scale it up with more data or UI integration (e.g., C# frontend).

---

## 👨‍💻 Author
**Mohammed Almaflehi**  
[www.almaflehidev.com](https://www.almaflehidev.com)  
GitHub: [@ALMAFLEHI](https://github.com/ALMAFLEHI)  
LinkedIn: [Mohammed Al-Maflehi](https://www.linkedin.com/in/mohammed-al-maflehi-926a28330/)

---

> 💼 Designed to be portfolio-ready and recruiter-friendly!

