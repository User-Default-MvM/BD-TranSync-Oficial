-- Se elimina la base de datos si ya existe para asegurar una instalación limpia.
DROP DATABASE IF EXISTS transync;

-- Creación de la base de datos transync.
CREATE DATABASE transync;

-- Sentencia para usar la base de datos recién creada.
USE transync;

-- -----------------------------------------------------
-- Tabla: Roles
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Roles (
    idRol INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    nomRol VARCHAR(50) NOT NULL UNIQUE
);

-- -----------------------------------------------------
-- Tabla: Empresas
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Empresas (
    -- Identificador único de la Empresa.
    idEmpresa INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    -- Nombre de la Empresa.
    nomEmpresa VARCHAR(100) NOT NULL,
    -- NIT de la Empresa (único).
    nitEmpresa VARCHAR(20) NOT NULL UNIQUE,
    -- Dirección de la Empresa.
    dirEmpresa VARCHAR(100) NOT NULL,
    -- Correo electrónico de contacto de la Empresa.
    emaEmpresa VARCHAR(80) NOT NULL,
    -- Teléfono de contacto de la Empresa.
    telEmpresa VARCHAR(15) NOT NULL UNIQUE,
    -- Fecha y hora en que se registra una nueva empresa en el sistema.
    fecRegEmpresa TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------
-- Tabla: Usuarios
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Usuarios (
    -- Identificador único del Usuario.
    idUsuario INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    -- Email para el login (debe ser único en todo el sistema).
    email VARCHAR(80) NOT NULL UNIQUE,
    -- Contraseña cifrada (hash).
    passwordHash VARCHAR(255) NOT NULL,
    -- Rol del usuario que define sus permisos.
    idRol INT NOT NULL,
    -- Empresa a la que pertenece el usuario.
    idEmpresa INT NOT NULL,
    -- Los usuarios inician desactivados en el sistema hasta hacer la validacion.
    estActivo BOOLEAN DEFAULT FALSE,
    -- Fecha de creación del usuario.
    fecCreUsuario TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Fecha de última modificación (se actualiza sola).
    fecUltModUsuario TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- Llave foranea: Con la tabla de Roles
    CONSTRAINT Fk_Usuarios_Roles FOREIGN KEY (idRol) REFERENCES Roles(idRol),
    -- Llave foránea: Si se borra una empresa, se borran sus usuarios.
    CONSTRAINT Fk_Usuarios_Empresas FOREIGN KEY (idEmpresa) REFERENCES Empresas(idEmpresa) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Tabla: Administradores
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Administradores (
    -- Identificador único del Administrador.
    idAdministrador INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    -- Vínculo con sus credenciales en la tabla Usuarios.
    idUsuario INT NOT NULL UNIQUE,
    -- Nombre(s) del Administrador.
    nomAdministrador VARCHAR(80) NOT NULL,
    -- Apellido(s) del Administrador.
    apeAdministrador VARCHAR(80) NOT NULL,
    -- Número de documento del Administrador (único por empresa).
    numDocAdministrador VARCHAR(15) NOT NULL,
    -- Identificador de la Empresa a la que pertenece.
    idEmpresa INT NOT NULL,
    -- Restricción de unicidad para el documento por empresa.
    UNIQUE(idEmpresa, numDocAdministrador),
    -- Llave foránea: Si se borra una empresa, se borran sus perfiles de admin.
    CONSTRAINT Fk_Administradores_Empresas FOREIGN KEY (idEmpresa) REFERENCES Empresas(idEmpresa) ON DELETE CASCADE,
    -- Llave foránea: Si se borra un usuario, se borra su perfil de admin.
    CONSTRAINT Fk_Administradores_Usuarios FOREIGN KEY (idUsuario) REFERENCES Usuarios(idUsuario) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Tabla: Conductores
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Conductores (
    -- Identificador único del Conductor.
    idConductor INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    -- Vínculo opcional a Usuarios para el login en la app.
    idUsuario INT NULL UNIQUE,
    -- Nombre(s) del Conductor.
    nomConductor VARCHAR(80) NOT NULL,
    -- Apellido(s) del Conductor.
    apeConductor VARCHAR(80) NOT NULL,
    -- Número de documento del Conductor (único por empresa).
    numDocConductor VARCHAR(15) NOT NULL,
    -- Tipo de licencia de conducción.
    tipLicConductor ENUM('B1', 'B2', 'B3', 'C1', 'C2', 'C3') NOT NULL,
    -- Fecha de vencimiento de la licencia.
    fecVenLicConductor DATE NOT NULL,
    -- Teléfono de contacto del Conductor.
    telConductor VARCHAR(15),
    -- Estado laboral del Conductor.
    estConductor ENUM('ACTIVO', 'INACTIVO', 'DIA_DESCANSO', 'INCAPACITADO', 'DE_VACACIONES') NOT NULL DEFAULT 'INACTIVO',
    -- Empresa a la que pertenece el Conductor.
    idEmpresa INT NOT NULL,
    -- Fecha de creación del registro.
    fecCreConductor TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Fecha de última modificación.
    fecUltModConductor TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- Restricción de unicidad para el documento por empresa.
    UNIQUE(idEmpresa, numDocConductor),
    -- Llave foránea: Si se borra la empresa, se borran sus conductores.
    CONSTRAINT Fk_Conductores_Empresas FOREIGN KEY (idEmpresa) REFERENCES Empresas(idEmpresa) ON DELETE CASCADE,
    -- Llave foránea: Si se borra el usuario, el conductor no se borra, solo se desvincula (SET NULL).
    CONSTRAINT Fk_Conductores_Usuarios FOREIGN KEY (idUsuario) REFERENCES Usuarios(idUsuario) ON DELETE SET NULL
);

-- -----------------------------------------------------
-- Tabla: Vehiculos
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Vehiculos (
    -- Identificador único del Vehículo.
    idVehiculo INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    -- Número interno del Vehículo (único por empresa).
    numVehiculo VARCHAR(10) NOT NULL,
    -- Placa del Vehículo (única a nivel nacional).
    plaVehiculo VARCHAR(10) NOT NULL UNIQUE,
    -- Marca del Vehículo.
    marVehiculo VARCHAR(50) NOT NULL,
    -- Modelo del Vehículo.
    modVehiculo VARCHAR(50) NOT NULL,
    -- Año del Vehículo.
    anioVehiculo YEAR NOT NULL,
    -- Fecha de vencimiento del SOAT.
    fecVenSOAT DATE NOT NULL,
    -- Fecha de vencimiento de la Revisión Técnico-Mecánica.
    fecVenTec DATE NOT NULL,
    -- Estado actual del Vehículo.
    estVehiculo ENUM('DISPONIBLE', 'EN_RUTA', 'EN_MANTENIMIENTO', 'FUERA_DE_SERVICIO') NOT NULL DEFAULT 'DISPONIBLE',
    -- Empresa propietaria del Vehículo.
    idEmpresa INT NOT NULL,
    -- Conductor asignado actualmente (puede no tener uno).
    idConductorAsignado INT NULL,
    -- Fecha de creación del registro.
    fecCreVehiculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Fecha de última modificación.
    fecUltModVehiculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- Restricción de unicidad para el número interno por empresa.
    UNIQUE(idEmpresa, numVehiculo),
    -- Llave foránea: Si se borra la empresa, se borran sus vehículos.
    CONSTRAINT Fk_Vehiculos_Empresas FOREIGN KEY (idEmpresa) REFERENCES Empresas(idEmpresa) ON DELETE CASCADE,
    -- Llave foránea: Si se borra el conductor, el vehículo queda sin conductor asignado.
    CONSTRAINT Fk_Vehiculos_Conductor_Asignado FOREIGN KEY (idConductorAsignado) REFERENCES Conductores(idConductor) ON DELETE SET NULL
);

-- -----------------------------------------------------
-- Tabla: Rutas
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Rutas (
    -- Identificador único de la Ruta.
    idRuta INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    -- Nombre de la Ruta (único por empresa).
    nomRuta VARCHAR(100) NOT NULL,
    -- Origen de la Ruta.
    oriRuta VARCHAR(100) NOT NULL,
    -- Destino de la Ruta.
    desRuta VARCHAR(100) NOT NULL,
    -- Empresa que opera la ruta.
    idEmpresa INT NOT NULL,
    -- Restricción de unicidad para el nombre de la ruta por empresa.
    UNIQUE(idEmpresa, nomRuta),
    -- Llave foránea: Si se borra la empresa, se borran sus rutas.
    CONSTRAINT Fk_Rutas_Empresas FOREIGN KEY (idEmpresa) REFERENCES Empresas(idEmpresa) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Tabla: Viajes
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Viajes (
    -- Identificador único del Viaje.
    idViaje INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    -- Vehículo del viaje.
    idVehiculo INT NOT NULL,
    -- Conductor del viaje.
    idConductor INT NOT NULL,
    -- Ruta del viaje.
    idRuta INT NOT NULL,
    -- Fecha y hora de salida.
    fecHorSalViaje DATETIME NOT NULL,
    -- Fecha y hora de llegada.
    fecHorLleViaje DATETIME NULL,
    -- Estado del Viaje.
    estViaje ENUM('PROGRAMADO', 'EN_CURSO', 'FINALIZADO', 'CANCELADO') NOT NULL DEFAULT 'PROGRAMADO',
    -- Observaciones o novedades.
    obsViaje TEXT,
    -- Llave foránea hacia Vehiculos.
    CONSTRAINT Fk_Viajes_Vehiculos FOREIGN KEY (idVehiculo) REFERENCES Vehiculos(idVehiculo),
    -- Llave foránea hacia Conductores.
    CONSTRAINT Fk_Viajes_Conductores FOREIGN KEY (idConductor) REFERENCES Conductores(idConductor),
    -- Llave foránea hacia Rutas.
    CONSTRAINT Fk_Viajes_Rutas FOREIGN KEY (idRuta) REFERENCES Rutas(idRuta)
);

-- =====================================================
-- INSERCIÓN DE DATOS INICIALES Y EJEMPLOS
-- =====================================================

-- Insertar roles básicos del sistema
INSERT INTO Roles (nomRol) VALUES 
('SUPERADMIN'),
('PENDIENTE'),
('ADMINISTRADOR'),
('CONDUCTOR');

-- Insertar empresas de ejemplo
INSERT INTO Empresas (nomEmpresa, nitEmpresa, dirEmpresa, emaEmpresa, telEmpresa) VALUES
('TransSync Demo', '900123456-1', 'Calle 123 #45-67, Bogotá', 'demo@transync.com', '3001234567'),
('Transportes El Rápido S.A.S', '901234567-2', 'Avenida 80 #25-30, Medellín', 'info@elrapido.com', '3009876543');

-- Crear usuario SUPERADMIN con las credenciales solicitadas
-- Email: transsync1@gmail.com
-- Contraseña: admin123 (hasheada con bcrypt, salt rounds: 10)
INSERT INTO Usuarios (email, passwordHash, idRol, idEmpresa, estActivo) VALUES
('transsync1@gmail.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIrsKR8lGhcnDbPvN/d9YbKrOTGO0xGq', 1, 1, TRUE),
('admin@elrapido.com', '$2a$10$8K1p5Uj3N2B4F7D8G1H5JuO9LmNqPrStUvWxYzAbCdEfGhIjKlMnO', 3, 2, TRUE),
('conductor@elrapido.com', '$2a$10$9L2q6Vk4O3C5G8E9H2I6KvP0MnQrSuVxYzBcDfGhJkLnOpQrSuVx', 4, 2, TRUE);

-- Crear perfiles de administradores
INSERT INTO Administradores (idUsuario, nomAdministrador, apeAdministrador, numDocAdministrador, idEmpresa) VALUES
(1, 'Bryan', 'Munoz', '1073155317', 1),
(2, 'María José', 'Rodríguez Pérez', '98765432', 2);

-- Insertar conductores de ejemplo
INSERT INTO Conductores (idUsuario, nomConductor, apeConductor, numDocConductor, tipLicConductor, fecVenLicConductor, telConductor, estConductor, idEmpresa) VALUES
(3, 'Carlos Alberto', 'González Martínez', '87654321', 'C2', '2025-12-31', '3156789012', 'ACTIVO', 2),
(NULL, 'Ana Lucía', 'Vásquez Torres', '11223344', 'C1', '2026-06-15', '3187654321', 'INACTIVO', 1);

-- Insertar vehículos de ejemplo
INSERT INTO Vehiculos (numVehiculo, plaVehiculo, marVehiculo, modVehiculo, anioVehiculo, fecVenSOAT, fecVenTec, estVehiculo, idEmpresa, idConductorAsignado) VALUES
('BUS001', 'ABC123', 'Mercedes-Benz', 'OH 1626', 2020, '2025-08-30', '2025-12-15', 'DISPONIBLE', 1, NULL),
('VAN002', 'DEF456', 'Chevrolet', 'NPR', 2019, '2025-09-15', '2026-01-20', 'EN_RUTA', 2, 1);

-- Insertar rutas de ejemplo
INSERT INTO Rutas (nomRuta, oriRuta, desRuta, idEmpresa) VALUES
('Ruta Norte-Centro', 'Terminal Norte Bogotá', 'Centro Internacional Bogotá', 1),
('Expreso Medellín-Rionegro', 'Terminal Sur Medellín', 'Aeropuerto José María Córdova', 2);

-- Insertar viajes de ejemplo
INSERT INTO Viajes (idVehiculo, idConductor, idRuta, fecHorSalViaje, fecHorLleViaje, estViaje, obsViaje) VALUES
(1, 2, 1, '2025-08-21 08:00:00', '2025-08-21 09:30:00', 'FINALIZADO', 'Viaje completado sin novedades'),
(2, 1, 2, '2025-08-21 14:30:00', NULL, 'EN_CURSO', 'Salida a tiempo, tráfico normal');

-- =====================================================
-- VERIFICACIÓN DE DATOS INSERTADOS
-- =====================================================

-- Verificar que los roles se crearon correctamente
SELECT 'Roles creados:' as Info;
SELECT idRol, nomRol FROM Roles;

-- Verificar que las empresas se crearon correctamente  
SELECT 'Empresas creadas:' as Info;
SELECT idEmpresa, nomEmpresa, nitEmpresa FROM Empresas;

-- Verificar que los usuarios se crearon correctamente
SELECT 'Usuarios creados:' as Info;
SELECT 
    u.idUsuario, 
    u.email, 
    r.nomRol as rol, 
    u.estActivo,
    e.nomEmpresa
FROM Usuarios u
JOIN Roles r ON u.idRol = r.idRol
JOIN Empresas e ON u.idEmpresa = e.idEmpresa;

-- Verificar administradores
SELECT 'Administradores creados:' as Info;
SELECT 
    a.idAdministrador,
    CONCAT(a.nomAdministrador, ' ', a.apeAdministrador) as nombreCompleto,
    a.numDocAdministrador,
    e.nomEmpresa,
    u.email
FROM Administradores a
JOIN Empresas e ON a.idEmpresa = e.idEmpresa
JOIN Usuarios u ON a.idUsuario = u.idUsuario;

-- Verificar conductores
SELECT 'Conductores creados:' as Info;
SELECT 
    c.idConductor,
    CONCAT(c.nomConductor, ' ', c.apeConductor) as nombreCompleto,
    c.numDocConductor,
    c.tipLicConductor,
    c.estConductor,
    e.nomEmpresa,
    u.email as emailUsuario
FROM Conductores c
JOIN Empresas e ON c.idEmpresa = e.idEmpresa
LEFT JOIN Usuarios u ON c.idUsuario = u.idUsuario;

-- Verificar vehículos
SELECT 'Vehículos creados:' as Info;
SELECT 
    v.idVehiculo,
    v.numVehiculo,
    v.plaVehiculo,
    CONCAT(v.marVehiculo, ' ', v.modVehiculo) as vehiculo,
    v.anioVehiculo,
    v.estVehiculo,
    e.nomEmpresa,
    CASE 
        WHEN c.idConductor IS NOT NULL 
        THEN CONCAT(c.nomConductor, ' ', c.apeConductor)
        ELSE 'Sin asignar'
    END as conductorAsignado
FROM Vehiculos v
JOIN Empresas e ON v.idEmpresa = e.idEmpresa
LEFT JOIN Conductores c ON v.idConductorAsignado = c.idConductor;

-- Verificar rutas
SELECT 'Rutas creadas:' as Info;
SELECT 
    r.idRuta,
    r.nomRuta,
    r.oriRuta,
    r.desRuta,
    e.nomEmpresa
FROM Rutas r
JOIN Empresas e ON r.idEmpresa = e.idEmpresa;

-- Verificar viajes
SELECT 'Viajes creados:' as Info;
SELECT 
    vi.idViaje,
    CONCAT(v.marVehiculo, ' ', v.modVehiculo, ' - ', v.plaVehiculo) as vehiculo,
    CONCAT(c.nomConductor, ' ', c.apeConductor) as conductor,
    ru.nomRuta,
    vi.fecHorSalViaje,
    vi.fecHorLleViaje,
    vi.estViaje,
    vi.obsViaje
FROM Viajes vi
JOIN Vehiculos v ON vi.idVehiculo = v.idVehiculo
JOIN Conductores c ON vi.idConductor = c.idConductor
JOIN Rutas ru ON vi.idRuta = ru.idRuta;

-- Mostrar mensaje de éxito
SELECT 'Base de datos TransSync configurada exitosamente con datos de ejemplo!' as Resultado;


// src/controllers/authController.js

const pool = require("../config/db");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { sendEmail } = require("../utils/emailService");

// =====================================================
// REGISTRO DE USUARIO
// =====================================================
const register = async (req, res) => {
    const { nomUsuario, apeUsuario, numDocUsuario, telUsuario, email, password } = req.body;
    const idEmpresa = 1; // Empresa por defecto

    if (!nomUsuario || !apeUsuario || !numDocUsuario || !telUsuario || !email || !password) {
        return res.status(400).json({ msg: 'Todos los campos son obligatorios' });
    }

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [existingUser] = await connection.query(
            "SELECT idUsuario FROM Usuarios WHERE email = ? OR numDocUsuario = ?",
            [email, numDocUsuario]
        );
        if (existingUser.length > 0) {
            await connection.rollback();
            return res.status(409).json({ message: "El correo o documento ya está registrado." });
        }

        const [roleResult] = await connection.query(
            "SELECT idRol FROM Roles WHERE nomRol = 'CONDUCTOR'"
        );
        if (roleResult.length === 0) {
            await connection.rollback();
            return res.status(500).json({ message: "Rol CONDUCTOR no encontrado." });
        }

        const idRol = roleResult[0].idRol;
        const salt = await bcrypt.genSalt(10);
        const passwordHash = await bcrypt.hash(password, salt);

        const [userResult] = await connection.query(
            `INSERT INTO Usuarios 
            (email, passwordHash, nomUsuario, apeUsuario, numDocUsuario, telUsuario, idRol, idEmpresa) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
            [email, passwordHash, nomUsuario, apeUsuario, numDocUsuario, telUsuario, idRol, idEmpresa]
        );

        const newUserId = userResult.insertId;

        const verifyToken = jwt.sign({ id: newUserId }, process.env.JWT_SECRET, { expiresIn: '1d' });
        const verifyUrl = `http://localhost:5000/api/auth/verify?token=${verifyToken}`;

        await sendEmail(
            email,
            "Verifica Tu Cuenta De Transync",
            // Aquí iría el HTML que ya tienes (omito por brevedad)
            `<p>Haz clic en el siguiente enlace para verificar tu cuenta: <a href="${verifyUrl}">Verificar</a></p>`
        );

        await connection.commit();
        res.status(201).json({
            message: "Usuario registrado. Verifica tu correo electrónico para activar la cuenta.",
        });

    } catch (error) {
        await connection.rollback();
        console.error("Error en el registro:", error);
        res.status(500).json({ message: "Error al registrar usuario." });
    } finally {
        connection.release();
    }
};

// =====================================================
// LOGIN
// =====================================================
const login = async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ message: "Correo y contraseña requeridos." });
    }

    try {
        const query = `
            SELECT u.*, r.nomRol as rol, e.nomEmpresa
            FROM Usuarios u
            JOIN Roles r ON u.idRol = r.idRol
            JOIN Empresas e ON u.idEmpresa = e.idEmpresa
            WHERE u.email = ?
        `;

        const [rows] = await pool.query(query, [email]);
        const user = rows[0];

        if (!user) {
            return res.status(401).json({ message: "Credenciales incorrectas." });
        }

        if (!user.estActivo) {
            return res.status(403).json({ message: "Cuenta desactivada. Verifica tu correo o contacta soporte." });
        }

        const isMatch = await bcrypt.compare(password, user.passwordHash);
        if (!isMatch) {
            return res.status(401).json({ message: "Credenciales incorrectas." });
        }

        // Lógica para obtener nombre y apellido según rol
        let nombre = "";
        let apellido = "";

        if (user.rol === "SUPERADMIN") {
            nombre = user.nomAdministrador || "Super";
            apellido = user.apeAdministrador || "Admin";
        } else if (user.rol === "GESTOR") {
            nombre = user.nomAdministrador || "Gestor";
            apellido = user.apeAdministrador || "Usuario";
        } else if (user.rol === "CONDUCTOR") {
            nombre = user.nomConductor || "Conductor";
            apellido = user.apeConductor || "Usuario";
        } else {
            nombre = user.nomUsuario || "Usuario";
            apellido = user.apeUsuario || "Pendiente";
        }

        const token = jwt.sign(
            {
                id: user.idUsuario,
                role: user.rol,
                idEmpresa: user.idEmpresa,
                empresa: user.nomEmpresa
            },
            process.env.JWT_SECRET,
            { expiresIn: "8h" }
        );

        res.json({
            success: true,
            token,
            user: {
                id: user.idUsuario,
                name: `${nombre} ${apellido}`.trim(),
                email: user.email,
                role: user.rol,
                empresa: user.nomEmpresa,
                idEmpresa: user.idEmpresa
            }
        });

    } catch (error) {
        console.error("Error en login:", error);
        res.status(500).json({ message: "Error interno del servidor." });
    }
};

