# PlantAssetTracker

A JSP + JDBC based web application to monitor factory equipment status and maintenance schedules.

This project allows Admin and Reader roles to manage and view plant machinery, track maintenance dates, and identify at-risk equipment.

---

## 📌 Features

### 🔐 Authentication

* Login system using session tracking
* Role-based access control
* Roles:

  * **Admin** → Full access (Add / Edit / Delete)
  * **Reader** → View-only access

---

### 🏭 Asset Management

* Add new machine
* Edit machine details
* Delete machine
* View all machines
* Filter “At-Risk” machines

---

### 📊 Smart Dashboard

* Total Machines count
* Down Machines count
* Computed At-Risk Machines count
* Status badges (OK / DOWN / AT_RISK)
* Computed risk:

  * OVERDUE
  * DUE SOON (within 15 days)
  * OK

---

### 🎨 UI

* Clean responsive CSS
* Status badges
* Role badge display
* Modern card-based dashboard layout

---

## 🛠 Tech Stack

* JSP (Java Server Pages)
* JDBC
* MySQL
* Apache Tomcat 10+
* HTML / CSS
* Java 17+

---

## 📂 Project Structure

```
PlantAssetTracker/
│
├── login.jsp
├── dashboard.jsp
├── asset_form.jsp
├── asset_save.jsp
├── asset_delete.jsp
├── logout.jsp
│
├── db.jspf
│
├── assets/
│   └── style.css
│
└── WEB-INF/
    └── lib/
        └── mysql-connector-j.jar
```

---

## 🗄 Database Setup

### 1️⃣ Create Database

```sql
CREATE DATABASE plant_asset_tracker;
USE plant_asset_tracker;
```

### 2️⃣ Create Tables

```sql
CREATE TABLE admins (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL,
  role VARCHAR(20) DEFAULT 'admin'
);

CREATE TABLE assets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  asset_code VARCHAR(30) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  status ENUM('OK','DOWN','AT_RISK') DEFAULT 'OK',
  last_maintenance DATE,
  next_maintenance DATE
);
```

### 3️⃣ Insert Sample Users

```sql
INSERT INTO admins(username,password,role)
VALUES
('admin','admin123','admin'),
('reader','reader123','reader');
```

---

## ▶️ How to Run

1. Install **Apache Tomcat 10+**
2. Install **MySQL**
3. Place project folder inside:

   ```
   webapps/
   ```
4. Add MySQL connector JAR to:

   ```
   WEB-INF/lib/
   ```
5. Start Tomcat
6. Open browser:

   ```
   http://localhost:8080/PlantAssetTracker/login.jsp
   ```

---

## 🔑 Default Login

| Role   | Username | Password  |
| ------ | -------- | --------- |
| Admin  | admin    | admin123  |
| Reader | reader   | reader123 |

---

## 🔒 Security Notes

* Uses PreparedStatement to prevent SQL Injection
* Session-based authentication
* Reader role blocked from:

  * Editing
  * Deleting
  * Adding assets
* Direct URL access restricted

---

## 📈 How Risk Calculation Works

```
OVERDUE → next_maintenance < today
DUE SOON → next_maintenance ≤ today + 15 days
OK → beyond 15 days
```

Computed risk is independent of stored status.


## 🚀 Possible Improvements

* Password hashing
* Servlet MVC structure
* Audit logs
* Maintenance report export (PDF)
* Search and filter by asset code
* Session timeout auto logout

---

## 👨‍💻 Author

Subandh Kumar
Mini Project – JSP & JDBC

