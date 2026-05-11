# 📱 Masroufy (مصروفي)
> **Financial Mindfulness through Intelligent Budgeting.**

<p align="left">
  <img src="https://img.shields.io/badge/Framework-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Language-Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Architecture-Clean--Layered-green?style=for-the-badge" />
</p>

**Masroufy** is a sophisticated personal finance management application. It dynamically adjusts your "Safe Daily Spending Limit" based on real-time behavior and historical data to ensure financial stability throughout your budget cycle.

---
<h1>📸masrofy images</h1>
<img width="953" height="1015" alt="image" src="https://github.com/user-attachments/assets/ea356365-4436-4fe1-89e0-2da53cefd74a" />
<img width="954" height="1016" alt="image" src="https://github.com/user-attachments/assets/e362ce67-e523-4344-aeda-74bf0af2ff5a" />
<img width="954" height="1013" alt="image" src="https://github.com/user-attachments/assets/1e816289-33fd-4270-97cc-61933a312e0b" />
<img width="955" height="1016" alt="image" src="https://github.com/user-attachments/assets/09009a7c-e7a1-47cc-bd3f-46ea98c23daf" />
<img width="957" height="1013" alt="image" src="https://github.com/user-attachments/assets/03810fe2-6ba0-4f0b-980c-89df16504213" />
<img width="955" height="1014" alt="image" src="https://github.com/user-attachments/assets/4149b501-57ec-43bd-8014-c8c8d7e253f3" />
<img width="956" height="1018" alt="image" src="https://github.com/user-attachments/assets/66dec6e6-cb3f-4bdd-9c18-8d08d224dcff" />
<img width="957" height="1015" alt="image" src="https://github.com/user-attachments/assets/483c208d-e036-446b-9fab-6b2b2877faa1" />
<img width="955" height="1019" alt="image" src="https://github.com/user-attachments/assets/fbbff713-d45c-402b-986e-9bae6d858c2d" />
---
<h2>use case model</h2>
<img width="1001" height="658" alt="image" src="https://github.com/user-attachments/assets/7ac58be9-9337-4acc-b4f9-b1b357e8e5d3" />
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
---
<h2>👥 Contributors</h2>
Samir 
yossef
Saifeddine
abdelkareeem

<h1>📂 Project Structure</h1>

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
