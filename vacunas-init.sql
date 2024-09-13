USE master;
CREATE DATABASE vacunas;
GO

USE vacunas;

-- Únicamente las aplicaciones deben tener un login y su user con permisos
CREATE LOGIN ApplicationsVacunas
    WITH PASSWORD = '',
    DEFAULT_DATABASE = vacunas
GO
-- crear usuario de la base de datos y darle permisos
CREATE USER SpringAPI FOR LOGIN ApplicationsVacunas
GO
EXEC sp_addrolemember 'db_datareader', 'SpringApi'
EXEC sp_addrolemember 'db_datawriter', 'SpringApi'
GRANT EXECUTE ON SCHEMA::dbo TO SpringAPI
-- dependiendo la aplicación se le puede asignar más o menos permisos**

-- tablas de manejo de usuarios
CREATE TABLE permisos
(
    id_permiso          SMALLINT PRIMARY KEY IDENTITY (1,1),
    nombre_permiso      NVARCHAR(100) NOT NULL,
    descripcion_permiso NVARCHAR(100),
    CONSTRAINT uq_permisos_nombre UNIQUE (nombre_permiso)
);
GO
CREATE TABLE roles
(
    id_rol          SMALLINT PRIMARY KEY IDENTITY (1,1),
    nombre_rol      NVARCHAR(100) NOT NULL,
    descripcion_rol NVARCHAR(100),
    CONSTRAINT uq_roles_rol UNIQUE (nombre_rol)
);
GO
CREATE TABLE usuarios
(
    id_usuario       UNIQUEIDENTIFIER PRIMARY KEY
        CONSTRAINT df_usuarios_id DEFAULT NEWID(),
    cedula           NVARCHAR(20)  NOT NULL,
    usuario          NVARCHAR(50),
    correo_usuario   NVARCHAR(254),
    clave_hash       NVARCHAR(60)  NOT NULL,
    fecha_nacimiento SMALLDATETIME NOT NULL,
    disabled         BIT
        CONSTRAINT df_usuarios_disabled DEFAULT 0,
    created_at       DATETIME
        CONSTRAINT df_usuarios_created DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME
        CONSTRAINT df_usuarios_updated DEFAULT CURRENT_TIMESTAMP,
    last_used        DATETIME,
    CONSTRAINT ck_usuarios_fecha_nacimiento CHECK (fecha_nacimiento <= GETDATE()),
    CONSTRAINT uq_usuarios_cedula UNIQUE (cedula)
);
GO
CREATE UNIQUE NONCLUSTERED INDEX ix_usuarios_username
    ON usuarios (usuario)
    WHERE usuario IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX ix_usuarios_email
    ON usuarios (correo_usuario)
    WHERE correo_usuario IS NOT NULL;
GO
CREATE TABLE usuarios_roles
(
    id_usuario UNIQUEIDENTIFIER,
    id_rol     SMALLINT,
    PRIMARY KEY (id_usuario, id_rol),
    CONSTRAINT fk_usuarios_roles_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_usuarios_roles_rol FOREIGN KEY (id_rol) REFERENCES roles (id_rol) ON DELETE CASCADE
);
GO
CREATE NONCLUSTERED INDEX ix_usuarios_roles
    ON usuarios_roles (id_rol, id_usuario);
GO
CREATE TABLE roles_permisos
(
    id_rol     SMALLINT,
    id_permiso SMALLINT,
    PRIMARY KEY (id_rol, id_permiso),
    CONSTRAINT fk_roles_permisos_rol FOREIGN KEY (id_rol) REFERENCES roles (id_rol) ON DELETE CASCADE,
    CONSTRAINT fk_roles_permisos_permiso FOREIGN KEY (id_permiso) REFERENCES permisos (id_permiso) ON DELETE CASCADE
);
GO
-- tablas de vacunación
CREATE TABLE provincias
(
    id_provincia     TINYINT PRIMARY KEY IDENTITY (0,1),
    nombre_provincia NVARCHAR(30) NOT NULL,
    CONSTRAINT ck_provincia_existe CHECK (nombre_provincia IN
                                          ('Provincia por registrar', /* Problemas o nueva provincia sin registrar aún */
                                           'Bocas del Toro', /*1*/
                                           'Coclé', /*2*/
                                           'Colón', /*3*/
                                           'Chiriquí', /*4*/
                                           'Darién', /*5*/
                                           'Herrera', /*6*/
                                           'Los Santos', /*7*/
                                           'Panamá', /*8*/
                                           'Veraguas', /*9*/
                                           'Guna Yala', /*10*/
                                           'Emberá-Wounaan', /*11*/
                                           'Ngäbe-Buglé',/*12*/
                                           'Panamá Oeste', /*13*/
                                           'Naso Tjër Di', /*14*/
                                           'Guna de Madugandí', /*15*/
                                           'Guna de Wargandí' /*16*/
                                              ))
);
GO
CREATE TABLE distritos
(
    id_distrito     TINYINT PRIMARY KEY IDENTITY (0,1),
    nombre_distrito NVARCHAR(100) NOT NULL,
    id_provincia    TINYINT       NOT NULL,
    CONSTRAINT fk_distritos_provincia FOREIGN KEY (id_provincia) REFERENCES provincias (id_provincia),
    CONSTRAINT ck_distritos_provincias CHECK (
        (id_provincia = 0 AND nombre_distrito LIKE 'Distrito por registrar') OR
        (id_provincia = 1 AND nombre_distrito IN ('Almirante',
                                                  'Bocas del Toro',
                                                  'Changuinola',
                                                  'Chiriquí Grande')) OR
        (id_provincia = 2 AND nombre_distrito IN ('Aguadulce',
                                                  'Antón',
                                                  'La Pintada',
                                                  'Natá',
                                                  'Olá',
                                                  'Penonomé')) OR
        (id_provincia = 3 AND nombre_distrito IN ('Chagres',
                                                  'Colón',
                                                  'Donoso',
                                                  'Portobelo',
                                                  'Santa Isabel',
                                                  'Omar Torrijos Herrera')) OR
        (id_provincia = 4 AND nombre_distrito IN ('Alanje',
                                                  'Barú',
                                                  'Boquerón',
                                                  'Boquete',
                                                  'Bugaba',
                                                  'David',
                                                  'Dolega',
                                                  'Gualaca',
                                                  'Remedios',
                                                  'Renacimiento',
                                                  'San Félix',
                                                  'San Lorenzo',
                                                  'Tierras Altas',
                                                  'Tolé')) OR
        (id_provincia = 5 AND nombre_distrito IN ('Chepigana',
                                                  'Pinogana',
                                                  'Santa Fe',
                                                  'Guna de Wargandí')) OR
        (id_provincia = 6 AND nombre_distrito IN ('Chitré',
                                                  'Las Minas',
                                                  'Los Pozos',
                                                  'Ocú',
                                                  'Parita',
                                                  'Pesé',
                                                  'Santa María')) OR
        (id_provincia = 7 AND nombre_distrito IN ('Guararé',
                                                  'Las Tablas',
                                                  'Los Santos',
                                                  'Macaracas',
                                                  'Pedasí',
                                                  'Pocrí',
                                                  'Tonosí')) OR
        (id_provincia = 8 AND nombre_distrito IN ('Balboa',
                                                  'Chepo',
                                                  'Chimán',
                                                  'Panamá',
                                                  'San Miguelito',
                                                  'Taboga')) OR
        (id_provincia = 9 AND nombre_distrito IN ('Atalaya',
                                                  'Calobre',
                                                  'Cañazas',
                                                  'La Mesa',
                                                  'Las Palmas',
                                                  'Mariato',
                                                  'Montijo',
                                                  'Río de Jesús',
                                                  'San Francisco',
                                                  'Santa Fe',
                                                  'Santiago',
                                                  'Soná')) OR
            /*comarca guna yala, madugandi, wargandi no tiene distrito, provincia 10*/
        (id_provincia = 11 AND nombre_distrito IN ('Cémaco', 'Sambú')) OR
        (id_provincia = 12 AND nombre_distrito IN ('Besikó',
                                                   'Jirondai',
                                                   'Kankintú',
                                                   'Kusapín',
                                                   'Mironó',
                                                   'Müna',
                                                   'Nole Duima',
                                                   'Ñürüm',
                                                   'Santa Catalina',
                                                   'Calovébora')) OR
        (id_provincia = 13 AND nombre_distrito IN ('Arraiján',
                                                   'Capira',
                                                   'Chame',
                                                   'La Chorrera',
                                                   'San Carlos')) OR
        (id_provincia = 14 AND nombre_distrito IN ('Naso Tjër Di')) OR
        (id_provincia IS NULL AND nombre_distrito IS NULL) -- Permitir NULL si es necesario
        )
);
GO
CREATE TABLE direcciones
(
    id_direccion UNIQUEIDENTIFIER PRIMARY KEY
        CONSTRAINT df_direcciones_id DEFAULT NEWID(),
    direccion    VARCHAR(150) NOT NULL,
    id_distrito  TINYINT
        CONSTRAINT df_direcciones_distrito DEFAULT 0,
    CONSTRAINT fk_direcciones_distrito FOREIGN KEY (id_distrito) REFERENCES distritos (id_distrito)
);
GO
CREATE TABLE pacientes
(
    cedula             NVARCHAR(20) PRIMARY KEY,
    nombre_paciente    NVARCHAR(50)  NOT NULL,
    apellido1_paciente NVARCHAR(50)  NOT NULL,
    apellido2_paciente NVARCHAR(50),
    fecha_nacimiento   SMALLDATETIME NOT NULL,
    edad_calculada     INT,
    sexo               CHAR(1)       NOT NULL,
    telefono_paciente  NVARCHAR(15),
    correo_paciente    NVARCHAR(50),
    id_direccion       UNIQUEIDENTIFIER,
    CONSTRAINT ck_pacientes_fecha_nacimiento CHECK (fecha_nacimiento <= GETDATE()),
    CONSTRAINT ck_pacientes_sexo_m_f CHECK (sexo LIKE 'M' OR sexo LIKE 'F'),
    CONSTRAINT ck_telefonos_paciente_no_signo_plus CHECK (telefono_paciente NOT LIKE '%+%'),
    CONSTRAINT ck_pacientes_edad CHECK (edad_calculada >= 0),
    CONSTRAINT fk_pacientes_direccion FOREIGN KEY (id_direccion) REFERENCES direcciones (id_direccion) ON UPDATE CASCADE,
    INDEX ix_pacientes_nombre_apellido (nombre_paciente, apellido1_paciente, apellido2_paciente)
);
GO
CREATE UNIQUE NONCLUSTERED INDEX ix_pacientes_correo
    ON pacientes (correo_paciente)
    WHERE correo_paciente IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX ix_pacientes_telefono
    ON pacientes (telefono_paciente)
    WHERE telefono_paciente IS NOT NULL;
GO
CREATE TABLE sedes
(
    id_sede          UNIQUEIDENTIFIER PRIMARY KEY
        CONSTRAINT df_sedes_id DEFAULT NEWID(),
    nombre_sede      NVARCHAR(100) NOT NULL,
    correo_sede      NVARCHAR(50),
    telefono_sede    NVARCHAR(15),
    region           NVARCHAR(50),
    dependencia_sede NVARCHAR(13)  NOT NULL,
    id_direccion     UNIQUEIDENTIFIER,
    CONSTRAINT ck_sedes_telefono CHECK (telefono_sede NOT LIKE '%+%'),
    CONSTRAINT uq_sedes_nombre UNIQUE (nombre_sede),
    CONSTRAINT ck_sedes_dependencia CHECK (dependencia_sede IN ('CSS', 'MINSA', 'Privada', 'Por registrar')),
    CONSTRAINT fk_sedes_direccion FOREIGN KEY (id_direccion) REFERENCES direcciones (id_direccion) ON UPDATE CASCADE,
    INDEX ix_sedes_nombre_region_dependencia (nombre_sede, region, dependencia_sede)
);
GO
CREATE UNIQUE NONCLUSTERED INDEX ix_sedes_telefono
    ON sedes (telefono_sede)
    WHERE telefono_sede IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX ix_sedes_email
    ON sedes (correo_sede)
    WHERE correo_sede IS NOT NULL;
GO
CREATE TABLE vacunas
(
    id_vacuna                 UNIQUEIDENTIFIER PRIMARY KEY
        CONSTRAINT df_vacunas_id DEFAULT NEWID(),
    nombre_vacuna             NVARCHAR(100) NOT NULL,
    edad_minima_meses         SMALLINT,
    intervalo_dosis_1_2_meses FLOAT,
    CONSTRAINT ck_vacunas_edad_minima CHECK (edad_minima_meses >= 0),
    INDEX ix_vacunas_nombre (nombre_vacuna)
);
GO
CREATE TABLE dosis
(
    id_dosis         UNIQUEIDENTIFIER PRIMARY KEY
        CONSTRAINT df_dosis_id DEFAULT NEWID(),
    fecha_aplicacion DATETIME         NOT NULL,
    numero_dosis     CHAR(2)          NOT NULL, -- ver tabla adjunta con detalles
    id_vacuna        UNIQUEIDENTIFIER NOT NULL,
    id_sede          UNIQUEIDENTIFIER,
    CONSTRAINT ck_dosis_numero_dosis CHECK (numero_dosis IN ('1', '2', '3', 'R', 'R1', 'R2', 'P ')),
    CONSTRAINT fk_dosis_vacuna FOREIGN KEY (id_vacuna) REFERENCES vacunas (id_vacuna) ON UPDATE CASCADE,
    CONSTRAINT fk_dosis_sede FOREIGN KEY (id_sede) REFERENCES sedes (id_sede) ON UPDATE CASCADE
);
GO
CREATE TABLE pacientes_dosis
(
    cedula_paciente NVARCHAR(20),
    id_dosis        UNIQUEIDENTIFIER,
    PRIMARY KEY (cedula_paciente, id_dosis),
    CONSTRAINT fk_pacientes_dosis_paciente FOREIGN KEY (cedula_paciente) REFERENCES pacientes (cedula),
    CONSTRAINT fk_pacientes_dosis_dosis FOREIGN KEY (id_dosis) REFERENCES dosis (id_dosis)
);
GO
CREATE NONCLUSTERED INDEX ix_pacientes_dosis
    ON pacientes_dosis (cedula_paciente, id_dosis);
