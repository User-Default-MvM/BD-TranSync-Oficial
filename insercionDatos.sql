INSERT INTO Roles (nomRol) VALUES 
('SUPERADMIN'),
('GESTOR'),
('CONDUCTOR');

INSERT INTO Empresas (nomEmpresa, nitEmpresa, dirEmpresa, emaEmpresa, telEmpresa)
VALUES(
    'Transporte La Sabana S.A.S',
    '900123456',
    'Cra 45 # 12-34, Bogotá',
    'contacto@lasabana.com',
    '3011234567'
);



-- Insertar conductores de ejemplo
INSERT INTO Conductores (idUsuario, tipLicConductor, fecVenLicConductor, estConductor, idEmpresa) 
VALUES
        -- idUsuario, tipo de licencia, fecha de vencimiento de la licencia, estado del Conductor y Empresa a la que pertencece de momento solo existe una empresa 1.
        (9,'B1','2026-05-15', 'ACTIVO', 1),
        (10,'B2','2027-09-01', 'DIA_DESCANSO', 1),
        (11, 'B3','2028-12-01', 'INCAPACITADO', 1);

-- Insertar rutas de ejemplo
INSERT INTO Rutas (nomRuta, oriRuta, desRuta, idEmpresa) VALUES
('Ruta Norte-Centro', 'Terminal Norte Bogotá', 'Centro Internacional Bogotá', 1),
('Expreso Medellín-Rionegro', 'Terminal Sur Medellín', 'Aeropuerto José María Córdova', 2),
('Ruta Sur-Chapinero', 'Terminal Sur Bogotá', 'Zona Rosa Chapinero', 1),
('Ruta Envigado-Centro', 'Envigado', 'Centro Medellín', 2);
