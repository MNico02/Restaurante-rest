
-------------------------------------------------------

/* ============================================================
  RESET: eliminar tablas hijas -> padres (evita errores de FK)
  ============================================================*/
IF OBJECT_ID('dbo.reservas_sucursales','U') IS NOT NULL DROP TABLE dbo.reservas_sucursales;
IF OBJECT_ID('dbo.estilos_sucursales','U') IS NOT NULL DROP TABLE dbo.estilos_sucursales;
IF OBJECT_ID('dbo.especialidades_alimentarias_sucursales','U') IS NOT NULL DROP TABLE dbo.especialidades_alimentarias_sucursales;
IF OBJECT_ID('dbo.tipos_comidas_sucursales','U') IS NOT NULL DROP TABLE dbo.tipos_comidas_sucursales;
IF OBJECT_ID('dbo.zonas_turnos_sucursales','U') IS NOT NULL DROP TABLE dbo.zonas_turnos_sucursales;
IF OBJECT_ID('dbo.turnos_sucursales','U') IS NOT NULL DROP TABLE dbo.turnos_sucursales;
IF OBJECT_ID('dbo.zonas_sucursales','U') IS NOT NULL DROP TABLE dbo.zonas_sucursales;
IF OBJECT_ID('dbo.clicks_contenidos','U') IS NOT NULL DROP TABLE dbo.clicks_contenidos;

IF OBJECT_ID('dbo.contenidos','U') IS NOT NULL DROP TABLE dbo.contenidos;
IF OBJECT_ID('dbo.sucursales','U') IS NOT NULL DROP TABLE dbo.sucursales;

IF OBJECT_ID('dbo.categorias_precios','U') IS NOT NULL DROP TABLE dbo.categorias_precios;
IF OBJECT_ID('dbo.estilos','U') IS NOT NULL DROP TABLE dbo.estilos;
IF OBJECT_ID('dbo.especialidades_alimentarias','U') IS NOT NULL DROP TABLE dbo.especialidades_alimentarias;
IF OBJECT_ID('dbo.tipos_comidas','U') IS NOT NULL DROP TABLE dbo.tipos_comidas;
IF OBJECT_ID('dbo.zonas','U') IS NOT NULL DROP TABLE dbo.zonas;

IF OBJECT_ID('dbo.clientes','U') IS NOT NULL DROP TABLE dbo.clientes;
IF OBJECT_ID('dbo.restaurantes','U') IS NOT NULL DROP TABLE dbo.restaurantes;
IF OBJECT_ID('dbo.localidades','U') IS NOT NULL DROP TABLE dbo.localidades;
IF OBJECT_ID('dbo.provincias','U') IS NOT NULL DROP TABLE dbo.provincias;
GO

/* =======================
   DIMENSIONES / LOOKUPS
   =======================*/
CREATE TABLE dbo.provincias(
                               cod_provincia   INT          NOT NULL,
                               nom_provincia   NVARCHAR(80) NOT NULL,
                               CONSTRAINT PK_provincias PRIMARY KEY (cod_provincia),
                               CONSTRAINT AK_provincias_nom UNIQUE (nom_provincia)
);
GO

CREATE TABLE dbo.localidades(
                                nro_localidad   INT           NOT NULL,
                                nom_localidad   NVARCHAR(120) NOT NULL,
                                cod_provincia   INT           NOT NULL,
                                CONSTRAINT PK_localidades PRIMARY KEY (nro_localidad),
                                CONSTRAINT AK_localidades_prov_nom UNIQUE (cod_provincia, nom_localidad),
                                CONSTRAINT FK_localidades_provincias
                                    FOREIGN KEY (cod_provincia) REFERENCES dbo.provincias(cod_provincia)
);
GO

CREATE TABLE dbo.restaurantes(
                                 nro_restaurante INT           NOT NULL,
                                 razon_social    NVARCHAR(160) NOT NULL,
                                 cuit            VARCHAR(13)   NOT NULL,  -- admite con guiones
                                 CONSTRAINT PK_restaurantes PRIMARY KEY (nro_restaurante),
                                 CONSTRAINT AK_restaurantes_cuit UNIQUE (cuit)
);
GO

CREATE TABLE dbo.categorias_precios(
                                       nro_categoria INT NOT NULL,
                                       nom_categoria NVARCHAR(60) NOT NULL,
                                       CONSTRAINT PK_categorias_precios PRIMARY KEY (nro_categoria),
                                       CONSTRAINT AK_categorias_precios_nom UNIQUE (nom_categoria)
);
GO

CREATE TABLE dbo.zonas(
                          cod_zona   INT NOT NULL,
                          nom_zona   NVARCHAR(80) NOT NULL,
                          CONSTRAINT PK_zonas PRIMARY KEY (cod_zona),
                          CONSTRAINT AK_zonas_nom UNIQUE (nom_zona)
);
GO

CREATE TABLE dbo.tipos_comidas(
                                  nro_tipo_comida INT NOT NULL,
                                  nom_tipo_comida NVARCHAR(80) NOT NULL,
                                  CONSTRAINT PK_tipos_comidas PRIMARY KEY (nro_tipo_comida),
                                  CONSTRAINT AK_tipos_comidas_nom UNIQUE (nom_tipo_comida)
);
GO

CREATE TABLE dbo.especialidades_alimentarias(
                                                nro_restriccion INT NOT NULL,
                                                nom_restriccion NVARCHAR(80) NOT NULL,
                                                CONSTRAINT PK_especialidades_alimentarias PRIMARY KEY (nro_restriccion),
                                                CONSTRAINT AK_especialidades_alimentarias_nom UNIQUE (nom_restriccion)
);
GO

