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
DROP PROCEDURE IF EXISTS addReservation;
DROP PROCEDURE IF EXISTS addPassenger;
DROP PROCEDURE IF EXISTS addContact;
DROP PROCEDURE IF EXISTS addPayment;
DROP FUNCTION IF EXISTS calculateFreeSeats;
DROP FUNCTION IF EXISTS calculatePrice;
DROP TRIGGER IF EXISTS onBooking;

DROP VIEW IF EXISTS allFlights;

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
  contact INTEGER UNSIGNED,
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
  DECLARE departure_id INTEGER UNSIGNED;
  DECLARE route_price DOUBLE;
  DECLARE profit_fctr DOUBLE;
  DECLARE weekday_fctr DOUBLE;

  SELECT COUNT(*) INTO booked_seats FROM ticket WHERE flight_number = in_flight_number;
  SELECT departure INTO departure_id FROM flight WHERE flight_number = in_flight_number;
  SELECT price INTO route_price FROM route WHERE id = (SELECT route FROM weekly_departure WHERE id = departure_id);
  SELECT profit_factor INTO profit_fctr FROM year WHERE year = (SELECT year FROM weekly_departure WHERE id = departure_id);
  SELECT weekday_factor INTO weekday_fctr FROM weekday WHERE (day, year) = (SELECT day, year from weekly_departure WHERE id = departure_id);
  RETURN route_price*weekday_fctr*profit_fctr*((booked_seats+1)/40);
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
    IF EXISTS (SELECT * from passengers WHERE reservation_number = NEW.reservation_number LIMIT passenger_index, 1)
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
    END IF;
    SET passenger_index = passenger_index + 1;
  UNTIL passenger_index >= num_passengers
  END REPEAT;
END;//

CREATE PROCEDURE addReservation(IN in_departs_from VARCHAR(3), IN in_departs_to VARCHAR(3), IN in_year INTEGER UNSIGNED, IN in_week INTEGER UNSIGNED, IN in_day VARCHAR(10), IN in_departure_time TIME, IN in_number_of_passengers INTEGER UNSIGNED, OUT output_reservation_nr INTEGER UNSIGNED)
BEGIN
  DECLARE flight_nr INTEGER UNSIGNED;
  DECLARE unguessable_id INTEGER UNSIGNED;
  DECLARE found_unique BOOLEAN;

  SELECT flight_number INTO flight_nr FROM flight WHERE 
	in_week = week AND 
	departure = 
		(SELECT id FROM weekly_departure WHERE 
			departure_time = in_departure_time AND 
			day = in_day AND 
			year = in_year AND 
			route = 
				(SELECT id FROM route WHERE in_departs_from = departs_from AND in_departs_to = departs_to AND valid = in_year)
		)
  ;
  IF NOT (flight_nr IS NULL)
  THEN
    IF (calculateFreeSeats(flight_nr)>= in_number_of_passengers)
    THEN
        SET found_unique = false;
    	REPEAT
          SET unguessable_id = FLOOR(RAND() * 9999999);
      	    IF (SELECT COUNT(*) FROM reservation WHERE reservation_number = unguessable_id) = 0
      	    THEN
              SET found_unique = true;
            END IF;
          UNTIL found_unique = true
        END REPEAT; 
    	INSERT INTO reservation (reservation_number, number_of_passengers, flight_number) VALUES (unguessable_id, in_number_of_passengers, flight_nr);
	SET output_reservation_nr = unguessable_id;
    ELSE
     SELECT "There are not enough seats available on the chosen flight" AS "Message";
    END IF;
  ELSE
   SELECT "There exist no flight for the given route, date and time" AS "Message";
  END IF;
END;//

/* We assume that adding more passengers than number_of_passengers is not allowed, therefor we issue a error */
CREATE PROCEDURE addPassenger(IN in_reservation_nr INTEGER UNSIGNED, IN in_passport_nr INTEGER UNSIGNED, IN in_name VARCHAR(30))
BEGIN

  IF EXISTS (SELECT reservation_number FROM reservation WHERE reservation_number = in_reservation_nr)
  THEN
    IF NOT EXISTS (select * FROM booking WHERE reservation_number = in_reservation_nr)
    THEN
      IF ((SELECT COUNT(*) FROM passengers WHERE reservation_number = in_reservation_nr) < 
		(SELECT number_of_passengers FROM reservation WHERE reservation_number = in_reservation_nr))
      THEN
        IF NOT EXISTS (SELECT * FROM passenger WHERE passport_number = in_passport_nr)
        THEN
      	  INSERT INTO passenger (passport_number, name) VALUES (in_passport_nr, in_name);
        END IF;
        INSERT INTO passengers (reservation_number, passport_number) VALUES (in_reservation_nr, in_passport_nr);
      ELSE
        SELECT "The given reservation cannot hold more passengers" AS "Message";
      END IF;
    ELSE
      SELECT "The booking has already been payed and no futher passengers can be added" AS "Message";
    END IF;
  ELSE
    SELECT "The given reservation number does not exist" AS "Message";
  END IF;
