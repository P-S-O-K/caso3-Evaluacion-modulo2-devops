CREATE DATABASE escuela;

\c escuela;

CREATE TABLE alumnos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO alumnos (nombre, email) VALUES
('Juan Perez', 'juan@escuela.com'),
('Maria Lopez', 'maria@escuela.com'),
('Carlos Sanchez', 'carlos@escuela.com'),
('Ana Torres', 'ana@escuela.com'),
('Luis Ramirez', 'luis@escuela.com');
