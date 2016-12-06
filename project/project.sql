/* Drop all tables and procedures */
DROP TABLE IF EXISTS ticket;
DROP TABLE IF EXISTS booking;
DROP TABLE IF EXISTS passengers;
DROP TABLE IF EXISTS credit_card;
DROP TABLE IF EXISTS reservation;
DROP TABLE IF EXISTS contact;
DROP TABLE IF EXISTS passenger;
DROP TABLE IF EXISTS flight;
DROP TABLE IF EXISTS weekly_departure;
DROP TABLE IF EXISTS route;
DROP TABLE IF EXISTS destination;
DROP TABLE IF EXISTS weekday;
DROP TABLE IF EXISTS year;

DROP PROCEDURE IF EXISTS addYear;
DROP PROCEDURE IF EXISTS addDay;

/* Create all neccessary tables */
CREATE TABLE IF NOT EXISTS year (
  year INTEGER UNSIGNED NOT NULL,
  profit_factor DOUBLE NOT NULL,
  CONSTRAINT pk_year PRIMARY KEY (year)
);

CREATE TABLE IF NOT EXISTS destination (
  airport_code VARCHAR(3) NOT NULL,
  airport_name VARCHAR(30) NOT NULL,
  country VARCHAR(30) NOT NULL,
  CONSTRAINT pk_airport_code PRIMARY KEY (airport_code)
);

CREATE TABLE IF NOT EXISTS route (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  valid INTEGER UNSIGNED NOT NULL,
  departs_to VARCHAR(3) NOT NULL,
  departs_from VARCHAR(3) NOT NULL,
  price DOUBLE UNSIGNED NOT NULL,
  CONSTRAINT pk_id PRIMARY KEY (id),
  CONSTRAINT fk_valid FOREIGN KEY (valid) REFERENCES year(year),
  CONSTRAINT fk_departs_to FOREIGN KEY (departs_to) REFERENCES destination(airport_code),
  CONSTRAINT fk_departs_from FOREIGN KEY (departs_from) REFERENCES destination(airport_code)
);

CREATE TABLE IF NOT EXISTS weekday (
  day VARCHAR(10) NOT NULL,
  year INTEGER UNSIGNED NOT NULL,
  weekday_factor DOUBLE UNSIGNED NOT NULL,
  CONSTRAINT pk_weekday PRIMARY KEY (day, year),
  CONSTRAINT fk_year FOREIGN KEY (year) REFERENCES year(year)
);

CREATE TABLE IF NOT EXISTS weekly_departure (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  departure_time TIME NOT NULL,
  day VARCHAR(10) NOT NULL,
  year INTEGER UNSIGNED NOT NULL,
  route INTEGER UNSIGNED NOT NULL,
  CONSTRAINT pk_id PRIMARY KEY (id),
  CONSTRAINT fk_weekday FOREIGN KEY (day, year) REFERENCES weekday(day, year),
  CONSTRAINT fk_route FOREIGN KEY (route) REFERENCES route(id)
);

CREATE TABLE IF NOT EXISTS flight (
  flight_number INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  week INTEGER UNSIGNED NOT NULL,
  available_seats INTEGER UNSIGNED NOT NULL DEFAULT 40,
  departure INTEGER UNSIGNED NOT NULL,
  CONSTRAINT pk_flight_number PRIMARY KEY (flight_number),
  CONSTRAINT fk_weekly_departure FOREIGN KEY (departure) REFERENCES weekly_departure(id)
);

CREATE TABLE IF NOT EXISTS passenger (
  passport_number INTEGER UNSIGNED NOT NULL,
  name VARCHAR(30) NOT NULL,
  CONSTRAINT pk_passport_number PRIMARY KEY (passport_number)
);

CREATE TABLE IF NOT EXISTS ticket (
  id INTEGER UNSIGNED NOT NULL,
  passport_number INTEGER UNSIGNED NOT NULL,
  flight_number INTEGER UNSIGNED NOT NULL,
  CONSTRAINT pk_id PRIMARY KEY (id),
  CONSTRAINT fk_passport_number FOREIGN KEY (passport_number) REFERENCES passenger(passport_number),
  CONSTRAINT fk_ticket_flight_number FOREIGN KEY (flight_number) REFERENCES flight(flight_number)
);

CREATE TABLE IF NOT EXISTS contact (
  passport_number INTEGER UNSIGNED NOT NULL,
  email VARCHAR(30) NOT NULL,
  phone_number BIGINT NOT NULL,
  CONSTRAINT pk_passport_number PRIMARY KEY (passport_number),
  CONSTRAINT fk_contact_passport_number FOREIGN KEY (passport_number) REFERENCES passenger(passport_number)
);

CREATE TABLE IF NOT EXISTS reservation (
  reservation_number INTEGER UNSIGNED NOT NULL,
  number_of_passengers INTEGER UNSIGNED NOT NULL,
  flight_number INTEGER UNSIGNED NOT NULL,
  contact INTEGER UNSIGNED NOT NULL,
  CONSTRAINT pk_reservation_number PRIMARY KEY (reservation_number),
  CONSTRAINT fk_flight_number FOREIGN KEY (flight_number) REFERENCES flight(flight_number),
  CONSTRAINT fk_contact FOREIGN KEY (contact) REFERENCES contact(passport_number)
);


CREATE TABLE IF NOT EXISTS passengers (
  reservation_number INTEGER UNSIGNED NOT NULL,
  passport_number INTEGER UNSIGNED NOT NULL,
  CONSTRAINT pk_passengers PRIMARY KEY (reservation_number, passport_number),
  CONSTRAINT fk_passengers_reservation_number FOREIGN KEY (reservation_number) REFERENCES reservation(reservation_number),
  CONSTRAINT fk_passengers_passport_number FOREIGN KEY (passport_number) REFERENCES passenger(passport_number)
);

CREATE TABLE IF NOT EXISTS credit_card (
  credit_card_number BIGINT UNSIGNED NOT NULL,
  holder VARCHAR(30) NOT NULL,
  CONSTRAINT pk_credit_card_number PRIMARY KEY (credit_card_number)
);

CREATE TABLE IF NOT EXISTS booking (
  reservation_number INTEGER UNSIGNED NOT NULL,
  paid_amount DOUBLE UNSIGNED NOT NULL,
  credit_card BIGINT UNSIGNED NOT NULL,
  CONSTRAINT pk_reservation_number PRIMARY KEY (reservation_number),
  CONSTRAINT fk_booking_number FOREIGN KEY (reservation_number) REFERENCES reservation(reservation_number),
  CONSTRAINT fk_credit_card FOREIGN KEY (credit_card) REFERENCES credit_card(credit_card_number)
);

/* Define all procedures */
delimiter //

CREATE PROCEDURE addYear(IN in_year INTEGER UNSIGNED, IN in_factor DOUBLE)
BEGIN
	INSERT INTO year (year,profit_factor) values (in_year, in_factor);
END;//

CREATE PROCEDURE addDay(IN in_year INTEGER UNSIGNED, IN in_day VARCHAR(10), IN in_factor DOUBLE)
BEGIN
	INSERT INTO weekday (year, day, weekday_factor) values (in_year, in_day, in_factor);
END;//





delimiter ;