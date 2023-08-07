-- create database
USE master;
GO

DROP DATABASE IF EXISTS test_tasks
CREATE DATABASE test_tasks;
go

USE test_tasks;
GO

CREATE SCHEMA smpl;
GO

DROP TABLE IF EXISTS smpl.clients;
CREATE TABLE smpl.clients
(
    _key INTEGER IDENTITY(1,1),
    client_id INTEGER,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    country_code CHAR(2) NOT NULL,
    country_name VARCHAR(255), 
    city VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    CONSTRAINT clients_pkey PRIMARY KEY (_key)
);


DROP TABLE IF EXISTS smpl.articles;
CREATE TABLE smpl.articles
(
    _key INTEGER IDENTITY(1,1),
    article_id INTEGER,
    name VARCHAR(200) NOT NULL,
    country_code CHAR(2),
    country_name VARCHAR(255),
    description text,
    price FLOAT(2) NOT NULL,
    valid_from DATETIME NOT NULL DEFAULT(CURRENT_TIMESTAMP),
    valid_to DATETIME NOT NULL DEFAULT('9999-12-31 23:59:59'),
    CONSTRAINT articles_pkey PRIMARY KEY (_key)
);


DROP TABLE IF EXISTS smpl.transactions;
CREATE TABLE smpl.transactions
(   
    _key INTEGER IDENTITY(1,1),
    t_id INTEGER,
    creation_timestamp DATETIME NOT NULL DEFAULT(CURRENT_TIMESTAMP),
    client_key INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    article_key INTEGER NOT NULL,
    article_id INTEGER NOT NULL,
    amount INTEGER NOT NULL DEFAULT 1,
    year             AS DATEPART(year, [creation_timestamp]),
    quarter          AS DATEPART(quarter, [creation_timestamp]),
    month_number     AS DATEPART(month, [creation_timestamp]),
    week_number      AS DATEPART(week, [creation_timestamp]),
    weekday_number   AS DATEPART(weekday, [creation_timestamp]),
    hour             AS DATEPART(hour, [creation_timestamp]),
    minute           AS DATEPART(minute, [creation_timestamp]),
	second           AS DATEPART(second, [creation_timestamp]),
    CONSTRAINT transactions_pkey PRIMARY KEY (_key),
    CONSTRAINT FK_client_key FOREIGN KEY (client_key) REFERENCES [smpl].[clients]([_key]),
    CONSTRAINT FK_article_key FOREIGN KEY (article_key) REFERENCES [smpl].[articles]([_key]),
);
