CREATE TABLE IF NOT EXISTS productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    precio INTEGER
);

INSERT INTO productos (nombre, precio) VALUES ('pulsera', '5');