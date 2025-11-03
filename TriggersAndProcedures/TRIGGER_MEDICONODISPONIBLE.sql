CREATE OR REPLACE TRIGGER MEDICITA_DB_USR.MEDICONODISPONIBLE
BEFORE INSERT ON MEDICITA_DB_USR.CITA
FOR EACH ROW
DECLARE
    v_id_horario            NUMBER;
    v_cupo_maximo           NUMBER;
    v_citas_agendadas       NUMBER;
    v_dia_semana_cita       NUMBER;
    v_hora_inicio_horario   TIMESTAMP;
    v_hora_fin_horario      TIMESTAMP;
BEGIN
    -- 1. Determinar el día de la semana (1=Domingo, 2=Lunes, etc.) de la cita
    v_dia_semana_cita := TO_NUMBER(TO_CHAR(:NEW.FECHA, 'D'));
    
    -- 2. Intentar encontrar el ID_HORARIO correspondiente a la fecha/hora solicitada.
    -- La lógica compleja requiere unir CITA, DISPONIBILIDAD y HORARIO.
    BEGIN
        SELECT 
            H.ID_HORARIO,
            H.CUPO_MAXIMO,
            D.HORA_INICIO,
            D.HORA_FIN
        INTO 
            v_id_horario, 
            v_cupo_maximo,
            v_hora_inicio_horario,
            v_hora_fin_horario
        FROM 
            MEDICITA_DB_USR.DISPONIBILIDAD D
        JOIN 
            MEDICITA_DB_USR.HORARIO H ON D.ID_DISPONIBILIDAD = H.ID_DISPONIBILIDAD
        WHERE 
            D.ID_MEDICO = :NEW.ID_MEDICO 
            AND D.DIA_SEMANA = v_dia_semana_cita -- Coincide el día de la semana
            AND H.FECHA = :NEW.FECHA             -- Coincide la fecha
            -- Asegurarse que la HORA de la CITA caiga dentro del rango HORA_INICIO y HORA_FIN
            -- Se asume que HORA en CITA debe ser comparada con los campos TIMESTAMP de DISPONIBILIDAD.
            AND CAST(:NEW.HORA AS DATE) BETWEEN CAST(v_hora_inicio_horario AS DATE) AND CAST(v_hora_fin_horario AS DATE)
            AND ROWNUM = 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Si no se encuentra un horario que coincida con la FECHA, HORA y DIA,
            -- el médico no está disponible en ese momento.
            RAISE_APPLICATION_ERROR(-20001, 'El médico no tiene un horario de disponibilidad configurado para la fecha y hora solicitadas.');
            RETURN; -- Detiene la ejecución del trigger
    END;

    -- 3. Si se encontró un horario, contar las citas agendadas para ese ID_HORARIO en esa fecha.
    -- Nota: Al usar ID_HORARIO, ya estamos filtrando por día (H.FECHA) y médico (D.ID_MEDICO).
    SELECT 
        COUNT(*)
    INTO 
        v_citas_agendadas
    FROM 
        MEDICITA_DB_USR.CITA C
    JOIN
        MEDICITA_DB_USR.HORARIO H_JOIN ON C.ID_HORARIO = H_JOIN.ID_HORARIO
    WHERE 
        C.ID_MEDICO = :NEW.ID_MEDICO
        AND H_JOIN.FECHA = :NEW.FECHA
        -- Excluir la cita que se está insertando (no aplica para BEFORE INSERT, pero buena práctica)
        AND C.ID_CITA != NVL(:NEW.ID_CITA, -1); 
        
    -- 4. Validar si la nueva cita excede el cupo máximo
    IF v_citas_agendadas >= v_cupo_maximo THEN
        -- Si el número actual de citas es igual o mayor al cupo máximo, se lanza un error.
        RAISE_APPLICATION_ERROR(-20002, 
            'El cupo del horario de citas para el médico en la fecha ' || TO_CHAR(:NEW.FECHA, 'DD-MON-YYYY') || ' está lleno. Cupo Máximo: ' || v_cupo_maximo
        );
    END IF;

END;
/

COMMIT;