CREATE TABLE dbo.estilos(
                            nro_estilo INT NOT NULL,
                            nom_estilo NVARCHAR(80) NOT NULL,
                            CONSTRAINT PK_estilos PRIMARY KEY (nro_estilo),
                            CONSTRAINT AK_estilos_nom UNIQUE (nom_estilo)
);
GO

/* =======================
   OPERATIVO
   =======================*/
CREATE TABLE dbo.sucursales(
                               nro_restaurante           INT           NOT NULL,
                               nro_sucursal              INT           NOT NULL,
                               nom_sucursal              NVARCHAR(120) NOT NULL,
                               calle                     NVARCHAR(120) NOT NULL,
                               nro_calle                 NVARCHAR(10)  NOT NULL,
                               barrio                    NVARCHAR(120) NULL,
                               nro_localidad             INT           NOT NULL,
                               cod_postal                NVARCHAR(10)  NULL,
                               telefonos                 NVARCHAR(80)  NULL,
                               total_comensales          INT           NOT NULL,
                               min_tolerencia_reserva    INT           NOT NULL, -- minutos
                               nro_categoria             INT           NOT NULL,
                               CONSTRAINT PK_sucursales PRIMARY KEY (nro_restaurante, nro_sucursal),
                               CONSTRAINT AK_sucursales_nombre UNIQUE (nro_restaurante, nom_sucursal),
                               CONSTRAINT FK_sucursales_restaurantes
                                   FOREIGN KEY (nro_restaurante) REFERENCES dbo.restaurantes(nro_restaurante),
                               CONSTRAINT FK_sucursales_localidades
                                   FOREIGN KEY (nro_localidad) REFERENCES dbo.localidades(nro_localidad),
                               CONSTRAINT FK_sucursales_categorias_precios
                                   FOREIGN KEY (nro_categoria) REFERENCES dbo.categorias_precios(nro_categoria),
                               CONSTRAINT CK_sucursales_total_comensales CHECK (total_comensales >= 0),
                               CONSTRAINT CK_sucursales_tolerancia_min CHECK (min_tolerencia_reserva >= 0)
);
GO

CREATE TABLE dbo.zonas_sucursales(
                                     nro_restaurante INT NOT NULL,
                                     nro_sucursal    INT NOT NULL,
                                     cod_zona        INT NOT NULL,
                                     cant_comensales INT NOT NULL,
                                     permite_menores BIT NOT NULL CONSTRAINT DF_zs_perm_menores DEFAULT(1),
                                     habilitada      BIT NOT NULL CONSTRAINT DF_zs_habilitada DEFAULT(1),
                                     CONSTRAINT PK_zonas_sucursales PRIMARY KEY (nro_restaurante, nro_sucursal, cod_zona),
                                     CONSTRAINT FK_zs_sucursales
                                         FOREIGN KEY (nro_restaurante, nro_sucursal)
                                             REFERENCES dbo.sucursales(nro_restaurante, nro_sucursal),
                                     CONSTRAINT FK_zs_zonas
                                         FOREIGN KEY (cod_zona) REFERENCES dbo.zonas(cod_zona),
                                     CONSTRAINT CK_zs_cant_comensales CHECK (cant_comensales >= 0)
);
GO

CREATE TABLE dbo.turnos_sucursales(
                                      nro_restaurante INT      NOT NULL,
                                      nro_sucursal    INT      NOT NULL,
                                      hora_reserva    TIME(0)  NOT NULL,
                                      hora_hasta      TIME(0)  NOT NULL,
                                      habilitado      BIT      NOT NULL CONSTRAINT DF_ts_habilitado DEFAULT(1),
                                      CONSTRAINT PK_turnos_sucursales PRIMARY KEY (nro_restaurante, nro_sucursal, hora_reserva),
                                      CONSTRAINT FK_ts_sucursales
                                          FOREIGN KEY (nro_restaurante, nro_sucursal)
                                              REFERENCES dbo.sucursales(nro_restaurante, nro_sucursal),
                                      CONSTRAINT CK_ts_rango_horario CHECK (hora_hasta > hora_reserva)
);
GO

CREATE TABLE dbo.zonas_turnos_sucursales(
                                            nro_restaurante INT     NOT NULL,
                                            nro_sucursal    INT     NOT NULL,
                                            cod_zona        INT     NOT NULL,
                                            hora_reserva      TIME(0) NOT NULL,
                                            permite_menores BIT     NOT NULL CONSTRAINT DF_zts_perm_menores DEFAULT(1),
                                            CONSTRAINT PK_zonas_turnos_sucursales PRIMARY KEY (nro_restaurante, nro_sucursal, cod_zona, hora_reserva),
    -- FK a la zona de la sucursal
                                            CONSTRAINT FK_zts_zonas_sucursales
                                                FOREIGN KEY (nro_restaurante, nro_sucursal, cod_zona)
                                                    REFERENCES dbo.zonas_sucursales(nro_restaurante, nro_sucursal, cod_zona),
    -- FK al turno de la sucursal
                                            CONSTRAINT FK_zts_turnos_sucursales
                                                FOREIGN KEY (nro_restaurante, nro_sucursal,hora_reserva)
                                                    REFERENCES dbo.turnos_sucursales(nro_restaurante, nro_sucursal, hora_reserva)
);
GO

