BEGIN;

DROP SCHEMA IF EXISTS hw_edtech CASCADE;
CREATE SCHEMA hw_edtech;
SET search_path TO hw_edtech;

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(254) NOT NULL UNIQUE,
    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    teacher_id INTEGER NOT NULL REFERENCES users(user_id),
    title VARCHAR(200) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    teacher_rate DECIMAL(4,2) NOT NULL CHECK (teacher_rate BETWEEN 0 AND 1)
);

CREATE INDEX idx_courses_teacher
ON courses(teacher_id);

CREATE TABLE lessons (
    course_id INTEGER NOT NULL REFERENCES courses(course_id),
    lesson_no INTEGER NOT NULL CHECK (lesson_no > 0),
    title VARCHAR(200) NOT NULL,
    content TEXT,
    PRIMARY KEY (course_id, lesson_no)
);

CREATE TABLE enrollments (
    user_id INTEGER NOT NULL REFERENCES users(user_id),
    course_id INTEGER NOT NULL REFERENCES courses(course_id),
    enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    price_paid DECIMAL(10,2) NOT NULL CHECK (price_paid >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'completed')),
    completed_at TIMESTAMP,
    PRIMARY KEY (user_id, course_id)
);

CREATE INDEX idx_enrollments_course
ON enrollments(course_id);

CREATE TABLE reviews (
    user_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CONSTRAINT reviews_rating_check
        CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, course_id),
    FOREIGN KEY (user_id, course_id)
        REFERENCES enrollments(user_id, course_id)
);

CREATE INDEX idx_reviews_course
ON reviews(course_id);

COMMIT;