GO
CREATE TABLE fabricantes
(
    id_fabricante        INT PRIMARY KEY IDENTITY (1,1),
    licencia             NVARCHAR(50)  NOT NULL,
    nombre_fabricante    NVARCHAR(100) NOT NULL,
    telefono_fabricante  NVARCHAR(15),
    correo_fabricante    NVARCHAR(50),
    direccion_fabricante NVARCHAR(150)
        CONSTRAINT df_fabricantes_direccion DEFAULT 'Dirección por registrar',
    contacto_fabricante  NVARCHAR(50),
    CONSTRAINT ck_fabricantes_telefono CHECK (telefono_fabricante NOT LIKE '%+%'),
    INDEX ix_fabricantes_nombre_licencia (nombre_fabricante, licencia)
);
GO
CREATE UNIQUE NONCLUSTERED INDEX ix_fabricantes_telefono
    ON fabricantes (telefono_fabricante)
    WHERE telefono_fabricante IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX ix_fabricantes_correo
    ON fabricantes (correo_fabricante)
    WHERE correo_fabricante IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX ix_fabricantes_contacto
    ON fabricantes (contacto_fabricante)
    WHERE contacto_fabricante IS NOT NULL;
GO
CREATE TABLE almacenes
(
    id_almacen          SMALLINT PRIMARY KEY IDENTITY (1,1),
    nombre_almacen      NVARCHAR(100) NOT NULL,
    dependencia_almacen NVARCHAR(7),
    correo_almacen      NVARCHAR(50),
    telefono_almacen    NVARCHAR(15),
    id_direccion        UNIQUEIDENTIFIER,
    encargado           NVARCHAR(50),
    CONSTRAINT ck_almacenes_telefono CHECK (telefono_almacen NOT LIKE '%+%'),
    CONSTRAINT ck_almacenes_dependencia CHECK (dependencia_almacen IN ('CSS', 'MINSA', 'Privada')),
    CONSTRAINT fk_almacenes_direccion FOREIGN KEY (id_direccion) REFERENCES direcciones (id_direccion) ON UPDATE CASCADE,
    INDEX ix_almacenes_nombre (nombre_almacen)
);
GO
CREATE UNIQUE NONCLUSTERED INDEX ix_almacenes_telefono
    ON almacenes (telefono_almacen)
    WHERE telefono_almacen IS NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX ix_almacenes_email
    ON almacenes (correo_almacen)
    WHERE correo_almacen IS NOT NULL;
GO
CREATE TABLE almacenes_inventarios
(
    id_almacen         SMALLINT         NOT NULL,
    id_vacuna          UNIQUEIDENTIFIER NOT NULL,
    cantidad           INT              NOT NULL,
    fecha_lote_almacen DATETIME         NOT NULL,
    lote_almacen       NVARCHAR(10)     NOT NULL,
    PRIMARY KEY (id_almacen, id_vacuna),
    CONSTRAINT ck_almacenes_inventarios_fecha_lote CHECK (fecha_lote_almacen > GETDATE()),
    CONSTRAINT fk_almacenes_inventarios_almacen FOREIGN KEY (id_almacen) REFERENCES almacenes (id_almacen),
    CONSTRAINT fk_almacenes_inventarios_vacuna FOREIGN KEY (id_vacuna) REFERENCES vacunas (id_vacuna)
);
GO
CREATE TABLE sedes_inventarios
(
    id_sede         UNIQUEIDENTIFIER NOT NULL,
    id_vacuna       UNIQUEIDENTIFIER NOT NULL,
    cantidad        INT              NOT NULL,
    fecha_lote_sede DATETIME         NOT NULL,
    lote_sede       NVARCHAR(10)     NOT NULL,
    PRIMARY KEY (id_sede, id_vacuna),
    CONSTRAINT ck_sede_inventario_fecha_lote CHECK (fecha_lote_sede > GETDATE()),
    CONSTRAINT ck_cantidad CHECK (cantidad >= 0),
    CONSTRAINT fk_inventario_sede FOREIGN KEY (id_sede) REFERENCES sedes (id_sede),
    CONSTRAINT fk_inventario_vacuna FOREIGN KEY (id_vacuna) REFERENCES vacunas (id_vacuna)
);
GO
CREATE TABLE distribuciones_vacunas
(
    id_distribucion    UNIQUEIDENTIFIER PRIMARY KEY
        CONSTRAINT df_distribuciones_id DEFAULT NEWID(),
    id_almacen         SMALLINT         NOT NULL,
    id_sede            UNIQUEIDENTIFIER NOT NULL,
    id_vacuna          UNIQUEIDENTIFIER NOT NULL,
    cantidad           INT              NOT NULL,
    lote               NVARCHAR(10)     NOT NULL,
    fecha_distribucion DATETIME         NOT NULL,
    CONSTRAINT ck_distribucion_fecha_distribucion CHECK (fecha_distribucion <= GETDATE()),
    CONSTRAINT fk_distribucion_almacen FOREIGN KEY (id_almacen) REFERENCES almacenes (id_almacen),
    CONSTRAINT fk_distribucion_sede FOREIGN KEY (id_sede) REFERENCES sedes (id_sede),
    CONSTRAINT fk_distribucion_vacuna FOREIGN KEY (id_vacuna) REFERENCES vacunas (id_vacuna)
);
GO
CREATE TABLE fabricantes_vacunas
(
    id_fabricante INT,
    id_vacuna     UNIQUEIDENTIFIER,
    PRIMARY KEY (id_fabricante, id_vacuna),
    CONSTRAINT fk_fabricante_vacuna_fabricante FOREIGN KEY (id_fabricante) REFERENCES fabricantes (id_fabricante) ON UPDATE CASCADE,
    CONSTRAINT fk_fabricante_vacuna_vacuna FOREIGN KEY (id_vacuna) REFERENCES vacunas (id_vacuna) ON DELETE CASCADE
);
GO
CREATE TABLE enfermedades
(
    id_enfermedad     BIGINT PRIMARY KEY IDENTITY (0,1),
    nombre_enfermedad NVARCHAR(100) NOT NULL,
    nivel_gravedad    NVARCHAR(50),
    CONSTRAINT uq_enfermedades_nombre UNIQUE (nombre_enfermedad),
    INDEX ix_enfermedades_nombre (nombre_enfermedad)
);
GO
CREATE TABLE sintomas
(
    id_sintoma     BIGINT PRIMARY KEY IDENTITY (0,1),
    nombre_sintoma NVARCHAR(50) NOT NULL,
    CONSTRAINT uq_sintomas_nombre UNIQUE (nombre_sintoma),
    INDEX ix_sintomas_nombre (nombre_sintoma)
);
GO
CREATE TABLE enfermedades_sintomas
(
    id_sintoma    BIGINT,
    id_enfermedad BIGINT,
    PRIMARY KEY (id_sintoma, id_enfermedad),
    CONSTRAINT fk_enfermedad_sintoma_sintoma FOREIGN KEY (id_sintoma) REFERENCES sintomas (id_sintoma) ON UPDATE CASCADE,
    CONSTRAINT fk_enfermedad_sintoma_enfermedad FOREIGN KEY (id_enfermedad) REFERENCES enfermedades (id_enfermedad) ON UPDATE CASCADE
);
GO
CREATE TABLE vacunas_enfermedades
(
    id_vacuna     UNIQUEIDENTIFIER,
    id_enfermedad BIGINT,
    PRIMARY KEY (id_vacuna, id_enfermedad),
    CONSTRAINT fk_vacuna_enfermedad_vacuna FOREIGN KEY (id_vacuna) REFERENCES vacunas (id_vacuna) ON DELETE CASCADE,
    CONSTRAINT fk_vacuna_enfermedad_enfermedad FOREIGN KEY (id_enfermedad) REFERENCES enfermedades (id_enfermedad) ON DELETE CASCADE
);
GO

-- Triggers
-- Trigger para asignar automáticamente la región a las sedes cuando coincide con la provincia y/o distrito
CREATE TRIGGER tr_sedes_insert_region
    ON sedes
    AFTER INSERT
    AS
BEGIN
    UPDATE S
    SET region =
            CASE
                WHEN P.id_provincia = 1 THEN 'Bocas del Toro'
                WHEN P.id_provincia = 2 THEN 'Coclé'
                WHEN P.id_provincia = 3 THEN 'Colón'
                WHEN P.id_provincia = 4 THEN 'Chiriquí'
                WHEN P.id_provincia = 5 THEN 'Darién y la comarca Embera Waunán y Wargandí'
                WHEN P.id_provincia = 6 THEN 'Herrera'
                WHEN P.id_provincia = 7 THEN 'Los Santos'
                WHEN P.id_provincia = 8 AND D.id_distrito = 53 THEN 'San Miguelito'
                WHEN P.id_provincia = 8 AND D.id_distrito <> 53 THEN 'Panamá Norte/Este/Metro'
                WHEN P.id_provincia = 9 THEN 'Veraguas'
                WHEN P.id_provincia = 10 THEN 'Kuna Yala'
                WHEN P.id_provincia = 11 THEN 'Darién y la comarca Embera Waunán y Wargandí'
                WHEN P.id_provincia = 12 THEN 'Ngabe Buglé'
                WHEN P.id_provincia = 13 AND D.id_distrito <> 79 THEN 'Panamá Oeste'
                WHEN P.id_provincia = 13 AND D.id_distrito = 79 THEN 'Arraiján'
                WHEN P.id_provincia = 16 THEN 'Darién y la comarca Embera Waunán y Wargandí'
                ELSE 'n/a'
                END
    FROM sedes S
             INNER JOIN inserted I ON S.id_sede = I.id_sede
             INNER JOIN direcciones D ON I.id_direccion = D.id_direccion
             INNER JOIN distritos DD ON D.id_distrito = DD.id_distrito
             INNER JOIN provincias P ON DD.id_provincia = P.id_provincia
END;
GO
-- trigger para actualizar la edad calculada del paciente al momento de insertar o actualizar la fecha de nacimiento
CREATE TRIGGER tr_pacientes_update_edad
    ON pacientes
    AFTER INSERT, UPDATE
    AS
BEGIN
    UPDATE pacientes
    SET edad_calculada =
            IIF(DATEADD(YEAR, DATEDIFF(YEAR, fecha_nacimiento, GETDATE()), fecha_nacimiento) > GETDATE(),
                DATEDIFF(YEAR, fecha_nacimiento, GETDATE()) - 1, DATEDIFF(YEAR, fecha_nacimiento, GETDATE()))
    WHERE (edad_calculada IS NULL OR
           IIF(DATEADD(YEAR, DATEDIFF(YEAR, fecha_nacimiento, GETDATE()), fecha_nacimiento) > GETDATE(),
               DATEDIFF(YEAR, fecha_nacimiento, GETDATE()) - 1, DATEDIFF(YEAR, fecha_nacimiento, GETDATE())) <>
           edad_calculada);
END;
GO
-- trigger para mantener registro de cambios de usuarios
CREATE TRIGGER tr_usuarios_updated
    ON usuarios
    AFTER UPDATE
    AS
BEGIN
    UPDATE usuarios
    SET updated_at = CURRENT_TIMESTAMP
    WHERE id_usuario IN (SELECT id_usuario FROM INSERTED);
END
GO

-- Procedimientos
-- algunos procedimiento dan opcional el nombre tabla, los sistemas deben procurar usar el id y no el nombre
CREATE PROCEDURE spVacunas_UpdatePacienteEdad
AS
BEGIN
    UPDATE pacientes
    SET edad_calculada = DATEDIFF(YEAR, fecha_nacimiento, GETDATE())
    WHERE DATEPART(MONTH, fecha_nacimiento) = DATEPART(MONTH, GETDATE())
      AND DATEPART(DAY, fecha_nacimiento) = DATEPART(DAY, GETDATE());
END;
GO

CREATE PROCEDURE spVacunas_InsertSede @nombre_sede NVARCHAR(100),
                                      @dependencia_sede NVARCHAR(13),
                                      @correo_sede NVARCHAR(50) = NULL,
                                      @telefono_sede NVARCHAR(15) = NULL,
                                      @direccion_sede NVARCHAR(150) = NULL,
                                      @distrito_sede NVARCHAR(100) = NULL