CREATE TABLE dbo.contenidos(
                               nro_restaurante     INT            NOT NULL,
                               nro_contenido       INT            NOT NULL,
                               contenido_a_publicar NVARCHAR(500) NOT NULL,
                               imagen_a_publicar   NVARCHAR(500)  NULL,
                               publicado           BIT            NOT NULL CONSTRAINT DF_cont_publicado DEFAULT(0),
                               costo_click         DECIMAL(12,2)  NULL,
                               nro_sucursal        INT            NULL, -- puede ser contenido general del restaurante
                               CONSTRAINT PK_contenidos PRIMARY KEY (nro_restaurante, nro_contenido),
                               CONSTRAINT FK_contenidos_restaurantes
                                   FOREIGN KEY (nro_restaurante) REFERENCES dbo.restaurantes(nro_restaurante),
                               CONSTRAINT FK_contenidos_sucursales
                                   FOREIGN KEY (nro_restaurante, nro_sucursal)
                                       REFERENCES dbo.sucursales(nro_restaurante, nro_sucursal)
);
GO

CREATE TABLE dbo.tipos_comidas_sucursales(
                                             nro_restaurante  INT NOT NULL,
                                             nro_sucursal     INT NOT NULL,
                                             nro_tipo_comida  INT NOT NULL,
                                             habilitado       BIT NOT NULL CONSTRAINT DF_tcs_habilitado DEFAULT(1),
                                             CONSTRAINT PK_tipos_comidas_sucursales PRIMARY KEY (nro_restaurante, nro_sucursal, nro_tipo_comida),
                                             CONSTRAINT FK_tcs_sucursales
                                                 FOREIGN KEY (nro_restaurante, nro_sucursal)
                                                     REFERENCES dbo.sucursales(nro_restaurante, nro_sucursal),
                                             CONSTRAINT FK_tcs_tipos_comidas
                                                 FOREIGN KEY (nro_tipo_comida) REFERENCES dbo.tipos_comidas(nro_tipo_comida)
);
GO

CREATE TABLE dbo.especialidades_alimentarias_sucursales(
                                                           nro_restaurante  INT NOT NULL,
                                                           nro_sucursal     INT NOT NULL,
                                                           nro_restriccion  INT NOT NULL,
                                                           habilitada       BIT NOT NULL CONSTRAINT DF_eas_habilitada DEFAULT(1),
                                                           CONSTRAINT PK_especialidades_alimentarias_sucursales PRIMARY KEY (nro_restaurante, nro_sucursal, nro_restriccion),
                                                           CONSTRAINT FK_eas_sucursales
                                                               FOREIGN KEY (nro_restaurante, nro_sucursal)
                                                                   REFERENCES dbo.sucursales(nro_restaurante, nro_sucursal),
                                                           CONSTRAINT FK_eas_especialidades
                                                               FOREIGN KEY (nro_restriccion) REFERENCES dbo.especialidades_alimentarias(nro_restriccion)
);
GO

CREATE TABLE dbo.estilos_sucursales(
                                       nro_restaurante INT NOT NULL,
                                       nro_sucursal    INT NOT NULL,
                                       nro_estilo      INT NOT NULL,
                                       habilitado      BIT NOT NULL CONSTRAINT DF_es_habilitado DEFAULT(1),
                                       CONSTRAINT PK_estilos_sucursales PRIMARY KEY (nro_restaurante, nro_sucursal, nro_estilo),
                                       CONSTRAINT FK_es_sucursales
                                           FOREIGN KEY (nro_restaurante, nro_sucursal)
                                               REFERENCES dbo.sucursales(nro_restaurante, nro_sucursal),
                                       CONSTRAINT FK_es_estilos
                                           FOREIGN KEY (nro_estilo) REFERENCES dbo.estilos(nro_estilo)
);
GO

CREATE TABLE dbo.clientes(
                             nro_cliente INT IDENTITY(1,1) NOT NULL,
                             apellido    NVARCHAR(80)  NOT NULL,
                             nombre      NVARCHAR(80)  NOT NULL,
                             correo      NVARCHAR(160) NOT NULL,
                             telefonos   NVARCHAR(80)  NULL,
                             CONSTRAINT PK_clientes PRIMARY KEY (nro_cliente),
                             CONSTRAINT AK_clientes_correo UNIQUE (correo)
);
GO

