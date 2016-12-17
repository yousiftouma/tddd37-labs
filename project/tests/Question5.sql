insert into passenger (passport_number, name) values (1, "hej");
insert into contact (passport_number, email, phone_number) values (1, "r", 34);
insert into reservation(reservation_number, number_of_passengers, flight_number, contact) values (1, 1, 54, 1);
insert into passengers(reservation_number, passport_number) values (1, 1);
insert into credit_card(credit_card_number, holder) values (1, "hej");
insert into booking (reservation_number, paid_amount, credit_card) values (1, 10, 1); 

select * from ticket;