AS
BEGIN
    BEGIN TRY

        DECLARE @id_direccion UNIQUEIDENTIFIER;

        -- Validar que dirección y distrito estén ambos campos o ninguno
        IF (@direccion_sede IS NOT NULL AND @distrito_sede IS NULL) OR
           (@direccion_sede IS NULL AND @distrito_sede IS NOT NULL)
            BEGIN
                RAISERROR ('Debe especificar ambos campos: dirección y distrito o ninguno.', 16, 1);
            END
        -- Validar la dependencia bien escrito
        IF (@dependencia_sede NOT LIKE 'CSS' AND @dependencia_sede NOT LIKE 'MINSA' AND
            @dependencia_sede NOT LIKE 'Privada' AND @dependencia_sede NOT LIKE 'Por registrar')
            BEGIN
                RAISERROR ('La dependencia de la sede debe ser MINSA o CSS o Privada, si no encuentra su opción no se puede registrar.', 16, 1);
            END
        -- Verifica si la sede ya existe
        IF EXISTS (SELECT 1 FROM sedes WHERE nombre_sede = @nombre_sede)
            BEGIN
                RAISERROR ('La sede con ese nombre ya existe.', 16, 1);
            END

        BEGIN TRANSACTION;

        -- Insertar la dirección si no existe
        IF @direccion_sede IS NOT NULL AND @distrito_sede IS NOT NULL
            BEGIN
                -- Verificar si la dirección ya existe
                SELECT @id_direccion = id_direccion
                FROM direcciones
                WHERE direccion = @direccion_sede;

                IF @id_direccion IS NULL
                    BEGIN
                        SET @id_direccion = NEWID();
                        -- Insertar nueva dirección
                        INSERT INTO direcciones (id_direccion, direccion, id_distrito)
                        VALUES (@id_direccion, @direccion_sede,
                                (SELECT id_distrito FROM distritos WHERE nombre_distrito = @distrito_sede))
                    END
            END
        ELSE
            BEGIN
                SELECT @id_direccion = id_direccion
                FROM direcciones
                WHERE direccion = 'Dirección por registrar'
                  AND id_distrito = 0
            END

        -- Insertar la sede
        INSERT INTO sedes (nombre_sede, dependencia_sede, correo_sede, telefono_sede, id_direccion)
        VALUES (@nombre_sede, @dependencia_sede, @correo_sede, @telefono_sede, @id_direccion);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

CREATE PROCEDURE spVacunas_GestionarPaciente @cedula_paciente NVARCHAR(20),
                                             @nombre_paciente NVARCHAR(50),
                                             @apellido1_paciente NVARCHAR(50),
                                             @apellido2_paciente NVARCHAR(50) = NULL,
                                             @fecha_nacimiento_paciente SMALLDATETIME,
                                             @sexo_paciente CHAR(1),
                                             @telefono_paciente NVARCHAR(15) = NULL,
                                             @correo_paciente NVARCHAR(50) = NULL,
                                             @direccion_residencial_paciente NVARCHAR(150) = NULL,
                                             @distrito_reside_paciente NVARCHAR(100) = NULL
AS
BEGIN
    BEGIN TRY
        -- Validar que dirección y distrito estén ambos campos o ninguno
        IF (@direccion_residencial_paciente IS NOT NULL AND @distrito_reside_paciente IS NULL) OR
           (@direccion_residencial_paciente IS NULL AND @distrito_reside_paciente IS NOT NULL)
            BEGIN
                RAISERROR ('Debe especificar ambos campos dirección y distrito o ninguno.', 16, 1);
            END

        -- Validar el sexo bien escrito
        IF (@sexo_paciente NOT LIKE 'M' AND @sexo_paciente NOT LIKE 'F')
            BEGIN
                RAISERROR ('Debe especificar el sexo como M masculino y F femenino.', 16, 1);
            END

        -- Validar fecha nacimiento en el formato esperado
        IF TRY_CAST(@fecha_nacimiento_paciente AS SMALLDATETIME) IS NULL OR
           TRY_CAST(@fecha_nacimiento_paciente AS DATE) IS NULL
            BEGIN
                RAISERROR ('Las fechas deben estar en el formato YYYY-MM-DD o YYYY/MM/DD y con hora opcional HH:MM:SS', 16, 1);
            END

        BEGIN TRANSACTION
            DECLARE @id_direccion UNIQUEIDENTIFIER;

            -- Insertar la dirección si no existe
            IF @direccion_residencial_paciente IS NOT NULL AND @distrito_reside_paciente IS NOT NULL
                BEGIN
                    -- Verificar si la dirección ya existe
                    SELECT @id_direccion = id_direccion
                    FROM direcciones
                    WHERE direccion = @direccion_residencial_paciente;

                    IF @id_direccion IS NULL
                        BEGIN
                            SET @id_direccion = NEWID();
                            -- Insertar nueva dirección
                            INSERT INTO direcciones (id_direccion, direccion, id_distrito)
                            VALUES (@id_direccion, @direccion_residencial_paciente, (SELECT id_distrito
                                                                                     FROM distritos
                                                                                     WHERE nombre_distrito = @distrito_reside_paciente));
                        END
                END
            ELSE
                BEGIN
                    -- Obtener el uuid de la dirección por defecto si es null
                    SELECT @id_direccion = id_direccion
                    FROM direcciones
                    WHERE direccion = 'Dirección por registrar'
                      AND id_distrito = 0
                END

            -- Verificar si el paciente ya existe
            IF EXISTS (SELECT 1 FROM pacientes WHERE cedula = @cedula_paciente)
                BEGIN
                    -- Actualizar el paciente si ya existe y los datos son diferentes
                    UPDATE pacientes
                    SET nombre_paciente    = @nombre_paciente,
                        apellido1_paciente = @apellido1_paciente,
                        apellido2_paciente = @apellido1_paciente,
                        fecha_nacimiento   = @fecha_nacimiento_paciente,
                        sexo               = @sexo_paciente,
                        telefono_paciente  = @telefono_paciente,
                        correo_paciente    = @correo_paciente,
                        id_direccion       = @id_direccion
                    WHERE cedula = @cedula_paciente
                      AND (nombre_paciente != @nombre_paciente OR
                           apellido1_paciente != @apellido1_paciente OR
                           apellido2_paciente != @apellido2_paciente OR
                           fecha_nacimiento != @fecha_nacimiento_paciente OR
                           sexo != @sexo_paciente OR
                           telefono_paciente != @telefono_paciente OR
                           correo_paciente != @correo_paciente OR
                           id_direccion != @id_direccion);
                END
            ELSE
                BEGIN
                    -- Insertar el paciente si no existe
                    INSERT INTO pacientes (cedula, nombre_paciente, apellido1_paciente, apellido2_paciente,
                                           fecha_nacimiento,
                                           sexo, telefono_paciente, correo_paciente, id_direccion)
                    VALUES (@cedula_paciente, @nombre_paciente, @apellido1_paciente, @apellido2_paciente,
                            @fecha_nacimiento_paciente,
                            @sexo_paciente, @telefono_paciente, @correo_paciente, @id_direccion);
                END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- modificar
CREATE PROCEDURE spVacunas_InsertDosis @cedula_paciente NVARCHAR(20),
                                       @fecha_aplicacion DATETIME,
                                       @numero_dosis CHAR(2),
                                       @uuid_vacuna UNIQUEIDENTIFIER NULL,
                                                                     @nombre_vacuna NVARCHAR(100) NULL,
    @id_sede UNIQUEIDENTIFIER NULL,
	@nombre_sede NVARCHAR(100) NULL,
    @lote NVARCHAR(10) = NULL
AS
BEGIN
    BEGIN TRY
        -- validar los datos opcionales tengan mínimo 1 dato para cada tabla
        IF @nombre_vacuna IS NULL AND @uuid_vacuna IS NULL
            BEGIN
                RAISERROR ('Debe especificar la vacuna por uuid o nombre.', 16, 1);
            END

        IF @id_sede IS NULL AND @nombre_sede IS NULL
            BEGIN
                RAISERROR ('Debe especificar la sede por uuid o nombre.', 16, 1);
            END

        IF @nombre_vacuna IS NOT NULL
            BEGIN
                SELECT @uuid_vacuna = id_vacuna
                FROM vacunas
                WHERE nombre_vacuna = @nombre_vacuna;

                -- Verificar si se encontró la vacuna
                IF @uuid_vacuna IS NULL
                    BEGIN
                        RAISERROR ('No se encontró ninguna vacuna con el nombre proporcionado.', 16, 1);
                    END
            END

        IF @nombre_sede IS NOT NULL
            BEGIN
                SELECT @id_sede = id_sede
                FROM sedes
                WHERE nombre_sede = @nombre_sede;

                -- Verificar si se encontró la vacuna
                IF @id_sede IS NULL
                    BEGIN
                        RAISERROR ('No se encontró ninguna sede con el nombre proporcionado.', 16, 1);
                    END
            END

        -- Verificar si la vacuna existe
        IF NOT EXISTS (SELECT 1 FROM vacunas WHERE id_vacuna = @uuid_vacuna)
            BEGIN
                RAISERROR ('La vacuna especificada no existe.', 16, 1);
            END

        -- Verificar si la sede existe
        IF NOT EXISTS (SELECT 1 FROM sedes WHERE id_sede = @id_sede)
            BEGIN
                RAISERROR ('La sede especificada no existe.', 16, 1);
            END

        -- Verificar si el paciente existe
        IF NOT EXISTS (SELECT 1 FROM pacientes WHERE cedula = @cedula_paciente)
            BEGIN
                RAISERROR ('El paciente no existe.', 16, 1);
            END

        -- Validar fecha aplicación en el formato esperado
        IF TRY_CAST(@fecha_aplicacion AS DATETIME) IS NULL OR TRY_CAST(@fecha_aplicacion AS DATE) IS NULL
            BEGIN
                RAISERROR ('Las fechas deben estar en el formato YYYY-MM-DD o YYYY/MM/DD y con hora opcional HH:MM:SS', 16, 1);
            END

        -- Verifica si la dosis vacuna - numero de dosis ya existe
        IF EXISTS (SELECT 1
                   FROM pacientes_dosis pd
                            INNER JOIN Dosis d ON pd.id_dosis = d.id_dosis
                   WHERE pd.cedula_paciente = @cedula_paciente
                     AND d.id_vacuna = @uuid_vacuna
                     AND d.numero_dosis = @numero_dosis)
            BEGIN
                RAISERROR ('La dosis para el paciente en esa vacuna y número de dosis ya existe.', 16, 1);
            END

        -- Validar dosis anteriores
        IF @numero_dosis <> '1' AND @numero_dosis <> 'P'
            BEGIN
                IF @numero_dosis = '2' AND NOT EXISTS (SELECT 1
                                                       FROM pacientes_dosis pd
                                                                JOIN Dosis d ON pd.id_dosis = d.id_dosis
                                                       WHERE pd.cedula_paciente = @cedula_paciente
                                                         AND d.numero_dosis = '1')
                    BEGIN
                        RAISERROR ('La dosis 1 debe ser aplicada antes de la dosis 2.', 16, 1);
                    END

                IF @numero_dosis = '3' AND NOT EXISTS (SELECT 1
                                                       FROM pacientes_dosis pd
                                                                JOIN Dosis d ON pd.id_dosis = d.id_dosis
                                                       WHERE pd.cedula_paciente = @cedula_paciente
                                                         AND d.numero_dosis = '1')
                    BEGIN
                        RAISERROR ('La dosis 1 debe ser aplicada antes de la dosis 3.', 16, 1);
                    END

                IF @numero_dosis = 'R' AND NOT EXISTS (SELECT 1
                                                       FROM pacientes_dosis pd
                                                                JOIN Dosis d ON pd.id_dosis = d.id_dosis
                                                       WHERE pd.cedula_paciente = @cedula_paciente
                                                         AND d.numero_dosis = '1')
                    BEGIN
                        RAISERROR ('La dosis 1 debe ser aplicada antes de la dosis R.', 16, 1);
                    END

                IF @numero_dosis = 'R1' AND NOT EXISTS (SELECT 1
                                                        FROM pacientes_dosis pd
                                                                 JOIN Dosis d ON pd.id_dosis = d.id_dosis
                                                        WHERE pd.cedula_paciente = @cedula_paciente
                                                          AND d.numero_dosis IN ('1', 'R'))
                    BEGIN
                        RAISERROR ('La dosis 1 o R debe ser aplicada antes de la dosis R1.', 16, 1);
                    END

                IF @numero_dosis = 'R2' AND NOT EXISTS (SELECT 1
                                                        FROM pacientes_dosis pd
                                                                 JOIN Dosis d ON pd.id_dosis = d.id_dosis
                                                        WHERE pd.cedula_paciente = @cedula_paciente
                                                          AND d.numero_dosis IN ('R1', '2'))
                    BEGIN
                        RAISERROR ('La dosis R1 o 2 debe ser aplicada antes de la dosis R2.', 16, 1);
                    END
            END
        ELSE
            IF @numero_dosis LIKE 'P'
                BEGIN
                    IF EXISTS (SELECT 1
                               FROM pacientes_dosis pd
                                        INNER JOIN dosis d ON pd.id_dosis = d.id_dosis
                               WHERE pd.cedula_paciente = @cedula_paciente)
                        BEGIN
                            RAISERROR ('La dosis "P" previa solo puede ser antes de la primera dosis.', 16, 1);
                        END
                END

        BEGIN TRANSACTION;
        DECLARE @CantidadDisponible INT;
        DECLARE @FechaLote DATETIME;
        DECLARE @id_dosis UNIQUEIDENTIFIER = NEWID();

        -- Verificar si hay registro en el inventario de la sede
        IF EXISTS (SELECT 1
                   FROM sedes_inventarios
                   WHERE id_sede = @id_sede
                     AND id_vacuna = @uuid_vacuna
                     AND lote_sede LIKE @Lote)
            BEGIN
                SELECT @CantidadDisponible = Cantidad, @FechaLote = fecha_lote_sede
                FROM sedes_inventarios
                WHERE id_sede = @id_sede
                  AND id_vacuna = @uuid_vacuna
                  AND lote_sede LIKE @Lote;

                IF @CantidadDisponible < 1
                    BEGIN
                        RAISERROR ('Cantidad insuficiente de dosis de la vacuna en el inventario de la sede.', 16, 1);
                    END

                IF @FechaLote <= CURRENT_TIMESTAMP
                    BEGIN
                        RAISERROR ('La fecha de vencimiento del lote de esta vacuna es el día de hoy o anterior.', 16, 1);
                    END
            END

        SET @numero_dosis = RTRIM(@numero_dosis);

        -- Insertar la nueva dosis
        INSERT INTO Dosis (id_dosis, fecha_aplicacion, numero_dosis, id_vacuna, id_sede)
        VALUES (@id_dosis, @fecha_aplicacion, @numero_dosis, @uuid_vacuna, @id_sede);

        -- Insertar la relación en Paciente_Dosis
        INSERT INTO pacientes_dosis (cedula_paciente, id_dosis)
        VALUES (@cedula_paciente, @id_dosis);

        -- Restar la cantidad del inventario de la sede solo si existe el registro
        IF EXISTS (SELECT 1
                   FROM sedes_inventarios
                   WHERE id_sede = @id_sede
                     AND id_vacuna = @uuid_vacuna
                     AND lote_sede LIKE @Lote)
            BEGIN
                UPDATE sedes_inventarios
                SET Cantidad = Cantidad - 1
                WHERE id_sede = @id_sede
                  AND id_vacuna = @uuid_vacuna
                  AND lote_sede LIKE @Lote;
            END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