CREATE TABLE dbo.reservas_sucursales(
                                        cod_reserva      UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
                                        nro_cliente      INT      NOT NULL,
                                        fecha_reserva    DATE     NOT NULL,
                                        nro_restaurante  INT      NOT NULL,
                                        nro_sucursal     INT      NOT NULL,
                                        cod_zona         INT      NOT NULL,
                                        hora_reserva      TIME(0)  NOT NULL,
                                        cant_adultos     INT      NOT NULL,
                                        cant_menores     INT      NOT NULL,
                                        costo_reserva    DECIMAL(12,2) NOT NULL DEFAULT(0),
                                        cancelada        BIT      NOT NULL DEFAULT(0),
                                        fecha_cancelacion DATE    NULL,
                                        CONSTRAINT PK_reservas_sucursales PRIMARY KEY (cod_reserva),
                                        CONSTRAINT FK_rs_clientes
                                            FOREIGN KEY (nro_cliente) REFERENCES dbo.clientes(nro_cliente),
                                        CONSTRAINT FK_rs_sucursales
                                            FOREIGN KEY (nro_restaurante, nro_sucursal)
                                                REFERENCES dbo.sucursales(nro_restaurante, nro_sucursal),
    -- Asegura zona válida para esa sucursal
                                        CONSTRAINT FK_rs_zonas_sucursales
                                            FOREIGN KEY (nro_restaurante, nro_sucursal, cod_zona)
                                                REFERENCES dbo.zonas_sucursales(nro_restaurante, nro_sucursal, cod_zona),
    -- Asegura turno válido para esa sucursal
                                        CONSTRAINT FK_rs_turnos_sucursales
                                            FOREIGN KEY (nro_restaurante, nro_sucursal, hora_reserva)
                                                REFERENCES dbo.turnos_sucursales(nro_restaurante, nro_sucursal, hora_reserva),
                                        CONSTRAINT CK_rs_cantidades CHECK (cant_adultos >= 0 AND cant_menores >= 0 AND (cant_adultos + cant_menores) > 0),
                                        CONSTRAINT CK_rs_cancelacion
                                            CHECK ( (cancelada = 1 AND fecha_cancelacion IS NOT NULL) OR
                                                    (cancelada = 0 AND fecha_cancelacion IS NULL) )
);
GO

CREATE TABLE dbo.clicks_contenidos (
                                       nro_restaurante       INT           NOT NULL,
                                       nro_contenido         INT           NOT NULL,
                                       nro_click             INT           NOT NULL,
                                       fecha_hora_registro   DATETIME2(3)  NOT NULL
        CONSTRAINT DF_clicks_contenidos_fecha DEFAULT (SYSUTCDATETIME()),
                                       nro_cliente           INT           NULL,
                                       costo_click           DECIMAL(12,2) NOT NULL,
                                       CONSTRAINT PK_clicks_contenidos
                                           PRIMARY KEY (nro_restaurante, nro_contenido, nro_click),
                                       CONSTRAINT FK_clicks_contenidos_contenidos
                                           FOREIGN KEY (nro_restaurante, nro_contenido)
                                               REFERENCES dbo.contenidos (nro_restaurante, nro_contenido),
                                       CONSTRAINT FK_clicks_contenidos_clientes
                                           FOREIGN KEY (nro_cliente)
                                               REFERENCES dbo.clientes (nro_cliente),
                                       CONSTRAINT CK_clicks_contenidos_costo_nonneg
                                           CHECK (costo_click >= 0)
);
GO

CREATE OR ALTER TRIGGER TR_zonas_sucursales_validar_capacidad
ON dbo.zonas_sucursales
AFTER INSERT, UPDATE
                                  AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM (
            SELECT i.nro_restaurante, i.nro_sucursal
            FROM inserted i
            UNION
            SELECT d.nro_restaurante, d.nro_sucursal
            FROM deleted d
        ) AS afectados
        JOIN dbo.sucursales s
          ON s.nro_restaurante = afectados.nro_restaurante
         AND s.nro_sucursal    = afectados.nro_sucursal
        CROSS APPLY (
            SELECT SUM(zs.cant_comensales) AS suma_zonas
            FROM dbo.zonas_sucursales zs
            WHERE zs.nro_restaurante = afectados.nro_restaurante
              AND zs.nro_sucursal    = afectados.nro_sucursal
        ) x
        WHERE x.suma_zonas > s.total_comensales
    )
BEGIN
ROLLBACK;
THROW 51001, 'La suma de cant_comensales supera el total_comensales definido en sucursales.', 1;
END
END;
GO
---------------------------------------------------------

---         INSERTS

/* =======================
   Provincias y Localidades
   =======================*/


INSERT INTO dbo.provincias (cod_provincia, nom_provincia)
VALUES (1,N'Córdoba'), (2,N'Santa Fe'), (3,N'Buenos Aires');

INSERT INTO dbo.localidades (nro_localidad, nom_localidad, cod_provincia) VALUES
                                                                              (1,N'Córdoba Capital', 1),
                                                                              (2,N'Villa María', 1),
                                                                              (3,N'Río Cuarto', 1);

INSERT INTO dbo.localidades (nro_localidad,nom_localidad, cod_provincia)
VALUES (4,N'Santa Fe Capital', 2),
       (5,N'Rosario', 2);


INSERT INTO dbo.localidades (nro_localidad,nom_localidad, cod_provincia)
VALUES (6,N'La Plata', 3),
       (7,N'Mar del Plata', 3);

/* =======================
   Categorías de precios
   =======================*/
INSERT INTO dbo.categorias_precios (nro_categoria, nom_categoria) VALUES
                                                                      (1, N'Baja'), (2, N'Media'), (3, N'Alta');

/* =======================
   Zonas disponibles
   =======================*/
INSERT INTO dbo.zonas (cod_zona, nom_zona) VALUES
                                               (1, N'Saln'), (2, N'Terraza'), (3, N'Patio');

/* =======================
   Tipos de comidas
   =======================*/
INSERT INTO dbo.tipos_comidas (nro_tipo_comida, nom_tipo_comida) VALUES
    (1, N'Italiana tradicional');

/* =======================
   Especialidades alimentarias
   =======================*/
INSERT INTO dbo.especialidades_alimentarias (nro_restriccion, nom_restriccion) VALUES
                                                                                   (1, N'Vegetariano'), (2, N'Celíaco');

/* =======================
   Estilos
   =======================*/
INSERT INTO dbo.estilos (nro_estilo, nom_estilo) VALUES
                                                     (1, N'Casual'), (2, N'Familiar');


