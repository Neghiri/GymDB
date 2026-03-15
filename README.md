# GYMDB - RELATIONAL GYM MANAGEMENT SYSTEM

---

## DESCRIPTION
This project is a relational database designed and optimized for comprehensive gym management. Developed in **PostgreSQL**, the system manages the entire lifecycle of members, subscription enrollments, course scheduling, workout plan assignments, and attendance tracking.

The main goal of this project is to demonstrate a solid application of **Referential Integrity**, **Normalization** principles, and the use of **PL/pgSQL Triggers** to automate advanced business logic.

---

## KEY FEATURES
* **Member and Subscription Management:** Tracking subscription history without overwriting past data.
* **Course and Register Planning:** Organizing classes through registers linked to rooms, with automatic capacity control.
* **Personalized Workout Plans:** Flexible association of exercises, sets, and repetitions tailored to individual users.
* **Automation via Triggers (PL/pgSQL):**
  * Automatic control of the maximum number of participants per class to prevent overbooking.
  * Automatic calculation of the subscription expiration date based on the chosen duration.
  * Automatic update of the register status (Scheduled/Completed) based on the current date.
* **Data Abstraction (Views):** Created views (`v_iscritti_attivi`, `v_calendario_corsi`) to simplify data extraction for the front-end and hide sensitive biometric data.
* **Performance Optimization (Indexes):** Implemented indexes on frequently queried columns (e.g., member's last name, class dates) to ensure fast data retrieval as the database grows.
* **Security & Role-Based Access:** Configured a dedicated `receptionist` role with restricted access, utilizing `GRANT` and `REVOKE` to permit viewing of specific views while preventing unauthorized data modification or deletion.

---

## ARCHITECTURAL AND DESIGN CHOICES (BUSINESS RULES)
During the design phase, specific choices were made to ensure the database is robust and reflects real-world scenarios:
1. **Subscription History:** The foreign key `CF_Iscritto` resides in the `ABBONAMENTO` table (and not vice versa) to allow a single user to maintain a history of renewals over time.
2. **Workout Customization:** The `Serie` and `Ripetizione` fields are not attributes of the single `ESERCIZIO` entity, but reside in the join table `CONTIENE`. This allows two members to perform the same exercise with different workloads.
3. **Orphan Data Prevention:** Strict application of `ON DELETE CASCADE` (e.g., if a member is deleted, their class enrollments are removed) and `ON DELETE RESTRICT` constraints (e.g., a room cannot be deleted if there are courses currently scheduled in it).

---

## DATABASE STRUCTURE (MAIN ENTITIES)
* `ISCRITTO`: Demographic and biometric data of the clients.
* `ISTRUTTORE`: Gym staff.
* `SALA` & `CORSO`: Management of spaces and course types.
* `REGISTRO` & `FREQUENTARE`: Calendar of individual classes and attendance tracking.
* `SCHEDA`, `ESERCIZIO` & `CONTIENE`: Management of workout plans.
* `ABBONAMENTO` & `TIPOLOGIA`: Commercial management and deadlines.

---

Ensure you have **PostgreSQL** installed on your system.

