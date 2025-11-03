CREATE OR REPLACE TRIGGER MEDICITA_DB_USR.PacienteCitaDuplicada
BEFORE INSERT ON MEDICITA_DB_USR.CITA
FOR EACH ROW
DECLARE
    -- Variable para almacenar si ya existe una cita con los mismos datos
    v_existe_cita NUMBER;
    
    -- Excepción personalizada
    e_cita_duplicada EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_cita_duplicada, -20003);
    
BEGIN
    -- 1. Contar el número de citas que ya existen para este paciente en la misma FECHA y HORA
    SELECT COUNT(ID_CITA)
    INTO v_existe_cita
    FROM MEDICITA_DB_USR.CITA
    WHERE ID_PACIENTE = :NEW.ID_PACIENTE -- Mismo paciente
      AND FECHA = :NEW.FECHA             -- Misma fecha
      AND HORA = :NEW.HORA;              -- Misma hora

    -- 2. Validar el resultado de la cuenta
    IF v_existe_cita > 0 THEN
        -- Si ya existe una cita, se lanza un error y se detiene la inserción
        RAISE_APPLICATION_ERROR(-20003, 
            'Ya existe una cita agendada para el paciente [' || :NEW.ID_PACIENTE || '] en la fecha ' || TO_CHAR(:NEW.FECHA, 'DD-MON-YYYY') || ' y hora ' || TO_CHAR(:NEW.HORA, 'HH24:MI') || '.'
        );
    END IF;
END;
/

COMMIT;