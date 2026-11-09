CREATE TABLE IF NOT EXISTS silver.pacientes (
    id_paciente                  TEXT PRIMARY KEY,
    fecha_evaluacion             DATE NOT NULL,
    edad                         SMALLINT CHECK (edad BETWEEN 0 AND 120),
    genero                       TEXT,
    imc                          NUMERIC(4,1) CHECK (imc BETWEEN 10 AND 70),
    ocupacion_demanda            TEXT,
    tipo_lesion                  TEXT,
    cronicidad                   TEXT,
    dolor_inicial_eva            SMALLINT CHECK (dolor_inicial_eva BETWEEN 0 AND 10),
    cirugias_previas             SMALLINT CHECK (cirugias_previas >= 0),
    comorbilidades_num           SMALLINT CHECK (comorbilidades_num >= 0),
    rom_inicial_pct              SMALLINT CHECK (rom_inicial_pct BETWEEN 0 AND 100),
    fuerza_inicial_daniels       SMALLINT CHECK (fuerza_inicial_daniels BETWEEN 0 AND 5),
    kinesiofobia_tsk             SMALLINT CHECK (kinesiofobia_tsk BETWEEN 17 AND 68),
    catastrofismo_pcs            SMALLINT CHECK (catastrofismo_pcs BETWEEN 0 AND 52),
    actividad_fisica_previa      TEXT,
    asistencia_sesiones_pct      SMALLINT CHECK (asistencia_sesiones_pct BETWEEN 0 AND 100),
    cumplimiento_ejercicios_casa SMALLINT CHECK (cumplimiento_ejercicios_casa BETWEEN 1 AND 5),
    num_sesiones_totales         SMALLINT CHECK (num_sesiones_totales > 0),
    resultado_tratamiento        SMALLINT CHECK (resultado_tratamiento IN (0, 1)),
    _fecha_procesado             TIMESTAMPTZ DEFAULT now()
);
TRUNCATE silver.pacientes;

INSERT INTO silver.pacientes (
    id_paciente, fecha_evaluacion, edad, genero, imc, ocupacion_demanda,
    tipo_lesion, cronicidad, dolor_inicial_eva, cirugias_previas,
    comorbilidades_num, rom_inicial_pct, fuerza_inicial_daniels,
    kinesiofobia_tsk, catastrofismo_pcs, actividad_fisica_previa,
    asistencia_sesiones_pct, cumplimiento_ejercicios_casa,
    num_sesiones_totales, resultado_tratamiento
)
SELECT DISTINCT ON (TRIM(id_paciente))
    UPPER(TRIM(id_paciente)),
    TRIM(fecha_evaluacion)::DATE,
    TRIM(edad)::SMALLINT,
    INITCAP(TRIM(genero)),
    REPLACE(TRIM(imc), ',', '.')::NUMERIC(4,1),
    INITCAP(TRIM(ocupacion_demanda)),
    INITCAP(TRIM(tipo_lesion)),
    INITCAP(TRIM(cronicidad)),
    TRIM(dolor_inicial_eva)::SMALLINT,
    TRIM(cirugias_previas)::SMALLINT,
    TRIM(comorbilidades_num)::SMALLINT,
    TRIM(rom_inicial_pct)::SMALLINT,
    TRIM(fuerza_inicial_daniels)::SMALLINT,
    TRIM(kinesiofobia_tsk)::SMALLINT,
    TRIM(catastrofismo_pcs)::SMALLINT,
    INITCAP(TRIM(actividad_fisica_previa)),
    TRIM(asistencia_sesiones_pct)::SMALLINT,
    TRIM(cumplimiento_ejercicios_casa)::SMALLINT,
    TRIM(num_sesiones_totales)::SMALLINT,
    TRIM(resultado_tratamiento)::SMALLINT
FROM bronze.pacientes_raw
WHERE id_paciente IS NOT NULL
ORDER BY TRIM(id_paciente), _fecha_carga DESC;

SELECT count(*) AS filas_silver FROM silver.pacientes;