/* =======================
   Restaurante principal
   =======================*/
INSERT INTO dbo.restaurantes (nro_restaurante, razon_social, cuit) VALUES
    (1, N'El millonario', N'30-91245678-9');

/* =======================
   Sucursales (4 en total)
   =======================*/
INSERT INTO dbo.sucursales
(nro_restaurante, nro_sucursal, nom_sucursal, calle, nro_calle, barrio, nro_localidad, cod_postal, telefonos,
 total_comensales, min_tolerencia_reserva, nro_categoria)
VALUES
    (1, 1,N'Casa Central El millonario',  N'Av. Siempreviva', 742, N'Centro',   1, N'5000', N'351-5551001', 60, 15, 2),
    (1, 2,N'Sucursal norte El millonario',    N'25 de Mayo',    742,  N'General Paz',    2, N'5000', N'351-5551002', 80, 10, 3)



    INSERT INTO dbo.zonas_sucursales
(nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
VALUES
    (1,1,1,40,1,1), (1,1,2,20,1,1);


INSERT INTO dbo.zonas_sucursales
(nro_restaurante, nro_sucursal, cod_zona, cant_comensales, permite_menores, habilitada)
VALUES
    (1,2,1,50,1,1), (1,2,2,30,1,1);



INSERT INTO dbo.turnos_sucursales
(nro_restaurante, nro_sucursal, hora_reserva, hora_hasta, habilitado)
VALUES
-- ALMUERZO (1h30)
(1,1,'12:00:00','13:30:00',1),
(1,1,'13:30:00','15:00:00',1),
(1,2,'12:00:00','13:30:00',1),
(1,2,'13:30:00','15:00:00',1),

-- CENA (hasta cierre)
(1,1,'20:00:00','22:00:00',1),
(1,1,'22:00:00','23:59:00',1),

(1,2,'20:00:00','22:00:00',1),
(1,2,'22:00:00','23:59:00',1);




select * from turnos_sucursales


/* Todas las sucursales sirven Italiana tradicional */
    INSERT INTO dbo.tipos_comidas_sucursales (nro_restaurante, nro_sucursal, nro_tipo_comida, habilitado)
VALUES (1,1,1,1),(1,2,1,1);

/* Todas las sucursales con estilos Casual y Familiar */
INSERT INTO dbo.estilos_sucursales (nro_restaurante, nro_sucursal, nro_estilo, habilitado)
VALUES
    (1,1,1,1),(1,1,2,1),
    (1,2,1,1),(1,2,2,1);

/* Especialidades alimentarias (solo vegetariano y celíaco habilitados) */
INSERT INTO dbo.especialidades_alimentarias_sucursales (nro_restaurante, nro_sucursal, nro_restriccion, habilitada)
VALUES
    (1,1,1,1),(1,1,2,1),
    (1,2,1,1),(1,2,2,1);


INSERT INTO dbo.zonas_turnos_sucursales
(nro_restaurante, nro_sucursal, cod_zona, hora_reserva, permite_menores)
VALUES
-- Sucursal 1
(1,1,1,'12:00:00',1),(1,1,1,'13:30:00',1),
(1,1,1,'20:00:00',1),(1,1,1,'22:00:00',1),

(1,1,2,'12:00:00',1),(1,1,2,'13:30:00',1),
(1,1,2,'20:00:00',1),(1,1,2,'22:00:00',1),

-- Sucursal 2
(1,2,1,'12:00:00',1),(1,2,1,'13:30:00',1),
(1,2,1,'20:00:00',1),(1,2,1,'22:00:00',1),

(1,2,2,'12:00:00',1),(1,2,2,'13:30:00',1),
(1,2,2,'20:00:00',1),(1,2,2,'22:00:00',1);

go
---------------------------------------------------------------
----Procedimientos


CREATE OR ALTER PROCEDURE dbo.ins_cliente_reserva_sucursal
    -- Cliente (si @nro_cliente es NULL, se inserta usando correo como clave natural)
    @nro_cliente        INT              = NULL,
    @apellido           NVARCHAR(80)     = NULL,
    @nombre             NVARCHAR(80)     = NULL,
    @correo             NVARCHAR(160)    = NULL,
    @telefonos          NVARCHAR(80)     = NULL,

    -- Reserva
    @cod_reserva        UNIQUEIDENTIFIER = NULL,  -- se ignora: la tabla tiene DEFAULT NEWSEQUENTIALID()
    @fecha_reserva      DATE,
    @hora_reserva       TIME(0),
    @nro_restaurante    INT,
    @nro_sucursal       INT,
    @cod_zona           INT,
    @cant_adultos       INT,
    @cant_menores       INT,
    @costo_reserva      DECIMAL(12,2)    = 0,
    @cancelada          BIT              = 0,
    @fecha_cancelacion  DATE             = NULL,

    -- salida
    @o_cod_reserva      UNIQUEIDENTIFIER OUTPUT
    AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

BEGIN TRY
BEGIN TRAN;

        DECLARE @cliente_id INT;

        /* 1) Resolver cliente */
        IF @nro_cliente IS NOT NULL
BEGIN
            SET @cliente_id = @nro_cliente;
END
ELSE
BEGIN
            -- Reusar por correo si ya existe
SELECT @cliente_id = c.nro_cliente
FROM dbo.clientes c
WHERE c.correo = @correo;

IF @cliente_id IS NULL
BEGIN
INSERT INTO dbo.clientes (apellido, nombre, correo, telefonos)
VALUES (@apellido, @nombre, @correo, @telefonos);

SET @cliente_id = SCOPE_IDENTITY();
END
END



        /* 3) Insertar reserva y capturar cod_reserva */
       /* 3) Insertar reserva y capturar cod_reserva */
        DECLARE @t TABLE (cod_reserva UNIQUEIDENTIFIER);

INSERT INTO dbo.reservas_sucursales
(nro_cliente, fecha_reserva, hora_reserva,
 nro_restaurante, nro_sucursal, cod_zona,
 cant_adultos, cant_menores, costo_reserva,
 cancelada, fecha_cancelacion)
    OUTPUT inserted.cod_reserva INTO @t
VALUES
    (@cliente_id, @fecha_reserva, @hora_reserva,
    @nro_restaurante, @nro_sucursal, @cod_zona,
    @cant_adultos, @cant_menores, @costo_reserva,
    @cancelada, @fecha_cancelacion);

COMMIT;

/* 4) Devolver por ResultSet (para leer con #result-set-1) */
SELECT cod_reserva = (SELECT TOP 1 cod_reserva FROM @t);
END TRY
BEGIN CATCH
IF XACT_STATE() <> 0 ROLLBACK;
        -- Mensaje amigable si choca UNIQUE de correo
        IF ERROR_NUMBER() IN (2627,2601) AND CHARINDEX('AK_clientes_correo', ERROR_MESSAGE()) > 0
            THROW 51030, 'El correo de cliente ya existe.', 1;

        THROW; -- re-lanzar el error original
END CATCH
END
GO


SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.get_horarios_disponibles
    @nro_restaurante INT,
    @nro_sucursal    INT,
    @cod_zona        INT,
    @fecha           DATE,
    @cant_personas   INT,
    @menores         BIT
    AS
BEGIN
    SET NOCOUNT ON;

    IF @cant_personas <= 0
BEGIN
        RAISERROR('La cantidad de personas debe ser mayor a 0.', 16, 1);
        RETURN;
END

    -- Verificar que la zona exista y está habilitada para la sucursal
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.zonas_sucursales zs
        WHERE zs.nro_restaurante = @nro_restaurante
          AND zs.nro_sucursal    = @nro_sucursal
          AND zs.cod_zona        = @cod_zona
          AND zs.habilitada      = 1
    )
