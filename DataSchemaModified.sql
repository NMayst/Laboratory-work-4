/* Видалення таблиць з урахуванням зовнішніх ключів */
DROP TABLE IF EXISTS risk_removal_instruction CASCADE;
DROP TABLE IF EXISTS notification CASCADE;
DROP TABLE IF EXISTS protective_equipment CASCADE;
DROP TABLE IF EXISTS safety_rule CASCADE;
DROP TABLE IF EXISTS checklist CASCADE;
DROP TABLE IF EXISTS workplace CASCADE;
DROP TABLE IF EXISTS wake_up_alarm CASCADE;
DROP TABLE IF EXISTS recommendation CASCADE;
DROP TABLE IF EXISTS sleep_phase CASCADE;
DROP TABLE IF EXISTS sleep CASCADE;
DROP TABLE IF EXISTS app_user CASCADE;

/* Таблиця app_user (замість user - уникаємо зарезервованого слова) */
CREATE TABLE app_user (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL CHECK (name ~ '^[A-ZА-Я][a-zа-я\- ]{1,49}$'),
    age INTEGER NOT NULL CHECK (age BETWEEN 16 AND 100),
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('Male', 'Female', 'Other'))
);

/* Таблиця sleep */
CREATE TABLE sleep (
    sleep_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES app_user (user_id),
    sleep_date DATE NOT NULL CHECK (sleep_date <= CURRENT_DATE),
    bed_time TIME NOT NULL,
    desired_wake_time TIME NOT NULL,
    actual_wake_time TIME NOT NULL,
    sleep_duration INTERVAL NOT NULL,
    sleep_quality REAL CHECK (sleep_quality >= 0.0 AND sleep_quality <= 10.0)
);

/* Таблиця sleep_phase */
CREATE TABLE sleep_phase (
    phase_id SERIAL PRIMARY KEY,
    sleep_id INTEGER NOT NULL REFERENCES sleep (sleep_id),
    phase_name VARCHAR(20) NOT NULL CHECK (
        phase_name IN (
            'Light Sleep',
            'Deep Sleep',
            'REM Sleep'
        )
    ),
    phase_start TIME NOT NULL,
    phase_end TIME NOT NULL,
    phase_duration INTERVAL NOT NULL,
    sleep_depth VARCHAR(10) NOT NULL CHECK (
        sleep_depth IN (
            'Shallow',
            'Medium',
            'Deep'
        )
    )
);

/* Таблиця recommendation */
CREATE TABLE recommendation (
    recommendation_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES app_user (user_id),
    recommendation_text VARCHAR(500) NOT NULL CHECK (
        recommendation_text ~ '^[A-Za-zА-Яа-я0-9,.\-\s]{1,500}$'
    ),
    category VARCHAR(30) NOT NULL CHECK (
        category IN (
            'Schedule',
            'Nutrition',
            'Physical Activity'
        )
    ),
    priority VARCHAR(10) NOT NULL CHECK (priority IN ('Low', 'Medium', 'High')),
    creation_date DATE DEFAULT CURRENT_DATE
);

/* Таблиця wake_up_alarm */
CREATE TABLE wake_up_alarm (
    alarm_id SERIAL PRIMARY KEY,
    sleep_id INTEGER NOT NULL REFERENCES sleep (sleep_id),
    alarm_time TIME NOT NULL,
    alarm_type VARCHAR(20) NOT NULL CHECK (
        alarm_type IN (
            'Melody',
            'Vibration',
            'Light'
        )
    ),
    volume INTEGER CHECK (volume >= 1 AND volume <= 100),
    duration INTERVAL NOT NULL
);

/* Таблиця workplace */
CREATE TABLE workplace (
    workplace_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES app_user (user_id),
    identifier VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    qr_code VARCHAR(255) UNIQUE NOT NULL,
    address VARCHAR(200),
    work_type VARCHAR(20) NOT NULL CHECK (
        work_type IN (
            'Office',
            'Industrial',
            'Laboratory'
        )
    )
);

/* Таблиця checklist */
CREATE TABLE checklist (
    checklist_id SERIAL PRIMARY KEY,
    workplace_id INTEGER NOT NULL REFERENCES workplace (workplace_id),
    checklist_name VARCHAR(100) NOT NULL,
    creation_date DATE DEFAULT CURRENT_DATE,
    completion_status VARCHAR(20) CHECK (
        completion_status IN (
            'Not Started',
            'In Progress',
            'Completed'
        )
    ),
    completion_percentage REAL CHECK (
        completion_percentage >= 0.0 AND completion_percentage <= 100.0
    )
);

/* Таблиця safety_rule */
CREATE TABLE safety_rule (
    rule_id SERIAL PRIMARY KEY,
    checklist_id INTEGER NOT NULL REFERENCES checklist (checklist_id),
    rule_name VARCHAR(100) NOT NULL,
    description VARCHAR(1000) NOT NULL,
    category VARCHAR(20) NOT NULL CHECK (
        category IN (
            'PPE',
            'Behavior',
            'Equipment'
        )
    ),
    mandatory BOOLEAN NOT NULL
);

/* Таблиця protective_equipment */
CREATE TABLE protective_equipment (
    equipment_id SERIAL PRIMARY KEY,
    workplace_id INTEGER NOT NULL REFERENCES workplace (workplace_id),
    equipment_name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (
        type IN (
            'Helmet',
            'Glasses',
            'Gloves',
            'Respirator'
        )
    ),
    size VARCHAR(10),
    usage_status VARCHAR(20) NOT NULL CHECK (
        usage_status IN (
            'New',
            'In Use',
            'Needs Replacement'
        )
    ),
    expiration_date DATE NOT NULL CHECK (expiration_date >= CURRENT_DATE)
);

/* Таблиця notification */
CREATE TABLE notification (
    notification_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES app_user (user_id),
    message_text VARCHAR(500) NOT NULL,
    notification_type VARCHAR(20) CHECK (
        notification_type IN (
            'Warning',
            'Error',
            'Information'
        )
    ),
    send_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) CHECK (status IN ('Sent', 'Read', 'Processed'))
);

/* Таблиця risk_removal_instruction */
CREATE TABLE risk_removal_instruction (
    instruction_id SERIAL PRIMARY KEY,
    notification_id INTEGER REFERENCES notification (notification_id),
    equipment_id INTEGER REFERENCES protective_equipment (equipment_id),
    instruction_text VARCHAR(1000) NOT NULL,
    steps TEXT NOT NULL,
    urgency VARCHAR(20) CHECK (
        urgency IN (
            'Immediate',
            'Within Hour',
            'Within Day'
        )
    ),
    execution_status VARCHAR(20) CHECK (
        execution_status IN (
            'Not Started',
            'In Progress',
            'Completed'
        )
    )
);
