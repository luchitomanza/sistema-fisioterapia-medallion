CREATE OR REPLACE VIEW gold.pacientes_analitica
WITH (security_invoker = true) AS
SELECT
    p.*,
    CASE
        WHEN edad < 30 THEN '18-29'
        WHEN edad < 45 THEN '30-44'
        WHEN edad < 60 THEN '45-59'
        ELSE '60+'
    END AS grupo_edad,
    CASE
        WHEN imc < 25 THEN 'Normal'
        WHEN imc < 30 THEN 'Sobrepeso'
        ELSE 'Obesidad'
    END AS categoria_imc,
    CASE
        WHEN asistencia_sesiones_pct >= 85 THEN 'Alta'
        WHEN asistencia_sesiones_pct >= 70 THEN 'Media'
        ELSE 'Baja'
    END AS nivel_adherencia,
    CASE WHEN kinesiofobia_tsk > 37 THEN 'Alta' ELSE 'Baja' END AS nivel_kinesiofobia,
    CASE WHEN resultado_tratamiento = 1 THEN 'Recuperado' ELSE 'No recuperado' END AS resultado_texto,
    EXTRACT(YEAR FROM fecha_evaluacion)::INT AS anio
FROM silver.pacientes p;
CREATE OR REPLACE VIEW gold.ml_features
WITH (security_invoker = true) AS
SELECT
    id_paciente,
    edad,
    imc,
    CASE genero WHEN 'Femenino' THEN 1 ELSE 0 END AS genero_femenino,
    CASE ocupacion_demanda
        WHEN 'Sedentaria' THEN 0 WHEN 'Ligera' THEN 1
        WHEN 'Moderada' THEN 2 WHEN 'Pesada' THEN 3 END AS ocupacion_ord,
    CASE cronicidad
        WHEN 'Agudo' THEN 0 WHEN 'Subagudo' THEN 1 WHEN 'Cronico' THEN 2 END AS cronicidad_ord,
    CASE actividad_fisica_previa
        WHEN 'Nula' THEN 0 WHEN 'Ocasional' THEN 1 WHEN 'Regular' THEN 2 END AS actividad_ord,
    (tipo_lesion = 'Muscular')::INT       AS lesion_muscular,
    (tipo_lesion = 'Articular')::INT      AS lesion_articular,
    (tipo_lesion = 'Tendinosa')::INT      AS lesion_tendinosa,
    (tipo_lesion = 'Postquirurgica')::INT AS lesion_postquirurgica,
    (tipo_lesion = 'Neurologica')::INT    AS lesion_neurologica,
    dolor_inicial_eva,
    cirugias_previas,
    comorbilidades_num,
    rom_inicial_pct,
    fuerza_inicial_daniels,
    kinesiofobia_tsk,
    catastrofismo_pcs,
    asistencia_sesiones_pct,
    cumplimiento_ejercicios_casa,
    num_sesiones_totales,
    resultado_tratamiento AS target
FROM silver.pacientes;

SELECT count(*) AS filas_gold FROM gold.ml_features;