END;//

CREATE PROCEDURE addContact(IN in_reservation_nr INTEGER UNSIGNED, IN in_passport_number INTEGER UNSIGNED, IN in_email VARCHAR(30), IN in_phone BIGINT)
BEGIN

  IF EXISTS (SELECT reservation_number FROM reservation WHERE reservation_number = in_reservation_nr)
  THEN
    IF EXISTS(SELECT * from passengers WHERE passport_number = in_passport_number AND reservation_number = in_reservation_nr)
    THEN
      IF NOT EXISTS (SELECT * FROM contact WHERE passport_number = in_passport_number)
      THEN
      	INSERT INTO contact (passport_number, email, phone_number) VALUES (in_passport_number, in_email, in_phone);
      END IF;
      UPDATE reservation SET contact = in_passport_number WHERE reservation_number = in_reservation_nr;
    ELSE
      SELECT "The person is not a passenger of the reservation" AS "Message";
    END IF;
  ELSE
    SELECT "The given reservation number does not exist" AS "Message";
  END IF;
END;//

CREATE PROCEDURE addPayment(IN in_reservation_nr INTEGER UNSIGNED, IN in_cardholder_name VARCHAR(30), IN in_credit_card_number BIGINT)
BEGIN
  DECLARE amount DOUBLE;
  DECLARE flight_nr INTEGER UNSIGNED;
  DECLARE number_of_passengers INTEGER UNSIGNED;
  IF EXISTS (SELECT reservation_number FROM reservation WHERE reservation_number = in_reservation_nr)
  THEN
    IF NOT (SELECT contact FROM reservation WHERE reservation_number = in_reservation_nr) IS NULL
    THEN
      SELECT flight_number INTO flight_nr FROM reservation WHERE reservation_number = in_reservation_nr; 
      SELECT COUNT(*) INTO number_of_passengers FROM passengers WHERE reservation_number = in_reservation_nr;
      IF (calculateFreeSeats(flight_nr) >= number_of_passengers)
      THEN
      	IF NOT EXISTS (SELECT * FROM credit_card WHERE credit_card_number = in_credit_card_number)
      	THEN
      	  INSERT INTO credit_card (credit_card_number, holder) VALUES (in_credit_card_number, in_cardholder_name);
      	END IF;
      	SET amount = calculatePrice(flight_nr) * number_of_passengers;
      	INSERT INTO booking (reservation_number, paid_amount, credit_card) VALUES (in_reservation_nr, amount, in_credit_card_number);
      ELSE
        SELECT "There are not enough seats available on the flight anymore, deleting reservation" AS "Message";
        DELETE FROM passengers WHERE reservation_number = in_reservation_nr;
        DELETE FROM reservation WHERE reservation_number = in_reservation_nr;
      END IF;
    ELSE
      SELECT "The reservation has no contact yet" AS "Message";
    END IF;
  ELSE
    SELECT "The given reservation number does not exist" AS "Message";
  END IF;
END;//

delimiter ;

CREATE VIEW allFlights(
		departure_city_name,
		destination_city_name, 
		departure_time, 
		departure_day, 
		departure_week,
 		departure_year,
		nr_of_free_seats,
		current_price_per_seat
	)
	AS 
	SELECT 
		destF.airport_name, 
		destT.airport_name, 
		dep.departure_time, 
		dep.day, 
		fli.week, 
		dep.year, 
		calculateFreeSeats(fli.flight_number),
		calculatePrice(fli.flight_number)
		FROM flight AS fli
	INNER JOIN weekly_departure AS dep ON fli.departure = dep.id
	INNER JOIN destination AS destT ON destT.airport_code = (SELECT departs_to FROM route WHERE id = dep.route)
	INNER JOIN destination AS destF ON destF.airport_code = (SELECT departs_from FROM route WHERE id = dep.route)
;
