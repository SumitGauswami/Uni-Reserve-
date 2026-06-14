CREATE SCHEMA event_management;
SET search_path TO event_management;

CREATE TABLE USER_TABLE (
    user_id BIGINT PRIMARY KEY,
    user_name VARCHAR(255),
    designation VARCHAR(255)
);

CREATE TABLE USER_AUTH (
    user_id BIGINT PRIMARY KEY,
    hashed_password VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES USER_TABLE(user_id)
);

CREATE TABLE ROOM (
    room_id BIGINT PRIMARY KEY,
    room_name VARCHAR(255),
    capacity BIGINT
);

CREATE TABLE GROUP_TABLE (
    group_id BIGINT PRIMARY KEY,
    group_name VARCHAR(255)
);

CREATE TABLE EVENT (
    event_id BIGINT PRIMARY KEY,
    event_name VARCHAR(255),
    start_datetime TIMESTAMP,
    end_datetime TIMESTAMP,
    room_id BIGINT,
    creator_id BIGINT,
    FOREIGN KEY (room_id) REFERENCES ROOM(room_id),
    FOREIGN KEY (creator_id) REFERENCES USER_TABLE(user_id)
);

CREATE TABLE GROUP_MEMBER (
    group_id BIGINT,
    user_id BIGINT,
    PRIMARY KEY (group_id, user_id),
    FOREIGN KEY (group_id) REFERENCES GROUP_TABLE(group_id),
    FOREIGN KEY (user_id) REFERENCES USER_TABLE(user_id)
);

CREATE TABLE GROUP_SUPERVISOR (
    group_id BIGINT,
    user_id BIGINT,
    PRIMARY KEY (group_id, user_id),
    FOREIGN KEY (group_id) REFERENCES GROUP_TABLE(group_id),
    FOREIGN KEY (user_id) REFERENCES USER_TABLE(user_id)
);

CREATE TABLE GROUP_REPRESENTATIVE (
    group_id BIGINT,
    user_id BIGINT,
    PRIMARY KEY (group_id, user_id),
    FOREIGN KEY (group_id) REFERENCES GROUP_TABLE(group_id),
    FOREIGN KEY (user_id) REFERENCES USER_TABLE(user_id)
);

CREATE TABLE ROOM_REPRESENTATIVE (
    room_id BIGINT,
    user_id BIGINT,
    PRIMARY KEY (room_id, user_id),
    FOREIGN KEY (room_id) REFERENCES ROOM(room_id),
    FOREIGN KEY (user_id) REFERENCES USER_TABLE(user_id)
);

CREATE TABLE ROOM_BOOKING_REQUEST (
    room_booking_request_id BIGINT PRIMARY KEY,
    requester_user_id BIGINT,
    requestee_room_id BIGINT,
    start_datetime TIMESTAMP,
    end_datetime TIMESTAMP,
    request_purpose VARCHAR(255),
    request_description VARCHAR(255),
    request_status VARCHAR(50),
    FOREIGN KEY (requester_user_id) REFERENCES USER_TABLE(user_id),
    FOREIGN KEY (requestee_room_id) REFERENCES ROOM(room_id)
);

CREATE TABLE INDIVIDUAL_BOOKING_REQUEST (
    individual_booking_request_id BIGINT PRIMARY KEY,
    requester_user_id BIGINT,
    requestee_user_id BIGINT,
    start_datetime TIMESTAMP,
    end_datetime TIMESTAMP,
    request_purpose VARCHAR(255),
    request_description VARCHAR(255),
    request_status VARCHAR(50),
    room_id BIGINT,
    FOREIGN KEY (requester_user_id) REFERENCES USER_TABLE(user_id),
    FOREIGN KEY (requestee_user_id) REFERENCES USER_TABLE(user_id),
    FOREIGN KEY (room_id) REFERENCES ROOM(room_id)
);

CREATE TABLE GROUP_BOOKING_REQUEST (
    group_booking_request_id BIGINT PRIMARY KEY,
    requester_user_id BIGINT,
    requestee_group_id BIGINT,
    start_datetime TIMESTAMP,
    end_datetime TIMESTAMP,
    request_purpose VARCHAR(255),
    request_description VARCHAR(255),
    request_status VARCHAR(50),
    room_id BIGINT,
    FOREIGN KEY (requester_user_id) REFERENCES USER_TABLE(user_id),
    FOREIGN KEY (requestee_group_id) REFERENCES GROUP_TABLE(group_id),
    FOREIGN KEY (room_id) REFERENCES ROOM(room_id)
);

CREATE TABLE GROUP_EVENT (
    group_id BIGINT,
    event_id BIGINT,
    PRIMARY KEY (group_id, event_id),
    FOREIGN KEY (group_id) REFERENCES GROUP_TABLE(group_id),
    FOREIGN KEY (event_id) REFERENCES EVENT(event_id)
);