CREATE PROCEDURE spVacunas_DistribuirVacunas @id_almacen SMALLINT NULL,
                                                                  @nombre_almacen NVARCHAR(100) NULL,
    @id_sede UNIQUEIDENTIFIER NULL,
	@nombre_sede NVARCHAR(100) NULL,
    @uuid_vacuna UNIQUEIDENTIFIER NULL,
	@nombre_vacuna NVARCHAR(100) NULL,
    @cantidad INT,
	@lote NVARCHAR(10)
AS
BEGIN
    BEGIN TRY
        -- Validar que se ingresó al menos 1 valor requerido para cada tabla
        IF @id_almacen IS NULL AND @nombre_almacen IS NULL
            BEGIN
                RAISERROR ('Debe especificar el almacen por su id o nombre', 16, 1);
            END

        IF @nombre_vacuna IS NULL AND @uuid_vacuna IS NULL
            BEGIN
                RAISERROR ('Debe especificar la vacuna por uuid o nombre.', 16, 1);
            END

        IF @id_sede IS NULL AND @nombre_sede IS NULL
            BEGIN
                RAISERROR ('Debe especificar la sede por uuid o nombre.', 16, 1);
            END

        IF @nombre_almacen IS NOT NULL
            BEGIN
                SELECT @id_almacen = id_almacen
                FROM almacenes
                WHERE nombre_almacen = @nombre_almacen;

                -- Verificar si se encontró la vacuna
                IF @id_almacen IS NULL
                    BEGIN
                        RAISERROR ('No se encontró ningún almacen con el nombre proporcionado.', 16, 1);
                    END
            END

        IF @nombre_vacuna IS NOT NULL
            BEGIN
                SELECT @uuid_vacuna = id_vacuna
                FROM vacunas
                WHERE nombre_vacuna = @nombre_vacuna;

                -- Verificar si se encontró la vacuna
                IF @uuid_vacuna IS NULL
                    BEGIN
                        RAISERROR ('No se encontró ninguna vacuna con el nombre proporcionado.', 16, 1);
                    END
            END

        IF @nombre_sede IS NOT NULL
            BEGIN
                SELECT @id_sede = id_sede
                FROM sedes
                WHERE nombre_sede = @nombre_sede;

                -- Verificar si se encontró la vacuna
                IF @id_sede IS NULL
                    BEGIN
                        RAISERROR ('No se encontró ninguna sede con el nombre proporcionado.', 16, 1);
                    END
            END

        IF NOT EXISTS (SELECT 1
                       FROM almacenes_inventarios
                       WHERE id_almacen = @id_almacen AND id_vacuna = @uuid_vacuna AND lote_almacen LIKE @lote)
            BEGIN
                RAISERROR ('No se pudo obtener información del lote de vacuna en el inventario almacen', 16, 1);
            END

        -- Verificar si hay suficiente cantidad en el inventario del almacén y si la fecha de lote es válida
        DECLARE @cantidad_disponible INT;
        DECLARE @fecha_lote DATETIME;
        SELECT @Cantidad_disponible = cantidad, @fecha_lote = fecha_lote_almacen
        FROM almacenes_inventarios
        WHERE id_almacen = @id_almacen
          AND id_vacuna = @uuid_vacuna
          AND lote_almacen LIKE @Lote;

        IF @cantidad_disponible < @Cantidad
            BEGIN
                RAISERROR ('Cantidad insuficiente en el almacén para poder distribuir.', 16, 1);
            END

        IF @fecha_lote < GETDATE()
            BEGIN
                RAISERROR ('No se puede distribuir un lote con fecha menor al día de hoy. Revisar inventario almacen', 16, 1);
            END

        BEGIN TRANSACTION;
        -- Restar la cantidad del inventario del almacén
        UPDATE almacenes_inventarios
        SET cantidad = cantidad - @cantidad
        WHERE id_almacen = @id_almacen
          AND id_vacuna = @uuid_vacuna
          AND lote_almacen LIKE @lote;

        -- Agregar la cantidad al inventario de la sede
        IF EXISTS (SELECT 1
                   FROM sedes_inventarios
                   WHERE id_sede = @id_sede AND id_vacuna = @uuid_vacuna AND lote_sede LIKE @lote)
            BEGIN
                UPDATE sedes_inventarios
                SET cantidad = cantidad + @Cantidad
                WHERE id_sede = @id_sede
                  AND id_vacuna = @uuid_vacuna
                  AND lote_sede LIKE @lote;
            END
        ELSE
            BEGIN
                INSERT INTO sedes_inventarios (id_sede, id_vacuna, Cantidad, Fecha_lote_sede, Lote_sede)
                VALUES (@id_sede, @uuid_vacuna, @cantidad, @fecha_lote, @lote);
            END

        -- Registrar la distribución
        INSERT INTO distribuciones_vacunas (id_almacen, id_sede, id_vacuna, cantidad, lote, fecha_distribucion)
        VALUES (@id_almacen, @id_sede, @uuid_vacuna, @Cantidad, @Lote, CURRENT_TIMESTAMP);

        -- Confirmar la transacción
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

CREATE PROCEDURE spVacunas_GestionarUsuario @cedula NVARCHAR(20),
                                            @usuario NVARCHAR(50),
                                            @clave_hash NVARCHAR(60),
                                            @fecha_nacimiento DATETIME,
                                            @correo_usuario NVARCHAR(254) = NULL
AS
BEGIN
    BEGIN TRY
        -- Validar fecha nacimiento en el formato esperado
        IF TRY_CAST(@fecha_nacimiento AS DATETIME) IS NULL OR TRY_CAST(@fecha_nacimiento AS DATE) IS NULL
            BEGIN
                RAISERROR ('Las fechas deben estar en el formato YYYY-MM-DD o YYYY/MM/DD y con hora opcional HH:MM:SS', 16, 1);
            END
        BEGIN TRANSACTION
            -- Verificar si el usuario ya existe
            IF EXISTS (SELECT 1 FROM usuarios WHERE cedula = @cedula)
                BEGIN
                    -- Si existe, actualizar el registro
                    UPDATE usuarios
                    SET usuario          = @usuario,
                        clave_hash       = @clave_hash,
                        fecha_nacimiento = @fecha_nacimiento,
                        correo_usuario   = @correo_usuario,
                        last_used        = CURRENT_TIMESTAMP
                    WHERE cedula = @cedula
                      AND (usuario != @usuario OR
                           clave_hash != @clave_hash OR
                           fecha_nacimiento != @fecha_nacimiento OR
                           correo_usuario != @correo_usuario);
                END
            ELSE
                BEGIN
                    -- Si no existe, insertar un nuevo registro
                    INSERT INTO Usuarios (cedula, usuario, clave_hash, fecha_nacimiento, correo_usuario)
                    VALUES (@Cedula, @Usuario, @clave_hash, @fecha_nacimiento, @correo_usuario);
                END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

CREATE PROCEDURE spVacunas_InsertRolesUsuario @cedula NVARCHAR(20),
                                              @roles NVARCHAR(MAX) -- cadena delimitada por comas los roles
AS
BEGIN
    BEGIN TRY
        DECLARE @id_usuario UNIQUEIDENTIFIER;
        DECLARE @roles_tabla TABLE
                             (
                                 id_rol INT
                             ); -- tabla temporal para almacenar la cadena de roles
        SELECT @id_usuario = id_usuario FROM usuarios WHERE cedula = @cedula
        BEGIN TRANSACTION
            -- Convertir la cadena delimitada en la tabla temporal
            INSERT INTO @roles_tabla (id_rol)
            SELECT value
            FROM string_split(@roles, ',')

            -- Eliminar los roles existentes
            DELETE FROM usuarios_roles WHERE id_usuario = @id_usuario

            -- Insertar los roles nuevos
            INSERT INTO usuarios_roles (id_usuario, id_rol)
            SELECT @id_usuario, id_rol
            FROM @roles_tabla
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

CREATE PROCEDURE spVacunas_InsertVacunaEnfermedad @uuid_vacuna UNIQUEIDENTIFIER NULL,
                                                                                @nombre_vacuna NVARCHAR(100) NULL,
	@id_enfermedad BIGINT NULL,
	@nombre_enfermedad NVARCHAR(100) NULL
AS
BEGIN
    BEGIN TRY
        -- Validar que se ingresó al menos 1 valor requerido para cada tabla
        IF @nombre_vacuna IS NULL AND @uuid_vacuna IS NULL
            BEGIN
                RAISERROR ('Debe especificar la vacuna por uuid o nombre.', 16, 1);
            END

        IF @nombre_enfermedad IS NULL AND @id_enfermedad IS NULL
            BEGIN
                RAISERROR ('Debe especificar la enfermedad por id o nombre.', 16, 1);
            END

        -- Obtener uuid_vacuna si se proporcionó nombre_vacuna
        IF @nombre_vacuna IS NOT NULL
            BEGIN
                SELECT @uuid_vacuna = id_vacuna
                FROM vacunas
                WHERE nombre_vacuna = @nombre_vacuna;

                -- Verificar si se encontró la vacuna
                IF @uuid_vacuna IS NULL
                    BEGIN
                        RAISERROR ('No se encontró ninguna vacuna con el nombre proporcionado.', 16, 1);
                    END
            END

        -- Obtener id_enfermedad si se proporcionó nombre_enfermedad
        IF @nombre_enfermedad IS NOT NULL
            BEGIN
                SELECT @id_enfermedad = id_enfermedad FROM enfermedadeS WHERE nombre_enfermedad = @nombre_enfermedad

                IF @id_enfermedad IS NULL
                    BEGIN
                        RAISERROR ('No se encontró ninguna enfermedad con el nombre proporcionado.', 16, 1);
                    END
            END

        BEGIN TRANSACTION
            INSERT INTO vacunas_enfermedades (id_vacuna, id_enfermedad)
            VALUES (@uuid_vacuna, @id_enfermedad);
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END
GO

CREATE PROCEDURE spVacunas_InsertFabricanteVacuna @id_fabricante INT NULL,
                                                                     @nombre_fabricante NVARCHAR(100) NULL,
	@uuid_vacuna UNIQUEIDENTIFIER NULL,
	@nombre_vacuna NVARCHAR(100) NULL

AS
BEGIN
    BEGIN TRY
        -- validar que se ingresó al menos 1 valor requerido para cada tabla
        IF @id_fabricante IS NULL AND @nombre_fabricante IS NULL
            BEGIN
                RAISERROR ('Debe especificar un fabricante por su id o nombre.', 16, 1);
            END

        IF @nombre_vacuna IS NULL AND @uuid_vacuna IS NULL
            BEGIN
                RAISERROR ('Debe especificar la vacuna por uuid o nombre.', 16, 1);
            END

        -- Obtener id_fabricante si se proporcionó nombre_fabricante
        IF @nombre_fabricante IS NOT NULL
            BEGIN
                SELECT @id_fabricante = id_fabricante FROM fabricantes WHERE nombre_fabricante = @nombre_fabricante;

                IF @id_fabricante IS NULL
                    BEGIN
                        RAISERROR ('No se encontró ningún fabricante con el nombre proporcionado.', 16, 1);
                    END
            END

        -- Obtener uuid_vacuna si se proporcionó nombre_vacuna
        IF @nombre_vacuna IS NOT NULL
            BEGIN
                SELECT @uuid_vacuna = id_vacuna
                FROM vacunas
                WHERE nombre_vacuna = @nombre_vacuna;

                -- Verificar si se encontró la vacuna
                IF @uuid_vacuna IS NULL
                    BEGIN
                        RAISERROR ('No se encontró ninguna vacuna con el nombre proporcionado.', 16, 1);
                    END
            END

        BEGIN TRANSACTION
            INSERT INTO fabricantes_vacunas(id_fabricante, id_vacuna)
            VALUES (@id_fabricante, @uuid_vacuna);
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END
GO

CREATE PROCEDURE spVacunas_InsertAlmacenInventario @id_almacen SMALLINT NULL,
                                                                        @nombre_almacen NVARCHAR(100) NULL,
	@uuid_vacuna UNIQUEIDENTIFIER NULL,
	@nombre_vacuna NVARCHAR(100) NULL,
	@cantidad INT,
	@fecha_lote_almacen DATETIME,
	@lote_almacen NVARCHAR(10)
