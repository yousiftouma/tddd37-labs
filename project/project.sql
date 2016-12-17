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
DROP PROCEDURE IF EXISTS addDestination;
DROP PROCEDURE IF EXISTS addRoute;
DROP PROCEDURE IF EXISTS addFlight;
DROP FUNCTION IF EXISTS calculateFreeSeats;
DROP FUNCTION IF EXISTS calculatePrice;
DROP TRIGGER IF EXISTS onBooking;

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

/*
  Table not in BCNF, enforce candidate key uniqueness
*/
ALTER TABLE route ADD UNIQUE unique_route(valid, departs_to, departs_from);

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

CREATE PROCEDURE addDestination(IN in_airport_code VARCHAR(3), IN in_name VARCHAR(30), IN in_country VARCHAR(30))
BEGIN
  INSERT INTO destination (airport_code, airport_name, country) values (in_airport_code, in_name, in_country);
END;//

CREATE PROCEDURE addRoute(IN in_departs_from VARCHAR(3), IN in_departs_to VARCHAR(3), IN in_valid INTEGER UNSIGNED, IN in_price DOUBLE UNSIGNED)
BEGIN
  INSERT INTO route (valid, departs_to, departs_from, price) values (in_valid, in_departs_to, in_departs_from, in_price);
END;//

CREATE PROCEDURE addFlight(IN in_departs_from VARCHAR(3), IN in_departs_to VARCHAR(3), IN in_year INTEGER UNSIGNED, IN in_day VARCHAR(10), IN in_departure_time TIME)
BEGIN
  DECLARE route_id INTEGER UNSIGNED;
  DECLARE departure_id INTEGER UNSIGNED;
  DECLARE week_nr INTEGER UNSIGNED;

  SELECT id INTO route_id FROM route WHERE valid = in_year and departs_to = in_departs_to and departs_from = in_departs_from;

  INSERT INTO weekly_departure (departure_time, day, year, route) values (in_departure_time, in_day, in_year, route_id);

  /*
    Insert a flight for every week of the year
  */
  SELECT LAST_INSERT_ID() INTO departure_id;
  SET week_nr = 1;
  REPEAT
    INSERT INTO flight (week, departure) values (week_nr, departure_id);
    SET week_nr = week_nr + 1;
  UNTIL week_nr > 52 
  END REPEAT;
END;//

CREATE FUNCTION calculateFreeSeats(in_flight_number INTEGER UNSIGNED) RETURNS INTEGER UNSIGNED
BEGIN
  RETURN (SELECT available_seats FROM flight WHERE flight_number = in_flight_number) - (SELECT COUNT(*) FROM ticket WHERE flight_number = in_flight_number);
END;//

CREATE FUNCTION calculatePrice(in_flight_number INTEGER UNSIGNED) RETURNS DOUBLE UNSIGNED
BEGIN
  DECLARE booked_seats INTEGER UNSIGNED;
  DECLARE departure INTEGER UNSIGNED;
  DECLARE route_price INTEGER UNSIGNED;
  DECLARE profit_factor INTEGER UNSIGNED;
  DECLARE weekday_factor INTEGER UNSIGNED;
  
  SET booked_seats = (SELECT COUNT(*) FROM ticket WHERE flight_number = in_flight_number);
  SET departure = (SELECT departure FROM flight WHERE flight_number = in_flight_number);
  SET route_price = (SELECT price FROM route WHERE id = (SELECT route FROM weekly_departure WHERE id = departure));
  SET profit_factor = (SELECT profit_factor FROM year WHERE year = (SELECT year FROM weekly_departure WHERE id = departure));
  SET weekday_factor = (SELECT weekday_factor FROM weekday WHERE (day, year) = (SELECT day, year from weekly_departure WHERE id = departure));

  RETURN route_price*weekday_factor*((booked_seats+1)/40)*profit_factor;
END;//


CREATE TRIGGER onBooking
AFTER INSERT ON booking
FOR EACH ROW
BEGIN
  DECLARE p_nr INTEGER UNSIGNED;
  DECLARE f_nr INTEGER UNSIGNED;
  DECLARE passenger_index INTEGER UNSIGNED;
  DECLARE num_passengers INTEGER UNSIGNED;
  DECLARE unguessable_id INTEGER UNSIGNED;
  DECLARE found_unique BOOLEAN;

  SELECT flight_number INTO f_nr FROM reservation WHERE reservation_number = NEW.reservation_number;
  SELECT COUNT(*) INTO num_passengers from passengers;
  SET passenger_index = 0;

  REPEAT
    IF (SELECT COUNT(*) from passengers WHERE reservation_number = NEW.reservation_number LIMIT passenger_index, 1) = 1
      THEN
        SELECT passport_number INTO p_nr from passengers WHERE reservation_number = NEW.reservation_number LIMIT passenger_index, 1;
        SET found_unique = false;
    	REPEAT
          SET unguessable_id = FLOOR(RAND() * 9999999);
      	    IF (SELECT COUNT(*) FROM ticket WHERE id = unguessable_id) = 0
      	    THEN
              SET found_unique = true;
            END IF;
          UNTIL found_unique = true
        END REPEAT; 
    	INSERT INTO ticket (id, passport_number, flight_number) VALUES (unguessable_id, p_nr, f_nr);
        SET passenger_index = passenger_index + 1;
    END IF;
  UNTIL passenger_index >= num_passengers
  END REPEAT;
END;//

delimiter ;
