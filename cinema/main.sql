
CREATE DATABASE Кинотеатр;
USE Кинотеатр;

CREATE TABLE режиссер (
    ID_режиссера INT PRIMARY KEY AUTO_INCREMENT,
    ФИО VARCHAR(70)
);

CREATE TABLE фильм (
    ID_фильма INT PRIMARY KEY AUTO_INCREMENT,
    название VARCHAR(100),
    жанр VARCHAR(50),
    продолжительность INT, -- в минутах
    ID_режиссера INT,
    FOREIGN KEY (ID_режиссера) REFERENCES режиссер(ID_режиссера)
);

CREATE TABLE кинотеатр (
    ID_кинотеатра INT PRIMARY KEY AUTO_INCREMENT,
    название VARCHAR(100),
    адрес VARCHAR(255),
    телефон VARCHAR(20),
    число_залов INT
);

CREATE TABLE зал (
    ID_зала INT PRIMARY KEY AUTO_INCREMENT,
    ID_кинотеатра INT,
    номер_зала INT,
    экран VARCHAR(50),
    посадка INT,
    FOREIGN KEY (ID_кинотеатра) REFERENCES кинотеатр(ID_кинотеатра)
);

CREATE TABLE Тариф (
    ID_тарифа INT PRIMARY KEY AUTO_INCREMENT,
    название VARCHAR(50), -- взрослый/детский/студенческий/льготный
    цена DECIMAL(10, 2)
);

-- Создание таблицы Сеанс
CREATE TABLE Сеанс (
    ID_сеанса INT PRIMARY KEY AUTO_INCREMENT,
    ID_фильма INT,
    ID_зала INT,
    дата_время DATETIME,
    FOREIGN KEY (ID_фильма) REFERENCES фильм(ID_фильма),
    FOREIGN KEY (ID_зала) REFERENCES зал(ID_зала)
);

CREATE TABLE пользователь (
    ID_пользователя INT PRIMARY KEY AUTO_INCREMENT,
    карта_лояльности VARCHAR(50),
    баллы DECIMAL(10, 2) DEFAULT 0.00,
    ФИО VARCHAR(100),
    почта VARCHAR(100),
    номер VARCHAR(20),
    дата_рождения DATE
);

CREATE TABLE билет (
    ID_билета INT PRIMARY KEY AUTO_INCREMENT,
    ID_сеанса INT,
    ID_пользователя INT, -- Добавлено для связи с пользователем
    ряд_место INT,
    статус ENUM('продан', 'доступен'),
    ID_тарифа INT,
    FOREIGN KEY (ID_сеанса) REFERENCES сеанс(ID_сеанса),
    FOREIGN KEY (ID_тарифа) REFERENCES тариф(ID_тарифа),
    FOREIGN KEY (ID_пользователя) REFERENCES пользователь(ID_пользователя)
);


-- Задание 1

SELECT 
    r.ФИО AS Режиссер,
    k.название AS Кинотеатр,
    z.номер_зала AS Номер_зала,
    s.дата_время AS Дата_и_время_сеанса,
    t.цена AS Цена
FROM 
    сеанс s
JOIN 
    фильм f ON s.ID_фильма = f.ID_фильма
JOIN 
    режиссер r ON f.ID_режиссера = r.ID_режиссера
JOIN 
    зал z ON s.ID_зала = z.ID_зала
JOIN 
    кинотеатр k ON z.ID_кинотеатра = k.ID_кинотеатра
JOIN 
    билет b ON s.ID_сеанса = b.ID_сеанса
JOIN 
    тариф t ON b.ID_тарифа = t.ID_тарифа
WHERE 
    s.дата_время = '2024-08-09 10:00:00' -- Задайте нужную дату и время
    AND t.название = 'взрослый'; 

-- Задание 2
  
SELECT 
    z.ID_зала, 
    COUNT(CASE WHEN b.статус = 'продан' THEN b.ID_билета END) AS Количество_проданных_билетов,
    COUNT(b.ID_билета) AS Количество_доступных_билетов
FROM 
    зал z
LEFT JOIN 
    сеанс s ON z.ID_зала = s.ID_зала
LEFT JOIN 
    билет b ON s.ID_сеанса = b.ID_сеанса
WHERE 
    s.дата_время >= '2024-09-01 00:00:00' 
    AND s.дата_время < '2024-10-01 00:00:00' -- За сентябрь 2024
GROUP BY 
    z.ID_зала;

-- Задание 3
-- Вывести режиссера (или режиссеров) с наибольшей продолжительностью сеансов за сутки

SELECT 
    r.ФИО AS Режиссер,
    SUM(f.продолжительность)
    -- f.продолжительность * COUNT(s.ID_сеанса) AS Общая_продолжительность
FROM 
    сеанс s
JOIN 
    фильм f ON s.ID_фильма = f.ID_фильма
JOIN 
    режиссер r ON f.ID_режиссера = r.ID_режиссера
WHERE 
    DATE(s.дата_время) = '2024-09-24'
GROUP BY 
    r.ID_режиссера
ORDER BY 
    Общая_продолжительность DESC
LIMIT 1; -- Получаем только одного режиссера с наибольшей продолжительностью