AS
BEGIN
    BEGIN TRY
        -- Validar que se ingresó al menos 1 valor requerido para cada tabla
        IF @id_almacen IS NULL AND @nombre_almacen IS NULL
            BEGIN
                RAISERROR ('Debe especificar el almacen por su id o nombre', 16, 1);
            END

        IF @nombre_vacuna IS NULL AND @uuid_vacuna IS NULL
            BEGIN
                RAISERROR ('Debe especificar la vacuna por uuid o nombre.', 16, 1);
            END

        IF @nombre_almacen IS NOT NULL
            BEGIN
                SELECT @id_almacen = id_almacen
                FROM almacenes
                WHERE nombre_almacen = @nombre_almacen;

                -- Verificar si se encontró la vacuna
                IF @id_almacen IS NULL
                    BEGIN
                        RAISERROR ('No se encontró ningún almacen con el nombre proporcionado.', 16, 1);
                    END
            END

        IF @nombre_vacuna IS NOT NULL
            BEGIN
                SELECT @uuid_vacuna = id_vacuna
                FROM vacunas
                WHERE nombre_vacuna = @nombre_vacuna;

                -- Verificar si se encontró la vacuna
                IF @uuid_vacuna IS NULL
                    BEGIN
                        RAISERROR ('No se encontró ninguna vacuna con el nombre proporcionado.', 16, 1);
                    END
            END

        -- Validar fecha del lote en el formato esperado
        IF TRY_CAST(@fecha_lote_almacen AS DATETIME) IS NULL OR TRY_CAST(@fecha_lote_almacen AS DATE) IS NULL
            BEGIN
                RAISERROR ('Las fechas deben estar en el formato YYYY-MM-DD o YYYY/MM/DD y con hora opcional HH:MM:SS', 16, 1);
            END

        IF @fecha_lote_almacen <= CURRENT_TIMESTAMP
            BEGIN
                RAISERROR ('La fecha de vencimiento del lote de la vacuna no puede ser pasada.', 16, 1);
            END

        BEGIN TRANSACTION
            INSERT INTO almacenes_inventarios (id_almacen, id_vacuna, cantidad, fecha_lote_almacen, lote_almacen)
            VALUES (@id_almacen, @uuid_vacuna, @cantidad, @fecha_lote_almacen, @lote_almacen);
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END
GO
-- Funciones
CREATE FUNCTION fnVacunas_GetPacienteByFullName(
    @nombre_completo NVARCHAR(100) = NULL
)
    RETURNS TABLE
        AS
        RETURN(SELECT*
               FROM pacientes
               WHERE CONCAT(nombre_paciente, SPACE(1), apellido1_paciente) = @nombre_completo);
GO

CREATE FUNCTION fnVacunas_FindFabricante(
    @id_fabricante INT = NULL,
    @id_vacuna UNIQUEIDENTIFIER = NULL
)
    RETURNS TABLE
        AS
        RETURN(SELECT f.id_fabricante,
                      f.nombre_fabricante,
                      f.telefono_fabricante,
                      f.correo_fabricante,
                      f.direccion_fabricante,
                      f.contacto_fabricante
               FROM fabricantes f
                        LEFT JOIN
                    fabricantes_vacunas fv ON f.id_fabricante = fv.id_fabricante
               WHERE (f.id_fabricante = @id_fabricante OR @id_fabricante IS NULL)
                 AND (fv.id_vacuna = @id_vacuna OR @id_vacuna IS NULL));
GO

CREATE FUNCTION fnVacunas_FindDosis(
    @id_vacuna UNIQUEIDENTIFIER = NULL,
    @cedula_paciente NVARCHAR(20) = NULL,
    @numero_dosis CHAR(2) = NULL,
    @fecha_aplicacion DATETIME = NULL,
    @id_sede UNIQUEIDENTIFIER = NULL
)
    RETURNS TABLE
        AS
        RETURN(SELECT d.id_dosis,
                      d.fecha_aplicacion,
                      d.numero_dosis,
                      d.id_vacuna,
                      d.id_sede
               FROM dosis d
                        LEFT JOIN
                    pacientes_dosis pd ON d.id_dosis = pd.id_dosis
               WHERE (d.id_vacuna = @id_vacuna OR @id_vacuna IS NULL)
                 AND (pd.cedula_paciente = @cedula_paciente OR @cedula_paciente IS NULL)
                 AND (d.numero_dosis = @numero_dosis OR @numero_dosis IS NULL)
                 AND (d.fecha_aplicacion = @fecha_aplicacion OR @fecha_aplicacion IS NULL)
                 AND (d.id_sede = @id_sede OR @id_sede IS NULL));
GO

CREATE FUNCTION fnVacunas_GetUsuariosByCedula(@cedula NVARCHAR(20))
    RETURNS TABLE
        AS
        RETURN(SELECT u.id_usuario
                          cedula,
                      usuario,
                      fecha_nacimiento,
                      correo_usuario,
                      created_at,
                      r.id_rol
                          nombre_rol
               FROM usuarios u
                        INNER JOIN usuarios_roles r ON u.id_usuario = r.id_usuario
                        INNER JOIN roles ON r.id_rol = roles.id_rol
               WHERE cedula = @cedula);
GO

-- Vistas
/* ejemplo de uso
SELECT
    Provincia,
    COUNT(*) AS TotalVacunas
FROM
    [Reporte Vacunas Completo]
GROUP BY
    Provincia;
*/

/* ejemplo de uso
SELECT Vacuna, Cantidad, Lote, [Fecha Lote]  FROM [Sede - Inventario]
WHERE ID_Sede = 1
*/
CREATE VIEW view_PacientesVacunasEnfermedades AS
SELECT p.cedula                      AS 'Cédula',
       p.nombre_paciente             AS 'Nombre',
       p.apellido1_paciente          AS 'Apellido 1',
       p.apellido2_paciente          AS 'Apellido 2',
       p.fecha_nacimiento            AS 'Fecha de Nacimiento',
       p.edad_calculada              AS 'Edad',
       p.sexo                        AS 'Sexo',
       p.telefono_paciente           AS 'Teléfono',
       p.correo_paciente             AS 'Correo electrónico',
       d.direccion                   AS 'Dirección residencia actual',
       dis.nombre_distrito           AS 'Distrito',
       prov.nombre_provincia         AS 'Provincia',
       vac.nombre_vacuna             AS 'Nombre vacuna',
       dos.numero_dosis              AS 'Número de dosis',
       e.nombre_enfermedad           AS 'Enfermedad previene',
       vac.edad_minima_meses         AS 'Edad mínima recomendada en meses',
       dos.fecha_aplicacion          AS 'Fecha de aplicación',
       vac.intervalo_dosis_1_2_meses AS 'Intervalo recomendado entre dosis 1 y 2 en meses',
       s.nombre_sede                 AS 'Sede',
       s.dependencia_sede            AS 'Dependencia'
FROM pacientes p
         JOIN pacientes_dosis pd ON p.cedula = pd.cedula_paciente
         JOIN dosis dos ON pd.id_dosis = dos.id_dosis
         JOIN vacunas vac ON dos.id_vacuna = vac.id_vacuna
         LEFT JOIN vacunas_enfermedades ve ON vac.id_vacuna = ve.id_vacuna
         LEFT JOIN enfermedades e ON ve.id_enfermedad = e.id_enfermedad
         LEFT JOIN sedes s ON dos.id_sede = s.id_sede
         LEFT JOIN direcciones d ON p.id_direccion = d.id_direccion
         LEFT JOIN distritos dis ON d.id_distrito = dis.id_distrito
         LEFT JOIN provincias prov ON dis.id_provincia = prov.id_provincia;
GO

CREATE VIEW view_PacientesDetalles AS
SELECT p.cedula                      AS 'Cédula',
       p.nombre_paciente             AS 'Nombre',
       p.apellido1_paciente          AS 'Apellido 1',
       p.apellido1_paciente          AS 'Apellido 2',
       p.fecha_nacimiento            AS 'Fecha de Nacimiento',
       p.edad_calculada              AS 'Edad',
       p.sexo                        AS 'Sexo',
       p.telefono_paciente           AS 'Teléfono',
       p.correo_paciente             AS 'Correo electrónico',
       d.direccion                   AS 'Dirección residencia actual',
       dis.nombre_distrito           AS 'Distrito',
       prov.nombre_provincia         AS 'Provincia',
       vac.id_vacuna                 AS 'ID Vacuna',
       vac.nombre_vacuna             AS 'Nombre vacuna',
       pp.nombre_fabricante          AS 'Fabricante',
       dos.fecha_aplicacion          AS 'Fecha de aplicación',
       s.id_sede                     AS 'ID Sede',
       s.nombre_sede                 AS 'Sede',
       s.dependencia_sede            AS 'Dependencia',
       dos.numero_dosis              AS 'Número de dosis',
       vac.intervalo_dosis_1_2_meses AS 'Intervalo dosis 1 y 2 recomendado en meses',
       DATEDIFF(DAY, dos.fecha_aplicacion,
                (SELECT MAX(dos2.fecha_aplicacion)
                 FROM dosis dos2
                          JOIN pacientes_dosis pd2 ON dos2.id_dosis = pd2.id_dosis
                 WHERE pd2.cedula_paciente = p.cedula
                   AND dos2.id_vacuna = dos.id_vacuna
                   AND dos2.numero_dosis > dos.numero_dosis))
                                     AS 'Intervalo real en días',
       vac.edad_minima_meses         AS 'Edad mínima recomendada en meses'
FROM pacientes p
         JOIN pacientes_dosis pd ON p.cedula = pd.cedula_paciente
         JOIN dosis dos ON pd.id_dosis = dos.id_dosis
         JOIN vacunas vac ON dos.id_vacuna = vac.id_vacuna
         LEFT JOIN fabricantes_vacunas pv ON vac.id_vacuna = pv.id_vacuna
         LEFT JOIN fabricantes pp ON pv.id_fabricante = pp.id_fabricante
         LEFT JOIN sedes s ON dos.id_sede = s.id_sede
         LEFT JOIN direcciones d ON p.id_direccion = d.id_direccion
         LEFT JOIN distritos dis ON d.id_distrito = dis.id_distrito
         LEFT JOIN provincias prov ON dis.id_provincia = prov.id_provincia;
GO

CREATE VIEW view_PacientesUsuarios AS
SELECT p.cedula              AS 'Cédula',
       p.nombre_paciente     AS 'Nombre',
       p.apellido1_paciente  AS 'Apellido 1',
       p.apellido2_paciente  AS 'Apellido 2',
       p.fecha_nacimiento    AS 'Fecha de nacimiento paciente',
       p.edad_calculada      AS 'Edad',
       p.sexo                AS 'Sexo',
       p.telefono_paciente   AS 'Teléfono',
       p.correo_paciente     AS 'Correo electrónico paciente',
       d.direccion           AS 'Dirección residencia actual',
       dis.nombre_distrito   AS 'Distrito',
       prov.nombre_provincia AS 'Provincia',
       u.usuario             AS 'Usuario',
       u.correo_usuario      AS 'Correo electrónico usuario',
       u.fecha_nacimiento    AS 'Fecha de nacimiento usuario'
FROM pacientes p
         LEFT JOIN direcciones d ON p.id_direccion = d.id_direccion
         LEFT JOIN distritos dis ON d.id_distrito = dis.id_distrito
         LEFT JOIN provincias prov ON dis.id_provincia = prov.id_provincia
         LEFT JOIN usuarios u ON p.cedula = u.cedula;
GO

CREATE VIEW view_PacientesCompletos AS
SELECT p.cedula                      AS 'Cédula paciente',
       p.nombre_paciente             AS 'Nombre paciente',
       p.apellido1_paciente          AS 'Apellido 1 paciente',
       p.apellido2_paciente          AS 'Apellido 2 paciente',
       p.fecha_nacimiento            AS 'Fecha de nacimiento paciente',
       p.edad_calculada              AS 'Edad',
       p.sexo                        AS 'Sexo',
       p.telefono_paciente           AS 'Teléfono paciente',
       p.correo_paciente             AS 'Correo electrónico paciente',
       d.direccion                   AS 'Dirección residencial actual paciente',
       dis.nombre_distrito           AS 'Distrito paciente',
       prov.nombre_provincia         AS 'Provincia paciente',
       s.nombre_sede                 AS 'Sede vacunado',
       d2.direccion                  AS 'Dirección sede',
       dis2.nombre_distrito          AS 'Distrito sede',
       prov2.nombre_provincia        AS 'Provincia sede',
       s.telefono_sede               AS 'Teléfono sede',
       s.region                      AS 'Región de salud sede',
       s.dependencia_sede            AS 'Depedencia sede',
       vac.nombre_vacuna             AS 'Nombre vacuna',
       dos.fecha_aplicacion          AS 'Fecha de aplicación',
       dos.numero_dosis              AS 'Número de dosis aplicada',
       vac.intervalo_dosis_1_2_meses AS 'Intervalo dosis recomendado en meses',
       DATEDIFF(DAY, dos.fecha_aplicacion,
                (SELECT MAX(dos2.fecha_aplicacion)
                 FROM dosis dos2
                          JOIN pacientes_dosis pd2 ON dos2.id_dosis = pd2.id_dosis
                 WHERE pd2.cedula_paciente = p.cedula
                   AND dos2.id_vacuna = dos.id_vacuna
                   AND dos2.numero_dosis > dos.numero_dosis))
                                     AS 'Intervalo real en días',
       vac.edad_minima_meses         AS 'Edad mínima recomendada en meses',
       e.nombre_enfermedad           AS 'Enfermedad prevenida',
       e.nivel_gravedad              AS 'Nivel de gravedad enfermedad'
FROM pacientes p
         LEFT JOIN direcciones d ON p.id_direccion = d.id_direccion
         LEFT JOIN distritos dis ON d.id_distrito = dis.id_distrito
         LEFT JOIN provincias prov ON dis.id_provincia = prov.id_provincia
         LEFT JOIN pacientes_dosis pd ON p.cedula = pd.cedula_paciente
         LEFT JOIN dosis dos ON pd.id_dosis = dos.id_dosis
         LEFT JOIN vacunas vac ON dos.id_vacuna = vac.id_vacuna
         LEFT JOIN vacunas_enfermedades ve ON vac.id_vacuna = ve.id_vacuna
         LEFT JOIN enfermedades e ON ve.id_enfermedad = e.id_enfermedad
         LEFT JOIN sedes s ON dos.id_sede = s.id_sede
         LEFT JOIN direcciones d2 ON s.id_direccion = d2.id_direccion
         LEFT JOIN distritos dis2 ON d2.id_distrito = dis2.id_distrito
         LEFT JOIN provincias prov2 ON dis2.id_provincia = prov2.id_provincia;
