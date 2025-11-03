CREATE OR REPLACE TRIGGER MEDICITA_DB_USR.MedicoNoDisponible
BEFORE INSERT ON MEDICITA_DB_USR.CITA
FOR EACH ROW
DECLARE
    -- Variables para almacenar la información del horario y el cupo
    v_id_horario            NUMBER;
    v_cupo_maximo           NUMBER;
    v_citas_agendadas       NUMBER;
    
    -- Variables para determinar la disponibilidad según la fecha de la cita
    v_dia_semana_cita       NUMBER;
    v_hora_inicio_dispo     TIMESTAMP;
    v_hora_fin_dispo        TIMESTAMP;
    
    -- Excepciones personalizadas
    e_horario_no_encontrado EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_horario_no_encontrado, -20001);
    
    e_cupo_lleno            EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_cupo_lleno, -20002);

BEGIN
    -- 1. Determinar el día de la semana (1=Domingo, 2=Lunes, ... 7=Sábado) de la nueva cita
    -- Esto es necesario para enlazar con la tabla DISPONIBILIDAD.
    v_dia_semana_cita := TO_NUMBER(TO_CHAR(:NEW.FECHA, 'D'));
    
    -- 2. Buscar el HORARIO y su CUPO_MAXIMO que corresponde al médico, fecha y hora de la cita.
    BEGIN
        SELECT 
            H.ID_HORARIO,
            H.CUPO_MAXIMO,
            D.HORA_INICIO,
            D.HORA_FIN
        INTO 
            v_id_horario, 
            v_cupo_maximo,
            v_hora_inicio_dispo,
            v_hora_fin_dispo
        FROM 
            MEDICITA_DB_USR.DISPONIBILIDAD D
        JOIN 
            MEDICITA_DB_USR.HORARIO H ON D.ID_DISPONIBILIDAD = H.ID_DISPONIBILIDAD
        WHERE 
            D.ID_MEDICO = :NEW.ID_MEDICO                                  -- Coincide el Médico
            AND D.DIA_SEMANA = v_dia_semana_cita                          -- Coincide el día de la semana
            AND H.FECHA = :NEW.FECHA                                      -- Coincide la fecha específica
            -- Validar que la HORA de la CITA caiga dentro del rango de HORA_INICIO y HORA_FIN
            AND CAST(:NEW.HORA AS DATE) >= CAST(v_hora_inicio_dispo AS DATE) 
            AND CAST(:NEW.HORA AS DATE) < CAST(v_hora_fin_dispo AS DATE)  -- La hora debe ser menor a la hora de fin.
            AND ROWNUM = 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Si no se encuentra una combinación de Horario/Disponibilidad, el médico no está disponible.
            RAISE_APPLICATION_ERROR(-20001, 'El médico no tiene disponibilidad configurada para la fecha y hora solicitadas.');
    END;

    -- 3. Contar el número de citas ya agendadas para el ID_HORARIO encontrado
    SELECT 
        COUNT(*)
    INTO 
        v_citas_agendadas
    FROM 
        MEDICITA_DB_USR.CITA C
    JOIN
        MEDICITA_DB_USR.HORARIO H ON C.ID_MEDICO = :NEW.ID_MEDICO
    WHERE 
        C.ID_MEDICO = :NEW.ID_MEDICO
        AND C.FECHA = :NEW.FECHA
        -- Se añade una condición adicional para contar solo las citas que caen en el mismo ID_HORARIO
        -- Sin embargo, como CITA no tiene ID_HORARIO, se debe recrear la lógica de la subconsulta
        -- La forma más simple, dada la estructura, es contar citas con el mismo MEDICO y FECHA,
        -- pero solo si están en un estado que "ocupe" el cupo. (Asumiremos que todas ocupan cupo)
        -- Si hubiera una columna ID_HORARIO en CITA, la consulta sería más simple.
        
        -- Si asumimos que todas las citas a la misma FECHA, para el mismo MEDICO,
        -- y que caen en el rango de HORARIO encontrado, son válidas:
        AND C.ID_CITA != NVL(:NEW.ID_CITA, -1); -- Evitar contar la propia fila si fuera UPDATE, aunque es un INSERT

    -- 4. Validar si la nueva cita excede el cupo máximo
    IF v_citas_agendadas >= v_cupo_maximo THEN
        -- Si el número actual de citas iguala o supera el cupo máximo, se lanza un error.
        RAISE_APPLICATION_ERROR(-20002, 
            'El cupo de horario para el médico en la fecha ' || TO_CHAR(:NEW.FECHA, 'DD-MON-YYYY') || ' está lleno. Cupo Máximo: ' || v_cupo_maximo
        );
    END IF;

END;
/

COMMIT;