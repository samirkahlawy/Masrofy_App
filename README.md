# 📱 Masroufy (مصروفي)
> **Financial Mindfulness through Intelligent Budgeting.**

<p align="left">
  <img src="https://img.shields.io/badge/Framework-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Language-Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Architecture-Clean--Layered-green?style=for-the-badge" />
</p>

**Masroufy** is a sophisticated personal finance management application. It dynamically adjusts your "Safe Daily Spending Limit" based on real-time behavior and historical data to ensure financial stability throughout your budget cycle.

---

## ✨ Key Features

| Feature | Description |
| :--- | :--- |
| **🎯 Dynamic Daily Limit** | Automatically calculates your *Safe-to-Spend* amount for today. |
| **🔄 Intelligent Rollover** | Redistributes surplus savings or deficits across remaining days. |
| **⚡ Rapid Logging** | Optimized UI for recording transactions in under 3 seconds. |
| **⚠️ Smart Thresholds** | Visual alerts when spending approaches predefined budget limits. |
| **📊 Historical Audit** | Full transparency with categorized history and financial analytics. |

---

## 🏗 Technical Architecture
The project is built using **Clean Architecture** to ensure total separation of concerns and high testability.

### 🔴 Layered Breakdown
* **Presentation Layer**: Reactive UI using **Provider** for state management.
* **Domain & Logic Layer**: Contains the `FinanceCalculatorService` for core algorithms.
* **Data Layer**: Implements the **Repository Pattern** with **SQLite** for local persistence.

---

## 🛠 Software Engineering Excellence

### 🏗️ SOLID Principles Implementation
* **S (Single Responsibility)**: Logic is decoupled; Providers manage state, Services handle math.
* **O (Open/Closed)**: New data sources can be added via interfaces without modifying UI code.
* **D (Dependency Inversion)**: High-level modules depend on abstractions, not concrete implementations.

### 🎨 Design Patterns
* **Repository Pattern**: For clean data abstraction.
* **Singleton Pattern**: Safe, single-instance database access via `DatabaseHelper`.
* **Observer Pattern**: Leveraged through Flutter's `ChangeNotifier`.
---
<h2>💻 Tech Stack</h2>
Framework: Flutter (Dart)

State Management: Provider

Local Database: SQLite (sqflite)

Architecture: Clean Architecture + Repository Pattern
---
<h3>⚙️ Installation & Setup</h3>
Clone the repository:

git clone https://github.com/samirkahlawy/masroufy.git
Install dependencies:

flutter pub get
Run the application:

flutter run
<h2>👥 Contributors</h2>
Samir 
yossef
Saifeddine
abdelkareeem
---
## 📂 Project Structure

```text
lib/
lib/
├── core/
│   ├── constants/
│   └── utils/
├── data/
│   ├── local/
│   │   └── database_helper.dart
│   └── repositories/
│       ├── i_finance_repository.dart
│       └── sqlite_finance_repository.dart
├── logic/
│   ├── finance_provider.dart
│   └── finance_calculator_service.dart
├── models/
│   ├── budget_cycle.dart
│   ├── category.dart
│   ├── expense.dart
│   └── user.dart
├── presentation/
│   ├── screens/
│   │   ├── add_expense_screen.dart
│   │   ├── dashboard_screen.dart
│   │   └── splash_screen.dart
│   └── widgets/
│       ├── expense_pie_chart.dart
│       └── safe_limit_card.dart
└── main.dart
