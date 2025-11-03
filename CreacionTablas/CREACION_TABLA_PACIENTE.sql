-- *******************************************
--  Creación de Tabla PACIENTE 
-- *******************************************
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE PACIENTE CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            NULL;
        END IF;
END;
/

CREATE TABLE MEDICITA_DB_USR.PACIENTE (
    ID_PACIENTE         NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
    NOMBRES             VARCHAR2(60),
    APELLIDO_PATERNO    VARCHAR2(20),
    APELLIDO_MATERNO    VARCHAR2(20),
    DOC_IDENTIDAD       VARCHAR2(20)    NOT NULL
                        CONSTRAINT UQ_PACIENTE_DOC_IDENTIDAD UNIQUE,
    FEC_NACIMIENTO      DATE,
    SEXO                NUMBER,
    DIRECCION           VARCHAR2(40),
    TELEFONO            NUMBER(9),
    CORREO              VARCHAR2(50)
                        CONSTRAINT UQ_PACIENTE_CORREO UNIQUE,
    ID_GRUPO_SANGUINEO  NUMBER          NOT NULL
                        CONSTRAINT FK_PACIENTE_GRUPO_SANGUINEO REFERENCES GRUPO_SANGUINEO (ID_GRUPO_SANGUINEO) ON DELETE CASCADE,
    ID_DISTRITO         NUMBER          NOT NULL
                        CONSTRAINT FK_PACIENTE_DISTRITO REFERENCES DISTRITO (ID_DISTRITO) ON DELETE CASCADE,
    REG_CREACION        TIMESTAMP(2)    DEFAULT SYSTIMESTAMP NOT NULL,
    REG_MODIFICACION    TIMESTAMP(2)    DEFAULT SYSTIMESTAMP NOT NULL
);

ALTER TABLE MEDICITA_DB_USR.PACIENTE
ADD CONSTRAINT CHK_PACIENTE_CORREO_VALIDO CHECK (
    -- La expresión regular (^.+@.+\..+$) comprueba un patrón básico de email: 
    -- 1. Empieza con al menos un caracter.
    -- 2. Contiene un @.
    -- 3. Contiene al menos un caracter entre el @ y el punto.
    -- 4. Contiene un punto literal (\. para escapar el punto).
    -- 5. Contiene al menos un caracter después del punto.
    REGEXP_LIKE(CORREO, '^.+@.+\..+$') 
    OR CORREO IS NULL -- Permite valores NULL si la columna no es NOT NULL
);

COMMIT;