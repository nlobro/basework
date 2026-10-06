-- Сначала выполнить ДЗ_1.sql и ДЗ_2_схема.sql.

BEGIN;
SET LOCAL search_path TO hw_edtech;
SET LOCAL client_min_messages TO NOTICE;

INSERT INTO users (user_id, full_name, email) VALUES
    (-1, 'Анна', 'teacher@example.com'),
    (-2, 'Олег', 'student@example.com');

INSERT INTO courses (course_id, teacher_id, title, price, teacher_rate)
VALUES (-1, -1, 'Основы SQL', 3000, 0.7);

INSERT INTO lessons (course_id, lesson_no, title)
VALUES (-1, 1, 'Введение');

INSERT INTO enrollments (user_id, course_id, price_paid)
VALUES (-2, -1, 3000);

-- 1. CHECK
DO $$
BEGIN
    INSERT INTO reviews (user_id, course_id, rating)
    VALUES (-2, -1, 6);
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'Оценка курса должна быть от 1 до 5. Текст ошибки: %', SQLERRM;
END;
$$;

-- 2. FOREIGN KEY
DO $$
BEGIN
    INSERT INTO lessons (course_id, lesson_no, title)
    VALUES (-999, 1, 'Введение');
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Нельзя добавить урок к несуществующему курсу. Текст ошибки: %', SQLERRM;
END;
$$;

-- 3. UNIQUE
DO $$
BEGIN
    INSERT INTO users (full_name, email)
    VALUES ('Иван', 'student@example.com');
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Пользователь с такой почтой уже зарегистрирован. Текст ошибки: %', SQLERRM;
END;
$$;

-- 4. NOT NULL
DO $$
BEGIN
    INSERT INTO users (full_name, email)
    VALUES (NULL, 'new@example.com');
EXCEPTION
    WHEN not_null_violation THEN
        RAISE NOTICE 'При регистрации нужно указать имя. Текст ошибки: %', SQLERRM;
END;
$$;

-- 5. PRIMARY KEY
DO $$
BEGIN
    INSERT INTO lessons (course_id, lesson_no, title)
    VALUES (-1, 1, 'Повтор');
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'В курсе уже есть урок с таким номером. Текст ошибки: %', SQLERRM;
END;
$$;

ROLLBACK;