// =====================================================
// VERIFICACIÓN DE CUENTA
// =====================================================
const verifyAccount = async (req, res) => {
    const { token } = req.query;

    if (!token) {
        return res.status(400).json({ message: "Token de verificación no proporcionado." });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const userId = decoded.id;

        const [result] = await pool.query(
            'UPDATE Usuarios SET estActivo = 1 WHERE idUsuario = ?',
            [userId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Usuario no encontrado o ya verificado.' });
        }

        res.status(200).json({ message: 'Cuenta verificada exitosamente.' });
    } catch (error) {
        console.error("Error al verificar cuenta:", error);
        return res.status(400).json({ message: "Token inválido o expirado." });
    }
};

// =====================================================
// OLVIDÉ MI CONTRASEÑA
// =====================================================
const forgotPassword = async (req, res) => {
    const { email } = req.body;
    if (!email) {
        return res.status(400).json({ message: "Correo electrónico requerido." });
    }

    try {
        const [rows] = await pool.query("SELECT idUsuario FROM Usuarios WHERE email = ?", [email]);

        if (rows.length === 0) {
            return res.status(404).json({ message: "Correo no registrado." });
        }

        const userId = rows[0].idUsuario;

        const resetToken = jwt.sign({ id: userId }, process.env.JWT_SECRET, { expiresIn: "15m" });
        const resetUrl = `http://localhost:3000/reset-password?token=${resetToken}`;

        await sendEmail(
            email,
            "Restablece Tu Contraseña - TranSync",
            // Aquí también puedes personalizar con el HTML que ya tienes
            `<p>Haz clic en el siguiente enlace para restablecer tu contraseña: <a href="${resetUrl}">Restablecer</a></p>`
        );

        res.json({ message: "Correo de restablecimiento enviado." });
    } catch (error) {
        console.error("Error en forgotPassword:", error);
        res.status(500).json({ message: "Error en el servidor." });
    }
};

// =====================================================
// RESET DE CONTRASEÑA
// =====================================================
const resetPassword = async (req, res) => {
    const { token } = req.query;
    const { newPassword } = req.body;

    if (!token || !newPassword) {
        return res.status(400).json({ message: "Token y nueva contraseña son requeridos." });
    }

    if (!esPasswordSegura(newPassword)) {
        return res.status(400).json({
            message: "La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula, un número y un símbolo."
        });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const userId = decoded.id;

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(newPassword, salt);

        const [result] = await pool.query(
            "UPDATE Usuarios SET passwordHash = ? WHERE idUsuario = ?",
            [hashedPassword, userId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: "Usuario no encontrado." });
        }

        res.json({ message: "Contraseña actualizada correctamente." });
    } catch (error) {
        console.error("Error en resetPassword:", error);
        res.status(400).json({ message: "Token inválido o expirado." });
    }
};

// =====================================================
// VALIDACIÓN DE CONTRASEÑA SEGURA
// =====================================================
function esPasswordSegura(password) {
    const regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$/;
    return regex.test(password);
}

module.exports = {
    register,
    login,
    verifyAccount,
    forgotPassword,
    resetPassword,
    esPasswordSegura
};