BEGIN
        -- Devuelve vacío
SELECT CAST(NULL AS TIME(0)) AS hora_reserva,
       CAST(NULL AS TIME(0)) AS hora_hasta,
       NULL AS capacidad_total,
       NULL AS ocupados,
       NULL AS cupo_disponible
    WHERE 1 = 0;
RETURN;
END

    ;WITH Turnos AS (
    /* Turnos válidos para la sucursal y que además estén asociados a la zona */
    SELECT t.nro_restaurante, t.nro_sucursal, t.hora_reserva, t.hora_hasta
    FROM dbo.turnos_sucursales t
             INNER JOIN dbo.zonas_turnos_sucursales zts
                        ON zts.nro_restaurante = t.nro_restaurante
                            AND zts.nro_sucursal    = t.nro_sucursal
                            AND zts.hora_reserva    = t.hora_reserva
                            AND zts.cod_zona        = @cod_zona
    WHERE t.nro_restaurante = @nro_restaurante
      AND t.nro_sucursal    = @nro_sucursal
      AND t.habilitado      = 1
),
          Zona AS (
              SELECT zs.cant_comensales, zs.permite_menores, zs.habilitada
              FROM dbo.zonas_sucursales zs
              WHERE zs.nro_restaurante = @nro_restaurante
                AND zs.nro_sucursal    = @nro_sucursal
                AND zs.cod_zona        = @cod_zona
          ),
          Ocupacion AS (
              SELECT
                  r.hora_reserva,
                  ocupados = SUM(ISNULL(r.cant_adultos,0) + ISNULL(r.cant_menores,0))
              FROM dbo.reservas_sucursales r
              WHERE r.nro_restaurante = @nro_restaurante
                AND r.nro_sucursal    = @nro_sucursal
                AND r.cod_zona        = @cod_zona
                AND r.fecha_reserva   = @fecha
                AND ISNULL(r.cancelada,0) = 0
              GROUP BY r.hora_reserva
          )

     SELECT
         t.hora_reserva,
         t.hora_hasta
     FROM Turnos t
              CROSS JOIN Zona z
              LEFT JOIN Ocupacion o
                        ON o.hora_reserva = t.hora_reserva
     WHERE
       -- Cupo suficiente
         (z.cant_comensales - ISNULL(o.ocupados,0)) >= @cant_personas
       -- Si hay menores en la solicitud, la zona debe permitir menores
       AND ( @menores = 0 OR z.permite_menores = 1 )
     ORDER BY t.hora_reserva;
END
GO


CREATE OR ALTER PROCEDURE dbo.get_info_restaurante_rs
    @nro_restaurante INT
    AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.restaurantes WHERE nro_restaurante = @nro_restaurante)
BEGIN
        RAISERROR('El restaurante especificado no existe.', 16, 1);
        RETURN;
END;

    /* 1) Restaurante */
SELECT
    r.nro_restaurante,
    r.razon_social,
    r.cuit
FROM dbo.restaurantes r
WHERE r.nro_restaurante = @nro_restaurante;

