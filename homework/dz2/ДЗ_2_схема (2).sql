-- Сначала выполнить ДЗ_1.sql.

BEGIN;
SET search_path TO hw_edtech;

CREATE TABLE IF NOT EXISTS payments (
    payment_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'paid', 'failed')),
    paid_at TIMESTAMP,
    UNIQUE (user_id, course_id),
    FOREIGN KEY (user_id, course_id)
        REFERENCES enrollments(user_id, course_id)
);

CREATE TABLE IF NOT EXISTS lesson_progress (
    progress_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    lesson_no INTEGER NOT NULL,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE (user_id, course_id, lesson_no),
    FOREIGN KEY (user_id, course_id)
        REFERENCES enrollments(user_id, course_id),
    FOREIGN KEY (course_id, lesson_no)
        REFERENCES lessons(course_id, lesson_no)
);

CREATE INDEX IF NOT EXISTS idx_payments_course
ON payments(course_id);

CREATE INDEX IF NOT EXISTS idx_progress_lesson
ON lesson_progress(course_id, lesson_no);

COMMIT;
