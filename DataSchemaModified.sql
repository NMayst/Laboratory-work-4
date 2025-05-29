
/* Видалення таблиць з урахуванням зовнішніх ключів */
DROP TABLE IF EXISTS RiskRemovalInstruction CASCADE;
DROP TABLE IF EXISTS Notification CASCADE;
DROP TABLE IF EXISTS ProtectiveEquipment CASCADE;
DROP TABLE IF EXISTS SafetyRule CASCADE;
DROP TABLE IF EXISTS Checklist CASCADE;
DROP TABLE IF EXISTS Workplace CASCADE;
DROP TABLE IF EXISTS WakeUpAlarm CASCADE;
DROP TABLE IF EXISTS Recommendation CASCADE;
DROP TABLE IF EXISTS SleepPhase CASCADE;
DROP TABLE IF EXISTS Sleep CASCADE;
DROP TABLE IF EXISTS "User" CASCADE;

/* Таблиця User */
CREATE TABLE user (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL CHECK (regexp_like(name, '^[A-ZА-Я][a-zа-я\- ]{1,49}$')),
    age INTEGER NOT NULL CHECK (age BETWEEN 16 AND 100),
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('Male', 'Female', 'Other'))
);

/* Таблиця Sleep */
CREATE TABLE sleep (
    sleep_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES user(user_id),
    sleepDate DATE NOT NULL CHECK (sleepDate <= CURRENT_DATE),
    bedTime TIME NOT NULL,
    desiredWakeTime TIME NOT NULL,
    actualWakeTime TIME NOT NULL,
    sleepDuration INTERVAL HOUR TO MINUTE CHECK (sleepDuration >= INTERVAL '1 hour' AND sleepDuration <= INTERVAL '24 hours'),
    sleepQuality FLOAT CHECK (sleepQuality >= 0.0 AND sleepQuality <= 10.0)
);

/* Таблиця SleepPhase */
CREATE TABLE sleep_phase (
    phase_id SERIAL PRIMARY KEY,
    sleep_id INTEGER NOT NULL REFERENCES sleep(sleep_id),
    phaseName VARCHAR(20) NOT NULL CHECK (phaseName IN ('Light Sleep', 'Deep Sleep', 'REM Sleep')),
    phaseStart TIME NOT NULL,
    phaseEnd TIME NOT NULL,
    phaseDuration INTERVAL HOUR TO MINUTE CHECK (phaseDuration >= INTERVAL '1 minute' AND phaseDuration <= INTERVAL '8 hours'),
    sleepDepth VARCHAR(10) NOT NULL CHECK (sleepDepth IN ('Shallow', 'Medium', 'Deep'))
);

/* Таблиця Recommendation */
CREATE TABLE recommendation (
    recommendation_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES user(user_id),
    recommendationText VARCHAR(500) NOT NULL CHECK (regexp_like(recommendationText, '^[A-Za-zА-Яа-я0-9,.\-\s]{1,500}$')),
    category VARCHAR(30) NOT NULL CHECK (category IN ('Schedule', 'Nutrition', 'Physical Activity')),
    priority VARCHAR(10) NOT NULL CHECK (priority IN ('Low', 'Medium', 'High')),
    creationDate DATE DEFAULT CURRENT_DATE
);

/* Таблиця WakeUpAlarm */
CREATE TABLE wake_up_alarm (
    alarm_id SERIAL PRIMARY KEY,
    sleep_id INTEGER NOT NULL REFERENCES sleep(sleep_id),
    alarmTime TIME NOT NULL,
    alarmType VARCHAR(20) NOT NULL CHECK (alarmType IN ('Melody', 'Vibration', 'Light')),
    volume INTEGER CHECK (volume >= 1 AND volume <= 100),
    duration INTERVAL MINUTE TO SECOND CHECK (duration >= INTERVAL '30 seconds' AND duration <= INTERVAL '10 minutes')
);

/* Таблиця Workplace */
CREATE TABLE workplace (
    workplace_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES user(user_id),
    identifier VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    qrCode VARCHAR(255) UNIQUE NOT NULL,
    address VARCHAR(200),
    workType VARCHAR(20) NOT NULL CHECK (workType IN ('Office', 'Industrial', 'Laboratory'))
);

/* Таблиця Checklist */
CREATE TABLE checklist (
    checklist_id SERIAL PRIMARY KEY,
    workplace_id INTEGER NOT NULL REFERENCES workplace(workplace_id),
    checklistName VARCHAR(100) NOT NULL,
    creationDate DATE DEFAULT CURRENT_DATE,
    completionStatus VARCHAR(20) CHECK (completionStatus IN ('Not Started', 'In Progress', 'Completed')),
    completionPercentage FLOAT CHECK (completionPercentage >= 0.0 AND completionPercentage <= 100.0)
);

/* Таблиця SafetyRule */
CREATE TABLE safety_rule (
    rule_id SERIAL PRIMARY KEY,
    checklist_id INTEGER NOT NULL REFERENCES checklist(checklist_id),
    ruleName VARCHAR(100) NOT NULL,
    description VARCHAR(1000) NOT NULL,
    category VARCHAR(20) NOT NULL CHECK (category IN ('PPE', 'Behavior', 'Equipment')),
    mandatory BOOLEAN NOT NULL
);

/* Таблиця ProtectiveEquipment */
CREATE TABLE protective_equipment (
    equipment_id SERIAL PRIMARY KEY,
    workplace_id INTEGER NOT NULL REFERENCES workplace(workplace_id),
    equipmentName VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('Helmet', 'Glasses', 'Gloves', 'Respirator')),
    size VARCHAR(10),
    usageStatus VARCHAR(20) NOT NULL CHECK (usageStatus IN ('New', 'In Use', 'Needs Replacement')),
    expirationDate DATE NOT NULL CHECK (expirationDate >= CURRENT_DATE)
);

/* Таблиця Notification */
CREATE TABLE notification (
    notification_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES user(user_id),
    messageText VARCHAR(500) NOT NULL,
    notificationType VARCHAR(20) CHECK (notificationType IN ('Warning', 'Error', 'Information')),
    sendTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) CHECK (status IN ('Sent', 'Read', 'Processed'))
);

/* Таблиця RiskRemovalInstruction */
CREATE TABLE risk_removal_instruction (
    instruction_id SERIAL PRIMARY KEY,
    notification_id INTEGER REFERENCES notification(notification_id),
    equipment_id INTEGER REFERENCES protective_equipment(equipment_id),
    instructionText VARCHAR(1000) NOT NULL,
    steps TEXT NOT NULL,
    urgency VARCHAR(20) CHECK (urgency IN ('Immediate', 'Within Hour', 'Within Day')),
    executionStatus VARCHAR(20) CHECK (executionStatus IN ('Not Started', 'In Progress', 'Completed'))
);