/* 2) Sucursales */
SELECT
    s.nro_restaurante,
    s.nro_sucursal,
    s.nom_sucursal,
    s.calle,
    s.nro_calle,
    s.barrio,
    s.nro_localidad,
    l.nom_localidad,
    p.cod_provincia,
    p.nom_provincia,
    s.cod_postal,
    s.telefonos,
    s.total_comensales,
    s.min_tolerencia_reserva,
    s.nro_categoria,
    cp.nom_categoria AS categoria_precio
FROM dbo.sucursales s
         INNER JOIN dbo.localidades l ON l.nro_localidad = s.nro_localidad
         INNER JOIN dbo.provincias p  ON p.cod_provincia = l.cod_provincia
         INNER JOIN dbo.categorias_precios cp ON cp.nro_categoria = s.nro_categoria
WHERE s.nro_restaurante = @nro_restaurante
ORDER BY s.nro_sucursal;

/* 3) Zonas por sucursal */
SELECT
    zs.nro_restaurante,
    zs.nro_sucursal,
    zs.cod_zona,
    z.nom_zona,
    zs.cant_comensales,
    zs.permite_menores,
    zs.habilitada
FROM dbo.zonas_sucursales zs
         INNER JOIN dbo.zonas z ON z.cod_zona = zs.cod_zona
WHERE zs.nro_restaurante = @nro_restaurante
ORDER BY zs.nro_sucursal, zs.cod_zona;

/* 4) Turnos por sucursal */
SELECT
    t.nro_restaurante,
    t.nro_sucursal,
    t.hora_reserva,
    t.hora_hasta,
    t.habilitado
FROM dbo.turnos_sucursales t
WHERE t.nro_restaurante = @nro_restaurante
ORDER BY t.nro_sucursal, t.hora_reserva;

/* 5) Zonas-Turnos por sucursal */
SELECT
    zts.nro_restaurante,
    zts.nro_sucursal,
    zts.cod_zona,
    zts.hora_reserva,
    zts.permite_menores
FROM dbo.zonas_turnos_sucursales zts
WHERE zts.nro_restaurante = @nro_restaurante
ORDER BY zts.nro_sucursal, zts.cod_zona, zts.hora_reserva;

/* 6) Estilos por sucursal */
SELECT
    es.nro_restaurante,
    es.nro_sucursal,
    es.nro_estilo,
    e.nom_estilo,
    es.habilitado
FROM dbo.estilos_sucursales es
         INNER JOIN dbo.estilos e ON e.nro_estilo = es.nro_estilo
WHERE es.nro_restaurante = @nro_restaurante
ORDER BY es.nro_sucursal, es.nro_estilo;

/* 7) Especialidades alimentarias por sucursal */
SELECT
    eas.nro_restaurante,
    eas.nro_sucursal,
    eas.nro_restriccion,
    ea.nom_restriccion,
    eas.habilitada
FROM dbo.especialidades_alimentarias_sucursales eas
         INNER JOIN dbo.especialidades_alimentarias ea ON ea.nro_restriccion = eas.nro_restriccion
WHERE eas.nro_restaurante = @nro_restaurante
ORDER BY eas.nro_sucursal, eas.nro_restriccion;

/* 8) Tipos de comidas por sucursal */
SELECT
    tcs.nro_restaurante,
    tcs.nro_sucursal,
    tcs.nro_tipo_comida,
    tc.nom_tipo_comida,
    tcs.habilitado
FROM dbo.tipos_comidas_sucursales tcs
         INNER JOIN dbo.tipos_comidas tc ON tc.nro_tipo_comida = tcs.nro_tipo_comida
WHERE tcs.nro_restaurante = @nro_restaurante
ORDER BY tcs.nro_sucursal, tcs.nro_tipo_comida;

END;
GO



        CREATE OR ALTER PROCEDURE dbo.sp_clicks_contenidos_insertar
    @nro_restaurante      INT,
    @nro_contenido        INT,
    @correo_cliente       NVARCHAR(160) = NULL,   -- nuevo parámetro
    @fecha_hora_registro  DATETIME2     = NULL    -- opcional; default = ahora
    AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ahora DATETIME2 = ISNULL(@fecha_hora_registro, SYSUTCDATETIME());
    DECLARE @costo DECIMAL(12,2);
    DECLARE @nro_click INT;
    DECLARE @nro_cliente_resuelto INT = NULL;

    -- 0) Resolver nro_cliente a partir del correo (si viene)
    IF @correo_cliente IS NOT NULL
BEGIN
SELECT @nro_cliente_resuelto = c.nro_cliente
FROM dbo.clientes c
WHERE c.correo = @correo_cliente;
-- si no existe, queda NULL (correcto)
END

    -- Aislar para evitar nro_click duplicados en concurrencia
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRAN;

        -- 1) Obtener costo desde contenidos (y validar existencia)
SELECT @costo = c.costo_click
FROM dbo.contenidos AS c WITH (UPDLOCK, HOLDLOCK)
WHERE c.nro_restaurante = @nro_restaurante
  AND c.nro_contenido   = @nro_contenido;

IF @costo IS NULL
BEGIN
ROLLBACK;
THROW 50010, 'No existe contenido para ese restaurante/contenido o costo_click NULL.', 1;
END

        -- 2) Calcular siguiente nro_click incremental por (restaurante, contenido)
SELECT @nro_click = ISNULL(MAX(cc.nro_click), 0) + 1
FROM dbo.clicks_contenidos AS cc WITH (UPDLOCK, HOLDLOCK)
WHERE cc.nro_restaurante = @nro_restaurante
  AND cc.nro_contenido   = @nro_contenido;

