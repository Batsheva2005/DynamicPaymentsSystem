# Dynamic Payments System 🚀

A high-performance calculation engine capable of processing dynamic formulas on millions of records using SQL Server and C# .NET.

## 📋 Project Overview
This project demonstrates two different architectural approaches for processing heavy data loads:
1.  **SQL Stored Procedure:** Using Dynamic SQL and cursor-based iteration.
2.  **C# .NET Optimized:** Using `SqlBulkCopy` and `DataTable` in-memory vector calculation (Best Performance).

## 🏆 Performance Results
| Method | Processing Speed (CPU) | Status |
| :--- | :--- | :--- |
| **C# .NET Optimized** | **~1.5 Seconds** ⚡ | **Winner** |
| SQL Stored Procedure | ~15.0 Seconds | Slower |

*> Note: Total execution time for C# (including DB write I/O) is approx 9.5 sec.*

*(See full report in `docs` folder)*

## 🛠️ Tech Stack
* **Database:** MS SQL Server (Dynamic SQL, Stored Procedures)
* **Backend:** C# .NET 8.0 (Console App)
* **Key Concepts:** Bulk Operations, In-Memory Processing, Transpilation.

## 📂 Project Structure
* `src/`: Source code for the C# Application.
* `sql/`: Database setup scripts and Stored Procedures.
* `docs/`: Summary report (PDF) and verification screenshots.

## 🚀 How to Run
1.  Execute scripts from `sql/` folder to setup the DB.
2.  Update connection string in `src/SqlService.cs`.
3.  Run the Console Application.