GO

CREATE VIEW view_FabricantesVacunas AS
SELECT p.nombre_fabricante         AS 'Nombre fabricante',
       v.nombre_vacuna             AS 'Vacuna ofrecida',
       v.edad_minima_meses         AS 'Edad mínima recomendada en meses',
       v.intervalo_dosis_1_2_meses AS 'Intervalo recomendado dosis 1 y 2 en meses',
       e.nombre_enfermedad         AS 'Enfermedad que previene',
       e.nivel_gravedad            AS 'Nivel de gravedad enfermedad'
FROM fabricantes p
         JOIN fabricantes_vacunas pv ON pv.id_fabricante = p.id_fabricante
         JOIN vacunas v ON pv.id_vacuna = v.id_vacuna
         LEFT JOIN vacunas_enfermedades ve ON v.id_vacuna = ve.id_vacuna
         LEFT JOIN enfermedades e ON ve.id_enfermedad = e.id_enfermedad;
GO

CREATE VIEW view_ReporteVacunas AS
SELECT p.cedula                    AS cedula_paciente,
       p.nombre_paciente           AS nombre_paciente,
       p.apellido1_paciente        AS apellido1_paciente,
       p.apellido2_paciente        AS apellido2_paciente,
       p.fecha_nacimiento          AS fecha_nacimiento_paciente,
       p.sexo                      AS sexo_paciente,
       p.telefono_paciente         AS telefono_paciente,
       p.correo_paciente           AS correo_paciente,
       v.nombre_vacuna             AS nombre_vacuna,
       d.fecha_aplicacion          AS fecha_aplicacion,
       d.numero_dosis              AS numero_dosis,
       v.intervalo_dosis_1_2_meses AS intervalo_dosis_recomendado_en_meses,
       DATEDIFF(DAY, d.fecha_aplicacion,
                (SELECT MAX(dos2.fecha_aplicacion)
                 FROM dosis dos2
                          JOIN pacientes_dosis pd2 ON dos2.id_dosis = pd2.id_dosis
                 WHERE pd2.cedula_paciente = p.cedula
                   AND dos2.id_vacuna = d.id_vacuna
                   AND dos2.numero_dosis > d.numero_dosis))
                                   AS intervalo_real_en_dias,
       v.edad_minima_meses         AS edad_minima_recomendada_en_meses,
       s.id_sede                   AS id_sede,
       s.nombre_sede               AS nombre_sede,
       dir.direccion               AS direccion_sede,
       dis.nombre_distrito         AS distrito,
       prov.nombre_provincia       AS provincia
FROM pacientes p
         JOIN pacientes_dosis pd ON p.cedula = pd.cedula_paciente
         JOIN dosis d ON pd.id_dosis = d.id_dosis
         JOIN vacunas v ON d.id_vacuna = v.id_vacuna
         JOIN sedes s ON d.id_sede = s.id_sede
         LEFT JOIN direcciones dir ON s.id_direccion = dir.id_direccion
         LEFT JOIN distritos dis ON dir.id_distrito = dis.id_distrito
         LEFT JOIN provincias prov ON dis.id_provincia = prov.id_provincia;
GO

CREATE VIEW view_EnfermedadesSintomas AS
SELECT v.nombre_vacuna     AS vacuna,
       e.nombre_enfermedad AS enfermedad_prevenida,
       e.nivel_gravedad    AS nivel_gravedad_enfermedad,
       s.nombre_sintoma    AS sintomas_enfermedad
FROM vacunas_enfermedades ve
         LEFT JOIN vacunas v ON ve.id_vacuna = v.id_vacuna
         LEFT JOIN enfermedades e ON ve.id_enfermedad = e.id_enfermedad
         LEFT JOIN enfermedades_sintomas es ON e.id_enfermedad = es.id_enfermedad
         LEFT JOIN sintomas s ON es.id_sintoma = s.id_sintoma;
GO

CREATE VIEW view_SedesInventarios AS
SELECT s.id_sede,
       s.nombre_sede      AS nombre_sede,
       s.dependencia_sede AS dependencia_sede,
       v.id_vacuna        AS id_vacuna,
       v.nombre_vacuna    AS vacuna,
       si.cantidad        AS cantidad,
       si.lote_sede       AS lote,
       si.fecha_lote_sede AS fecha_lote
FROM sedes_inventarios si
         INNER JOIN sedes s ON si.id_sede = s.id_sede
         INNER JOIN vacunas v ON si.id_vacuna = v.id_vacuna;
GO

INSERT INTO provincias(nombre_provincia)
VALUES ('Provincia por registrar' /*0*/),
       ('Bocas del Toro'), /*1*/
       ('Coclé'), /*2*/
       ('Colón'), /*3*/
       ('Chiriquí'), /*4*/
       ('Darién'), /*5*/
       ('Herrera'), /*6*/
       ('Los Santos'), /*7*/
       ('Panamá'), /*8*/
       ('Veraguas'), /*9*/
       ('Guna Yala'), /*10*/
       ('Emberá-Wounaan'), /*11*/
       ('Ngäbe-Buglé'),/*12*/
       ('Panamá Oeste'), /*13*/
       ('Naso Tjër Di'), /*14*/
       ('Guna de Madugandí'), /*15*/
       ('Guna de Wargandí'); /*16*/
GO
INSERT INTO distritos(nombre_distrito, id_provincia)
VALUES ('Distrito por registrar', 0),
       ('Aguadulce', 2),
       ('Alanje', 4),
       ('Almirante', 1),
       ('Antón', 2),
       ('Arraiján', 13),
       ('Atalaya', 9),
       ('Balboa', 8),
       ('Barú', 4),
       ('Besikó', 12),
       ('Bocas del Toro', 1),
       ('Boquerón', 4),
       ('Boquete', 4),
       ('Bugaba', 4),
       ('Calobre', 9),
       ('Calovébora', 12),
       ('Cañazas', 9),
       ('Capira', 13),
       ('Chagres', 3),
       ('Chame', 13),
       ('Changuinola', 1),
       ('Chepigana', 5),
       ('Chepo', 8),
       ('Chimán', 8),
       ('Chiriquí Grande', 1),
       ('Chitré', 6),
       ('Colón', 3),
       ('Cémaco', 11),
       ('David', 4),
       ('Donoso', 3),
       ('Dolega', 4),
       ('Gualaca', 4),
       ('Guararé', 7),
       ('Guna de Wargandí', 5),
       ('Jirondai', 12),
       ('Kankintú', 12),
       ('Kusapín', 12),
       ('La Chorrera', 13),
       ('La Mesa', 9),
       ('La Pintada', 2),
       ('Las Minas', 6),
       ('Las Palmas', 9),
       ('Las Tablas', 7),
       ('Los Pozos', 6),
       ('Los Santos', 7),
       ('Macaracas', 7),
       ('Mariato', 9),
       ('Mironó', 12),
       ('Montijo', 9),
       ('Müna', 12),
       ('Natá', 2),
       ('Nole Duima', 12),
       ('Ñürüm', 12),
       ('Ocú', 6),
       ('Olá', 2),
       ('Omar Torrijos Herrera', 3),
       ('Panamá', 8),
       ('Parita', 6),
       ('Pedasí', 7),
       ('Penonomé', 2),
       ('Pesé', 6),
       ('Pinogana', 5),
       ('Pocrí', 7),
       ('Portobelo', 3),
       ('Remedios', 4),
       ('Renacimiento', 4),
       ('Río de Jesús', 9),
       ('Sambú', 11),
       ('San Carlos', 13),
       ('San Félix', 4),
       ('San Francisco', 9),
       ('San Lorenzo', 4),
       ('San Miguelito', 8),
       ('Santa Catalina', 12),
       ('Santa Fe', 5),
       ('Santa Fe', 9),
       ('Santa Isabel', 3),
       ('Santa María', 6),
       ('Santiago', 9),
       ('Soná', 9),
       ('Taboga', 8),
       ('Tierras Altas', 4),
       ('Tolé', 4),
       ('Tonosí', 7),
       ('Naso Tjër Di', 14)
GO
INSERT INTO direcciones (direccion, id_distrito)
VALUES ('Dirección por registrar', 0);
GO
EXEC dbo.spVacunas_InsertSede 'Sede por registrar', 'Por registrar', NULL, NULL, NULL, NULL;
GO
INSERT INTO enfermedades (nombre_enfermedad, nivel_gravedad)
VALUES ('Desconocida', NULL),
       ('Bacteriemia', 'Alta'),
       ('COVID-19', 'Alta'),
       ('Difteria', 'Alta'),
       ('Enfermedad meningocócica', 'Alta'),
       ('Enfermedades neumocócicas', 'Alta'),
       ('Fiebre Amarilla', 'Alta'),
       ('Hepatitis A', 'Moderada'),
       ('Hepatitis B', 'Moderada'),
       ('Hib (Haemophilus influenzae tipo b)', 'Alta'),
       ('Influenza (Gripe)', 'Moderada'),
       ('Meningitis', 'Alta'),
       ('Neumonía', 'Moderada'),
       ('Paperas', 'Moderada'),
       ('Poliomelitis (Polio)', 'Alta'),
       ('Rabia', 'Alta'),
       ('Rotavirus', 'Moderada'),
       ('Rubéola', 'Moderada'),
       ('Sarampión', 'Alta'),
       ('Tétanos', 'Alta'),
       ('Tos ferina', 'Alta'),
       ('Tuberculosis', 'Alta'),
       ('Varicela', 'Moderada'),
       ('Virus del papiloma humano (VPH)', 'Moderada');
GO
INSERT INTO sintomas (nombre_sintoma)
VALUES ('Desconocido'),
       ('Ataques de tos'),
       ('Cáncer de cuello uterino'),
       ('Confusión'),
       ('Conjuntivitis'),
       ('Convulsiones'),
       ('Diarrea grave'),
       ('Dificultad para respirar'),
       ('Dolor abdominal'),
       ('Dolor de cabeza'),
       ('Dolor de garganta'),
       ('Dolor e hinchazón en las glándulas salivales'),
       ('Dolor en el pecho'),
       ('Dolor muscular'),
       ('Erupción cutánea característica'),
       ('Escalofríos'),
       ('Espasmos'),
       ('Fatiga'),
       ('Fiebre'),
       ('Formación de una membrana gruesa en la garganta'),
       ('Ganglios inflamados'),
       ('Ictericia'),
       ('Infección de la sangre'),
       ('Meningitis'),
       ('Náuseas'),
       ('Neumonía'),
       ('Orina oscura'),
       ('Otros tipos de cáncer'),
       ('Parálisis'),
       ('Pérdida de peso'),
       ('Pérdida del gusto o olfato'),
       ('Picazón'),
       ('Poco apetito'),
       ('Rigidez en el cuello'),
       ('Rigidez muscular'),
       ('Secreción nasal'),
       ('Sensibilidad a la luz'),
       ('Sepsis'),
       ('Sudores nocturnos'),
       ('Tos intensa y persistente'),
       ('Tos persistente'),
       ('Tos');
GO
INSERT INTO enfermedades_sintomas (id_enfermedad, id_sintoma)
VALUES
-- Enfermedad desconocida
(0, 0),   -- Síntomas desconocido
-- usado para registrar posteriormente la vacuna - enfermedad donde una vacuna por registrar tendrá su enfermedad desconocida y síntomas desconocidos

-- Bacteriemia
(1, 18),  -- Fiebre
(1, 16),  -- Escalofríos
(1, 35),  -- Sepsis

-- COVID-19
(2, 18),  -- Fiebre
(2, 40),  -- Tos persistente
(2, 7),   -- Dificultad para respirar
(2, 16),  -- Fatiga
(2, 29),  -- Pérdida del gusto o olfato
(2, 13),  -- Dolor muscular
(2, 9),   -- Dolor de cabeza

-- Difteria
(3, 18),  -- Fiebre
(3, 10),  -- Dolor de garganta
(3, 19),  -- Formación de una membrana gruesa en la garganta
(3, 7),   -- Dificultad para tragar
(3, 20),  -- Ganglios inflamados

-- Enfermedad meningocócica
(4, 18),  -- Fiebre
(4, 9),   -- Dolor de cabeza
(4, 31),  -- Rigidez en el cuello
(4, 3),   -- Confusión
(4, 32),  -- Sensibilidad a la luz
(4, 4),   -- Convulsiones

-- Enfermedades neumocócicas
(5, 18),  -- Fiebre
(5, 9),   -- Dolor de cabeza
(5, 31),  -- Rigidez en el cuello
(5, 3),   -- Confusión
(5, 32),  -- Sensibilidad a la luz
(5, 35),  -- Sepsis

-- Fiebre Amarilla
(6, 18),  -- Fiebre
(6, 21),  -- Ictericia
(6, 13),  -- Dolor muscular
(6, 22),  -- Náuseas
(6, 23),  -- Vómito
(6, 16),  -- Fatiga

-- Hepatitis A
(7, 18),  -- Fiebre
(7, 16),  -- Fatiga
(7, 7),   -- Dolor abdominal
(7, 24),  -- Orina oscura
(7, 21),  -- Ictericia
(7, 22),  -- Náuseas
(7, 23),  -- Vómito
(7, 31),  -- Poco apetito

-- Hepatitis B
(8, 18),  -- Fiebre
(8, 16),  -- Fatiga
(8, 7),   -- Dolor abdominal
(8, 24),  -- Orina oscura
(8, 21),  -- Ictericia
(8, 22),  -- Náuseas
(8, 23),  -- Vómito
(8, 31),  -- Poco apetito

