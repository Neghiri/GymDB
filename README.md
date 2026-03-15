GymDB - Relational Gym Management System
Description
This project is a relational database designed and optimized for comprehensive gym management. Developed in PostgreSQL, the system manages the entire lifecycle of members, subscription enrollments, course scheduling, workout plan assignments, and attendance tracking.

The main goal of this project is to demonstrate a solid application of Referential Integrity, Normalization principles, and the use of PL/pgSQL Triggers to automate advanced business logic.

Key Features
Member and Subscription Management: Tracking subscription history without overwriting past data.

Course and Register Planning: Organizing classes through registers linked to rooms, with automatic capacity control.

Personalized Workout Plans: Flexible association of exercises, sets, and repetitions tailored to individual users.

Automation via Triggers (PL/pgSQL):

Automatic control of the maximum number of participants per class to prevent overbooking.

Automatic calculation of the subscription expiration date based on the chosen duration.

Automatic update of the register status (Scheduled/Completed) based on the current date.

Architectural and Design Choices (Business Rules)
During the design phase, specific choices were made to ensure the database is robust and reflects real-world scenarios:

Subscription History: The foreign key CF_Iscritto resides in the ABBONAMENTO table (and not vice versa) to allow a single user to maintain a history of renewals over time.

Workout Customization: The Serie and Ripetizione fields are not attributes of the single ESERCIZIO entity, but reside in the join table CONTIENE. This allows two members to perform the same exercise with different workloads.

Orphan Data Prevention: Strict application of ON DELETE CASCADE (e.g., if a member is deleted, their class enrollments are removed) and ON DELETE RESTRICT constraints (e.g., a room cannot be deleted if there are courses currently scheduled in it).

Database Structure (Main Entities)
ISCRITTO: Demographic and biometric data of the clients.

ISTRUTTORE: Gym staff.

SALA & CORSO: Management of spaces and course types.

REGISTRO & FREQUENTARE: Calendar of individual classes and attendance tracking.

SCHEDA, ESERCIZIO & CONTIENE: Management of workout plans.

ABBONAMENTO & TIPOLOGIA: Commercial management and deadlines.

Getting Started
Ensure you have PostgreSQL installed on your system.

Clone this repository:
git clone https://github.com/Neghiri/GymDB.git