-- 3) Insertar el click
INSERT INTO dbo.clicks_contenidos
(nro_restaurante, nro_contenido, nro_click, fecha_hora_registro, nro_cliente, costo_click)
VALUES
    (@nro_restaurante, @nro_contenido, @nro_click, @ahora, @nro_cliente_resuelto, @costo);

COMMIT;

-- 4) Devolver el registro insertado
SELECT
    @nro_restaurante        AS nro_restaurante,
    @nro_contenido          AS nro_contenido,
    @nro_click              AS nro_click,
    @ahora                  AS fecha_hora_registro,
    @nro_cliente_resuelto   AS nro_cliente,
    @correo_cliente         AS correo_cliente,
    @costo                  AS costo_click;
END;
GO



/* ============================================
   CONTENIDOS PROMOCIONALES — RESTAURANTE 1
   ============================================*/

-- ===========================
-- Sucursal 1 (Tradicional, Medio, Arg + Ita, Sin gluten)
-- ===========================
INSERT INTO dbo.contenidos
(nro_restaurante, nro_contenido, contenido_a_publicar, imagen_a_publicar, publicado, costo_click, nro_sucursal) VALUES
(1, 1,
 N'Menú Tradicional "Abuela" (Sin gluten): empanadas de carne al horno con tapa de maíz + sorrentinos de ricota y nuez en salsa fileto. Precio medio. Ideal para compartir.',
 N'https://media.elgourmet.com/recetas/cover/d886d9d83cdfbbb1e1e7aa1d395d796c_3_3_photo.png', 0, 0.10, 1);

INSERT INTO dbo.contenidos
(nro_restaurante, nro_contenido, contenido_a_publicar, imagen_a_publicar, publicado, costo_click, nro_sucursal) VALUES
    (1, 2,
     N'Combo Argentino & Italiano (Sin gluten): milanesa napolitana con papas al horno + penne rigate al pesto. Estilo tradicional, porciones generosas, precio medio.',
     N'https://airescriollos.com.ar/wp-content/uploads/2020/11/Milanesa-de-Pollo-Napolitana.jpg', 0, 0.10, 1);

INSERT INTO dbo.contenidos
(nro_restaurante, nro_contenido, contenido_a_publicar, imagen_a_publicar, publicado, costo_click, nro_sucursal) VALUES
    (1, 3,
     N'Noche de Pastas Caseras (opción Sin gluten): tallarines amasados a la vista con bolognesa o tuco de cocción lenta + copa de vino de la casa. Ambiente tradicional.',
     N'https://cdn.recetasderechupete.com/wp-content/uploads/2020/11/Tallarines-rojos-con-pollo.jpg', 0, 0.10, 1);


-- ===========================
-- Sucursal 2 (Casual, Alto/Premium, Mexicana, Vegetariana)
-- ===========================
INSERT INTO dbo.contenidos
(nro_restaurante, nro_contenido, contenido_a_publicar, imagen_a_publicar, publicado, costo_click, nro_sucursal) VALUES
    (1, 4,
     N'Tacos Degustación Premium (Vegetarianos): set de 6 tacos (hongos asados, calabaza especiada, frijoles y queso), salsas caseras y guacamole. Estilo casual, experiencia gourmet.',
     N'https://lastaquerias.com/wp-content/uploads/2022/11/tacos-pastor-gaacc26fa8_1920.jpg', 0, 0.10, 2);

INSERT INTO dbo.contenidos
(nro_restaurante, nro_contenido, contenido_a_publicar, imagen_a_publicar, publicado, costo_click, nro_sucursal) VALUES
    (1, 5,
     N'Burrito Bowl Verde (Vegetariano): arroz cilantro-lima, mix de hojas, porotos negros, fajitas de verduras, pico de gallo y crema ácida. Presentación premium, servicio casual.',
     N'https://www.melonsinjamon.com/wp-content/uploads/2022/07/burrito-bowl-vegano.jpg', 0, 0.10, 2);

INSERT INTO dbo.contenidos
(nro_restaurante, nro_contenido, contenido_a_publicar, imagen_a_publicar, publicado, costo_click, nro_sucursal) VALUES
    (1, 6,
     N'Cena Mexicana Premium: enchiladas rojas vegetarianas + maridaje con tequila/agua fresca. Estilo casual chic, producto de alta calidad, ideal para celebración.',
     N'https://solnatural.bio/views/img/recipesphotos/97.jpg',0, 0.10, 2);
go


go
	 CREATE OR ALTER PROCEDURE dbo.get_contenidos
    @nro_restaurante INT
    AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

BEGIN TRY
BEGIN TRAN;

        -- 1) Obtener contenidos no publicados /
SELECT
    c.nro_restaurante,
    c.nro_contenido,
    c.contenido_a_publicar,
    c.imagen_a_publicar,
    c.publicado,
    c.costo_click,
    c.nro_sucursal
FROM dbo.contenidos c
WHERE c.nro_restaurante = @nro_restaurante
  AND c.publicado = 0;

-- 2) Marcar como publicados
UPDATE dbo.contenidos
SET publicado = 1
WHERE nro_restaurante = @nro_restaurante
  AND publicado = 0;

COMMIT;
END TRY
BEGIN CATCH
IF XACT_STATE() <> 0
            ROLLBACK;

        THROW;
END CATCH
END;
GO

--para el procesamiento batch
select * from dbo.contenidos
update dbo.contenidos
set publicado=0