-- Hib (Haemophilus influenzae tipo b)
(9, 18),  -- Fiebre
(9, 25),  -- Meningitis
(9, 26),  -- Neumonía
(9, 27),  -- Infección de la sangre

-- Influenza (Gripe)
(10, 18), -- Fiebre
(10, 16), -- Fatiga
(10, 13), -- Dolor muscular
(10, 9),  -- Dolor de cabeza
(10, 41), -- Tos

-- Meningitis
(11, 18), -- Fiebre
(11, 9),  -- Dolor de cabeza
(11, 31), -- Rigidez en el cuello
(11, 3),  -- Confusión
(11, 32), -- Sensibilidad a la luz
(11, 4),  -- Convulsiones

-- Neumonía
(12, 18), -- Fiebre
(12, 7),  -- Dificultad para respirar
(12, 41), -- Tos
(12, 11), -- Dolor en el pecho

-- Paperas
(13, 18), -- Fiebre
(13, 11), -- Dolor e hinchazón en las glándulas salivales
(13, 9),  -- Dolor de cabeza
(13, 16), -- Fatiga

-- Poliomelitis (Polio)
(14, 18), -- Fiebre
(14, 16), -- Fatiga
(14, 9),  -- Dolor de cabeza
(14, 31), -- Rigidez en el cuello
(14, 24), -- Parálisis

-- Rabia
(15, 18), -- Fiebre
(15, 9),  -- Dolor de cabeza
(15, 15), -- Espasmos
(15, 3),  -- Confusión
(15, 24), -- Parálisis

-- Rotavirus
(16, 6),  -- Diarrea grave
(16, 23), -- Vómito
(16, 18), -- Fiebre
(16, 7),  -- Dolor abdominal

-- Rubéola
(17, 18), -- Fiebre
(17, 12), -- Erupción cutánea característica
(17, 20), -- Ganglios inflamados

-- Sarampión
(18, 18), -- Fiebre
(18, 12), -- Erupción cutánea característica
(18, 41), -- Tos
(18, 34), -- Secreción nasal
(18, 3),  -- Conjuntivitis

-- Tétanos
(19, 33), -- Rigidez muscular
(19, 15), -- Espasmos
(19, 9),  -- Dolor de cabeza
(19, 7),  -- Dificultad para tragar

-- Tos ferina
(20, 39), -- Tos intensa y persistente
(20, 1),  -- Ataques de tos
(20, 7),  -- Dificultad para respirar

-- Tuberculosis
(21, 18), -- Fiebre
(21, 16), -- Fatiga
(21, 40), -- Tos persistente
(21, 7),  -- Dificultad para respirar
(21, 28), -- Pérdida de peso
(21, 6),  -- Escalofríos
(21, 36), -- Sudores nocturnos

-- Varicela
(22, 18), -- Fiebre
(22, 12), -- Erupción cutánea característica
(22, 31), -- Picazón
(22, 16), -- Fatiga

-- Virus del papiloma humano (VPH)
(23, 37), -- Verrugas genitales
(23, 1),  -- Cáncer de cuello uterino
(23, 24); -- Otros tipos de cáncer
GO
-- por defecto estos roles con permisos
INSERT INTO roles (nombre_rol, descripcion_rol)
VALUES ('Paciente', 'Usuario que recibe tratamiento y consulta información médica.'),
       ('Fabricante', 'Persona o empresa que produce o distribuye vacunas.'),
       ('Doctor', 'Profesional médico que diagnostica y trata a los pacientes.'),
       ('Enfermera', 'Especialista en cuidados y asistencia directa a pacientes.'),
       ('Administrativo', 'Responsable de la atención, gestión, planificación de la institución.'),
       ('Autoridad', 'Persona con poderes decisionales y supervisión en la institución.'),
       ('Developer', 'Administra y desarrolla aplicaciones, bases de datos y sistemas.')
GO
INSERT INTO permisos (nombre_permiso, descripcion_permiso)
VALUES ('PACIENTE_READ', 'Permite leer datos básicos de pacientes y sus referencias médicas.'),
       ('MED_READ', 'Permite leer datos médicos detallados de pacientes.'),
       ('MED_WRITE', 'Permite añadir o modificar datos médicos.'),
       ('USER_MANAGER_WRITE', 'Permite gestionar los usuarios, sin incluir restricciones a los mismos.'),
       ('USER_MANAGER_READ', 'Permite leer los datos de los usuarios.'),
       ('FABRICANTE_READ', 'Permite leer los datos generales del fabricante de vacunas.'),
       ('FABRICANTE_WRITE',
        'Permite gestionar datos relacionados a las vacunas ofrecidos y referencias médicas de las mismas.'),
       ('ADMINISTRATIVO_WRITE', 'Permite gestionar usuarios y configuraciones de enfermedades, síntomas y vacunas.'),
       ('AUTORIDAD_READ', 'Permite supervisar todos los datos.'),
       ('AUTORIDAD_WRITE', 'Permite modificar todos los datos sin restricciones de lógica del negocio o permisos.'),
       ('DEV_DB_ADMIN', 'Permite administrar, configurar y desarollar la base de datos.'),
       ('GUEST_READ', 'Permite leer datos generales de la base de datos. Información no sensitiva ni confidencial.')
GO
/*
Aclaraciones:
- Diferencia entre ADMINISTRATIVO_WRITE y MED_WRITE, radica en poder gestionar las categorías padre llamase Vacunas, sus enfermedades y síntomas.
  MED unicamente puede gestionar las dosis de las categorías ya creadas, dando la posibilidad de usar 'Por registrar' para el rol correspondiente corrija.
- Diferencia entre ADMINISTRATIVO_WRITE y USER_MANAGER_WRITE, ambos roles permiten modificar usuarios, pero administrativo puede deshabilitar un usuario y sus roles.
  Ninguno puede crear usuarios ya que es una facultad de las aplicaciones o sistemas que implementan automáticamente el hash de contraseñas y otorga roles ya definidos.
- Diferencia entre AUTORIDAD_WRITE y DEV_DB_ADMIN es directamente en crear datos sin restricciones, los dev pueden modificar la estructura más no los datos.
*/
INSERT INTO roles_permisos (id_rol, id_permiso)
VALUES (1, 1),  -- Paciente, PACIENTE_READ
       (2, 2),  -- Doctor, MED_READ
       (2, 3),  -- Doctor, MED_WRITE
       (2, 4),  -- Doctor, USER_MANAGER_WRITE
       (2, 5),  -- Doctor, USER_MANAGER_READ
       (3, 2),  -- Enfermera, MED_READ
       (3, 3),  -- Enfermera, MED_WRITE
       (4, 8),  -- Administrativo, ADMINISTRATIVO_WRITE
       (4, 5),  -- Administrativo, USER_MANAGER_READ
       (4, 12), -- Administrativo, GUEST_READ
       (5, 9),  -- Autoridad, AUTORIDAD_READ
       (5, 10), -- Autoridad, AUTORIDAD_WRITE
       (6, 11) -- Developer, DEV_DB_ADMIN
GO

-- datos de prueba. Las direcciones se insertan a medida que se requieren. Se recomienda utilizar los procedimientos para insertar ya que respeta la lógica y facilita insertar a varias tablas
INSERT INTO vacunas (nombre_vacuna, edad_minima_meses, intervalo_dosis_1_2_meses)
VALUES ('Vacuna por registrar', NULL, NULL),
       ('Adacel', 132, NULL),
       ('BCG', 0, NULL),
       ('COVID-19', 6, 0.92),
       ('Fiebre Amarilla', NULL, NULL),
       ('Hep A (Euvax) (adultos)', 240, 6),
       ('Hep A (Euvax) (infantil)', 12, NULL),
       ('Hep B (adultos)', 240, 6),
       ('Hep B (infantil)', 0, 1),
       ('Hexaxim', 2, NULL),
       ('Influenza (FluQuadri)', 6, 12),
       ('Meningococo', 132, 48),
       ('MMR', 12, NULL),
       ('MR (antisarampión, antirrubéola)', 12, 72),
       ('Neumoco conjugado (Prevenar 13 valente)', 2, NULL),
       ('Papiloma Humano (Gardasil)', 132, NULL),
       ('Pneumo23', 780, NULL),
       ('Pneumovax', 780, NULL),
       ('Priorix', 9, 3),
       ('Rotarix', 2, NULL),
       ('TD', 48, 120),
       ('Tetravalente', NULL, NULL), -- No se especifica la edad mínima y el intervalo es según el calendario infantil
       ('Varivax', 12, 69),
       ('Verorab', NULL, NULL); -- Según el esquema de post-exposición
GO

-- Vacuna por registrar
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Vacuna por registrar', NULL, 'Desconocida'
-- enfermedad desconocida y síntomas desconocidos
-- Adacel
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Adacel', NULL, 'Difteria'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Adacel', NULL, 'Tétanos'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Adacel', NULL, 'Tos ferina'

EXEC spVacunas_InsertVacunaEnfermedad NULL, 'BCG', NULL, 'Tuberculosis'

EXEC spVacunas_InsertVacunaEnfermedad NULL, 'COVID-19', NULL, 'COVID-19'

EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Fiebre Amarilla', NULL, 'Fiebre Amarilla'

EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Hep A (Euvax) (adultos)', NULL, 'Hepatitis A'

EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Hep A (Euvax) (infantil)', NULL, 'Hepatitis A'

EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Hep B (adultos)', NULL, 'Hepatitis B'

EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Hep B (infantil)', NULL, 'Hepatitis B'
-- Hexaxim
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Hexaxim', NULL, 'Difteria'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Hexaxim', NULL, 'Tétanos'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Hexaxim', NULL, 'Tos ferina'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Hexaxim', NULL, 'Hepatitis B'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Hexaxim', NULL, 'Poliomelitis (Polio)'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Hexaxim', NULL, 'Hib (Haemophilus influenzae tipo b)'

EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Influenza (FluQuadri)', NULL, 'Influenza (Gripe)'

EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Meningococo', NULL, 'Enfermedad meningocócica'
-- MMR
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'MMR', NULL, 'Sarampión'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'MMR', NULL, 'Paperas'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'MMR', NULL, 'Rubéola'
-- MR (antisarampión, antirrubéola)
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'MR (antisarampión, antirrubéola)', NULL, 'Sarampión'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'MR (antisarampión, antirrubéola)', NULL, 'Rubéola'
-- Neumoco conjugado (Prevenar 13 valente)
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Neumoco conjugado (Prevenar 13 valente)', NULL, 'Neumonía'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Neumoco conjugado (Prevenar 13 valente)', NULL, 'Meningitis'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Neumoco conjugado (Prevenar 13 valente)', NULL, 'Bacteriemia'

EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Papiloma Humano (Gardasil)', NULL, 'Virus del papiloma humano (VPH)'

EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Pneumo23', NULL, 'Enfermedades neumocócicas'

EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Pneumovax', NULL, 'Enfermedades neumocócicas'
-- Priorix
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Priorix', NULL, 'Sarampión'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Priorix', NULL, 'Rubéola'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Priorix', NULL, 'Paperas'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Rotarix', NULL, 'Rotavirus'
-- TD
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'TD', NULL, 'Tétanos'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'TD', NULL, 'Difteria'
-- Tetravalente
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Tetravalente', NULL, 'Difteria'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Tetravalente', NULL, 'Tétanos'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Tetravalente', NULL, 'Tos ferina'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Tetravalente', NULL, 'Poliomelitis (Polio)'

EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Varivax', NULL, 'Varicela'
EXEC spVacunas_InsertVacunaEnfermedad NULL, 'Verorab', NULL, 'Rabia'

-- Pacientes ficticios
EXEC dbo.spVacunas_GestionarPaciente '8-1006-14', 'Jorge', 'Ruiz', NULL, '1999-05-31', 'M', '507 6068-4595', NULL,
     'Samaria, sector 4, casa E1', 'San Miguelito';
GO
EXEC dbo.spVacunas_GestionarPaciente '1-54-9635', 'Luis', 'Mendoza', NULL, '2006-05-05', 'M', '507 6325-7865', NULL,
     'Finca 30, casa 45', 'Changuinola';
GO
EXEC dbo.spVacunas_GestionarPaciente '2-4558-5479', 'José', 'Perez', NULL, '1959-12-13', 'M', '507 6265-4789', NULL,
     'Vía Interamericana, casa L78', 'Natá';
GO
EXEC dbo.spVacunas_GestionarPaciente '5-554-321', 'Martha', 'Cornejo', NULL, '1979-08-24', 'F', '507 6784-1296', NULL,
     'Vía Interamericana, Metetí, casa 87F', 'Pinogana';
GO
EXEC dbo.spVacunas_GestionarPaciente '8-9754-1236', 'Suleimi', 'Rodriguez', NULL, '2001-02-17', 'F', '507 6785-9631',
     NULL, 'Calle 51, casa 74', 'Panamá';
GO
-- Sedes algunos datos no son veraces **
EXEC dbo.spVacunas_InsertSede 'Hospital San Miguel Arcangel', 'MINSA', NULL, '507 523-6906',
     'HISMA, Vía Ricardo J. Alfaro', 'San Miguelito';
GO
EXEC dbo.spVacunas_InsertSede 'MINSA CAPSI FINCA 30 CHANGINOLA', 'MINSA', NULL, '507 758-8096', 'Finca 32',
     'Changuinola';
GO
EXEC dbo.spVacunas_InsertSede 'Hospital Aquilino Tejeira', 'CSS', NULL, '507 997-9386', 'Calle Manuel H Robles',
     'Penonomé';
GO
EXEC dbo.spVacunas_InsertSede 'CENTRO DE SALUD METETI', 'MINSA', NULL, '507 299-6151', 'La Palma', 'Pinogana';
GO
EXEC dbo.spVacunas_InsertSede 'POLICENTRO DE SALUD de Chepo', 'MINSA', NULL, '507 296-7220',
     'Via Panamericana Las Margaritas', 'Chepo';
GO
EXEC dbo.spVacunas_InsertSede 'Clínica Hospital San Fernando', 'Privada', NULL, '507 305-6300',
     'Via España, Hospital San Fernando', 'Panamá';
GO
EXEC dbo.spVacunas_InsertSede 'Complejo Hospitalario Doctor Arnulfo Arias Madrid', 'CSS', NULL, '507 503-6032',
     'Avenida José de Fábrega, Complejo Hospitalario', 'Panamá';
GO
EXEC dbo.spVacunas_InsertSede 'Hospital Santo Tomás', 'MINSA', NULL, '507 507-5830', 'Avenida Balboa y Calle 37 Este',
     'Panamá';
GO
EXEC dbo.spVacunas_InsertSede 'Hospital Regional de Changuinola Raul Dávila Mena', 'MINSA', NULL, '507 758-8295',
     'Changuinola, Bocas del Toro', 'Changuinola';
GO
EXEC dbo.spVacunas_InsertSede 'Hospital Dr. Rafael Hernández', 'MINSA', NULL, '507 774-8400', 'David, Chiriquí',
     'David';
GO
EXEC dbo.spVacunas_InsertSede 'Hospital Punta Pacífica Pacífica Salud', 'Privada', NULL, '507 204-8000',
     'Punta Pacífica, Ciudad de Panamá', 'Panamá';
GO
EXEC dbo.spVacunas_InsertSede 'Hospital Nacional', 'Privada', NULL, '507 307-2102', 'Av. Cuba, Ciudad de Panamá',
     'Panamá';
GO
EXEC dbo.spVacunas_InsertSede 'Centro de salud Pacora', 'MINSA', NULL, '507 296-0005', 'Pacora, Ciudad de Panamá',
     'Panamá';
GO
EXEC dbo.spVacunas_InsertSede 'Hospital Dr. Nicolás A. Solano', 'MINSA', NULL, '507 254-8926',
     'La Chorrera, Panamá Oeste', 'La Chorrera';
GO
EXEC dbo.spVacunas_InsertSede 'Cómplejo Hospitalario Dr. Manuel Amador Guerrero', 'CSS', NULL, '507 475-2207',
     'Colón, Colón', 'Colón';
GO
EXEC dbo.spVacunas_InsertSede 'Policlínica Lic. Manuel María Valdés', 'CSS', NULL, '507 503-1500',
     'San Miguelito, Ciudad de Panamá', 'Panamá';
GO
EXEC dbo.spVacunas_InsertSede 'CSS Complejo Metropolitano', 'CSS', NULL, '507 506-4000', 'Vía España, Ciudad de Panamá',
     'Panamá';
GO
EXEC dbo.spVacunas_InsertSede 'Hospital de Especialidades Pediátricas Omar Torrijos Herrena', 'CSS', NULL,
     '507 513-7008', 'Vía España, Ciudad de Panamá', 'Panamá';
GO

INSERT INTO fabricantes (licencia, nombre_fabricante, telefono_fabricante, correo_fabricante, direccion_fabricante,
                         contacto_fabricante)
VALUES -- algunos datos no son veraces **
       ('08-001 LA/DNFD', 'Sanofi Pasteur', '1-800-822-2463', 'info@sanofipasteur.com',
        'Sanofi Pasteur Inc., 1 Discovery Drive, Swiftwater, PA 18370, USA', 'John Doe'),
       ('08-002 LA/DNFD', 'Pfizer', '1-212-733-2323', 'support@pfizer.com',
        'Pfizer Inc., 235 East 42nd Street, New York, NY 10017, USA', 'Alice Johnson'),
       ('08-003 LA/DNFD', 'GlaxoSmithKline', '44-20-8047-5000', 'info@gsk.com',
        'GSK plc, 980 Great West Road, Brentford, Middlesex, TW8 9GS, UK', 'Bob Brown'),
       ('08-004 LA/DNFD', 'Merck', '1-908-740-4000', 'contact@merck.com',
        'Merck & Co., Inc., 2000 Galloping Hill Road, Kenilworth, NJ 07033, USA', 'Jane Smith'),
       ('08-005 LA/DNFD', 'Serum Institute', '91-20-26993900', 'contact@seruminstitute.com',
        '212/2, Hadapsar, Off Soli Poonawalla Road, Pune 411028, Maharashtra, India', 'Mr. Muralidharan Poduval');
GO

-- insertar la relación fabricante vacuna usando el procedimiento almacenado
EXEC spVacunas_InsertFabricanteVacuna 1, NULL, NULL, 'Adacel';
EXEC spVacunas_InsertFabricanteVacuna 1, NULL, NULL, 'BCG';
EXEC spVacunas_InsertFabricanteVacuna 2, NULL, NULL, 'COVID-19';
EXEC spVacunas_InsertFabricanteVacuna 1, NULL, NULL, 'Fiebre Amarilla';
EXEC spVacunas_InsertFabricanteVacuna 3, NULL, NULL, 'Hep A (Euvax) (adultos)';
EXEC spVacunas_InsertFabricanteVacuna 3, NULL, NULL, 'Hep A (Euvax) (infantil)';
EXEC spVacunas_InsertFabricanteVacuna 4, NULL, NULL, 'Hep B (adultos)';
EXEC spVacunas_InsertFabricanteVacuna 4, NULL, NULL, 'Hep B (infantil)';
EXEC spVacunas_InsertFabricanteVacuna 1, NULL, NULL, 'Hexaxim';
EXEC spVacunas_InsertFabricanteVacuna 1, NULL, NULL, 'Influenza (FluQuadri)';
EXEC spVacunas_InsertFabricanteVacuna 3, NULL, NULL, 'Meningococo';
EXEC spVacunas_InsertFabricanteVacuna 4, NULL, NULL, 'MMR';
EXEC spVacunas_InsertFabricanteVacuna 5, NULL, NULL, 'MR (antisarampión, antirrubéola)';
EXEC spVacunas_InsertFabricanteVacuna 2, NULL, NULL, 'Neumoco conjugado (Prevenar 13 valente)';
EXEC spVacunas_InsertFabricanteVacuna 4, NULL, NULL, 'Papiloma Humano (Gardasil)';
EXEC spVacunas_InsertFabricanteVacuna 4, NULL, NULL, 'Pneumo23';
EXEC spVacunas_InsertFabricanteVacuna 4, NULL, NULL, 'Pneumovax';
EXEC spVacunas_InsertFabricanteVacuna 3, NULL, NULL, 'Priorix';
EXEC spVacunas_InsertFabricanteVacuna 3, NULL, NULL, 'Rotarix';
EXEC spVacunas_InsertFabricanteVacuna 1, NULL, NULL, 'TD';
EXEC spVacunas_InsertFabricanteVacuna 4, NULL, NULL, 'Tetravalente';
EXEC spVacunas_InsertFabricanteVacuna 4, NULL, NULL, 'Varivax';
EXEC spVacunas_InsertFabricanteVacuna 1, NULL, NULL, 'Verorab';

INSERT INTO almacenes (nombre_almacen, encargado, telefono_almacen, dependencia_almacen)
VALUES ('Almacen Vacúnate Panamá', 'Carlos Gonzalez', '507 275-9689', 'MINSA') -- ficticios
GO

-- Insertar el inventario en el almacén usando el procedimiento almacenado
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'Adacel', 160, '2025-12-15', 'LoteA1';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'BCG', 215, '2025-12-16', 'LoteA2';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'COVID-19', 140, '2025-12-17', 'LoteA3';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'Fiebre Amarilla', 325, '2025-12-18', 'LoteA4';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'Hep A (Euvax) (adultos)', 280, '2025-12-19', 'LoteA5';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'Hep A (Euvax) (infantil)', 215, '2025-12-20', 'LoteA6';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'Hep B (adultos)', 260, '2025-12-21', 'LoteA7';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'Hep B (infantil)', 235, '2025-12-22', 'LoteA8';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'Hexaxim', 190, '2025-12-23', 'LoteA9';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'Influenza (FluQuadri)', 185, '2025-12-24', 'LoteA10';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'Meningococo', 170, '2025-12-25', 'LoteA11';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'MMR', 235, '2025-12-26', 'LoteA12';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'MR (antisarampión, antirrubéola)', 230, '2025-12-27', 'LoteA13';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'Neumoco conjugado (Prevenar 13 valente)', 165, '2025-12-28',
     'LoteA14';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'Papiloma Humano (Gardasil)', 160, '2025-12-29', 'LoteA15';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'Pneumo23', 155, '2025-12-30', 'LoteA16';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'Pneumovax', 150, '2025-12-31', 'LoteA17';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'Priorix', 145, '2025-12-01', 'LoteA18';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'Rotarix', 140, '2025-12-02', 'LoteA19';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'TD', 135, '2025-12-03', 'LoteA20';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'Tetravalente', 130, '2025-12-04', 'LoteA21';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'Varivax', 125, '2025-12-05', 'LoteA22';
EXEC spVacunas_InsertAlmacenInventario 1, NULL, NULL, 'Verorab', 125, '2025-12-06', 'LoteA23';

-- Distribución de vacunas usando el procedimiento almacenado
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'Hospital San Miguel Arcangel', NULL, 'Adacel', 10, 'LoteA1';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'MINSA CAPSI FINCA 30 CHANGINOLA', NULL, 'BCG', 15, 'LoteA2';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'Hospital Aquilino Tejeira', NULL, 'COVID-19', 20, 'LoteA3';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'CENTRO DE SALUD METETI', NULL, 'Fiebre Amarilla', 25, 'LoteA4';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'POLICENTRO DE SALUD de Chepo', NULL, 'Hep A (Euvax) (adultos)', 30,
     'LoteA5';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'Clínica Hospital San Fernando', NULL, 'Hep A (Euvax) (infantil)',
     35, 'LoteA6';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'Complejo Hospitalario Doctor Arnulfo Arias Madrid', NULL,
     'Hep B (adultos)', 40, 'LoteA7';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'Hospital Santo Tomás', NULL, 'Hep B (infantil)', 45, 'LoteA8';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'Hospital Regional de Changuinola Raul Dávila Mena', NULL,
     'Hexaxim', 50, 'LoteA9';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'Hospital Dr. Rafael Hernández', NULL, 'Influenza (FluQuadri)', 55,
     'LoteA10';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'Hospital Punta Pacífica Pacífica Salud', NULL, 'Meningococo', 60,
     'LoteA11';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'Hospital Nacional', NULL, 'MMR', 65, 'LoteA12';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'Centro de salud Pacora', NULL, 'MR (antisarampión, antirrubéola)',
     70, 'LoteA13';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'Hospital Dr. Nicolás A. Solano', NULL,
     'Neumoco conjugado (Prevenar 13 valente)', 75, 'LoteA14';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'Cómplejo Hospitalario Dr. Manuel Amador Guerrero', NULL,
     'Papiloma Humano (Gardasil)', 80, 'LoteA15';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'Policlínica Lic. Manuel María Valdés', NULL, 'Pneumo23', 85,
     'LoteA16';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'CSS Complejo Metropolitano', NULL, 'Pneumovax', 90, 'LoteA17';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'Hospital de Especialidades Pediátricas Omar Torrijos Herrena',
     NULL, 'Priorix', 95, 'LoteA18';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'Hospital San Miguel Arcangel', NULL, 'Rotarix', 100, 'LoteA19';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'MINSA CAPSI FINCA 30 CHANGINOLA', NULL, 'TD', 105, 'LoteA20';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'Hospital Aquilino Tejeira', NULL, 'Tetravalente', 110, 'LoteA21';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'CENTRO DE SALUD METETI', NULL, 'Varivax', 115, 'LoteA22';
EXEC dbo.spVacunas_DistribuirVacunas 1, NULL, NULL, 'POLICENTRO DE SALUD de Chepo', NULL, 'Verorab', 120, 'LoteA23';

-- crear las dosis y relacionar con su paciente usando el procedimiento almacenado
EXEC dbo.spVacunas_InsertDosis '1-54-9635', '2023-04-03 07:00', '1', NULL, 'BCG', NULL,
     'MINSA CAPSI FINCA 30 CHANGINOLA', 'LoteA2';
EXEC dbo.spVacunas_InsertDosis '1-54-9635', '2024-07-04 10:00:00', '2', NULL, 'BCG', NULL,
     'MINSA CAPSI FINCA 30 CHANGINOLA', 'LoteA2';
EXEC dbo.spVacunas_InsertDosis '2-4558-5479', '2024-01-03 08:35', '1', NULL, 'Hep B (adultos)', NULL,
     'Complejo Hospitalario Doctor Arnulfo Arias Madrid', 'LoteA7';
EXEC dbo.spVacunas_InsertDosis '5-554-321', '2023-12-03 18:45', '1', NULL, 'Neumoco conjugado (Prevenar 13 valente)',
     NULL, 'Hospital Punta Pacífica Pacífica Salud', 'LoteA14';
EXEC dbo.spVacunas_InsertDosis '8-1006-14', '2023-11-03 09:30', '1', NULL, 'MMR', NULL, 'Hospital Santo Tomás',
     'LoteA12';
EXEC dbo.spVacunas_InsertDosis '8-9754-1236', '2022-10-03 16:00', '1', NULL, 'Priorix', NULL,
     'Cómplejo Hospitalario Dr. Manuel Amador Guerrero', 'LoteA18';
EXEC dbo.spVacunas_InsertDosis '8-9754-1236', '2023-11-30 07:00', '2', NULL, 'Priorix', NULL,
     N'Cómplejo Hospitalario Dr. Manuel Amador Guerrero', 'LoteA18';

USE master;