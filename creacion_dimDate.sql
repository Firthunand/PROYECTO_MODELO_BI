--backup 29 feb 
--se logro cambiar columnas del eng al esp 
--se eliminan columnas innecesarias
--SE CALCULA LOS FERIADOS DE SEMANA SANTA PARA TODOS LOS AÑOS CON LA FORMULA DE GAUSS PARA SABER EL DOMINGO DE RESURRECCION
--Potentially quirky when it comes to week numbers.

BEGIN TRANSACTION;

DROP TABLE IF EXISTS numbers_small;
CREATE TABLE numbers_small (
  number SMALLINT NOT NULL
) DISTSTYLE ALL SORTKEY (number
);
INSERT INTO numbers_small VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);

DROP TABLE IF EXISTS numbers;
CREATE TABLE numbers (
  number BIGINT NOT NULL
) DISTSTYLE ALL SORTKEY (number
);
INSERT INTO numbers
  SELECT thousands.number * 1000 + hundreds.number * 100 + tens.number * 10 + ones.number
  FROM numbers_small thousands, numbers_small hundreds, numbers_small tens, numbers_small ones
  LIMIT 1000000;

DROP TABLE IF EXISTS "public"."dim_date" CASCADE;
CREATE TABLE "public"."dim_date" (
  "tk"                          INT4,
  "fecha"                        DATE,
  "día_de_la_semana"                 FLOAT8,
  "nombre_del_día_de_la_semana"            VARCHAR(10),
  "día_del_mes"                INT4,
  "día_del_anio"                 INT4,
  "semana"                        INT4,
  "semana_iso"                    INT4,
  "fecha_termino_de_semana"               TIMESTAMP NULL,
  "fecha_inicio_de_semana"             TIMESTAMP NULL,
  "mes"                       INT4,
  "nombre_del_mes"                  VARCHAR(10),
  "fecha_termino_del_mes"              TIMESTAMP NULL,
  "fecha_inicio_del_mes"            TIMESTAMP NULL,
  "trimestre"                     INT4,
  "nombre_del_trimestre"                VARCHAR(2),
  "semestre"                   INT4,
  "nombre_del_semestre"              VARCHAR(2),
  "anio"                        INT4,
  "fecha_termino_del_anio"               TIMESTAMP NULL,
  "fecha_inicio_del_anio"             TIMESTAMP NULL,
  "es_día_laboral"                  boolean,
  "es_fin_de_semana"                  boolean,
  "mas_7"                      DATE,
  "mas_14"                     DATE,
  "mas_21"                     DATE,
  "mas_28"                     DATE,
  "mas_35"                     DATE,
  "mas_42"                     DATE,
  "mas_49"                     DATE,
  "mas_56"                     DATE,
  "mas_63"                     DATE,
  "mas_70"                     DATE,
  "mas_77"                     DATE,
  "mas_84"                     DATE,
  "mas_91"                     DATE,
  "menos_7"                     DATE,
  "menos_14"                    DATE,
  "menos_21"                    DATE,
  "menos_28"                    DATE,
  "menos_35"                    DATE,
  "menos_42"                    DATE,
  "menos_49"                    DATE,
  "menos_56"                    DATE,
  "menos_63"                    DATE,
  "menos_70"                    DATE,
  "menos_77"                    DATE,
  "menos_84"                    DATE,
  "menos_91"                    DATE,
  "rango_del_dia_en_mes"         INT4,
  "rango_del_dia_en_mes_inverso" INT4,
  "identificador_festivo"       VARCHAR(50),
  "es_día_hábil"             boolean,  --37 + plus + minus
  "campaña_de_marketing"  VARCHAR(50),
  "tipo_de_campaña"       VARCHAR(50),
  "fecha_termino_campaña" DATE,
  "evento_especial"   VARCHAR(50)
) DISTSTYLE ALL SORTKEY (fecha);

INSERT INTO "public".dim_date
(TK
  , "fecha"
  , día_de_la_semana
  , nombre_del_día_de_la_semana
  , día_del_mes
  , día_del_anio
  , semana
  , semana_iso
  , fecha_termino_de_semana
  , fecha_inicio_de_semana
  , "mes"
  , nombre_del_mes
  , fecha_termino_del_mes
  , fecha_inicio_del_mes
  , trimestre
  , nombre_del_trimestre
  , semestre
  , nombre_del_semestre
  , "anio"
  , fecha_termino_del_anio
  , fecha_inicio_del_anio
  , es_día_laboral
  , es_fin_de_semana  --23
)
----------------------------------------------
----------------------------------------------
-----------------------------------------------
  SELECT
    bas.TK,
    bas.date,
    bas.day_of_week,

    CASE bas.day_of_week
    WHEN 1
      THEN 'Domingo'
    WHEN 2
      THEN 'Lunes'
    WHEN 3
      THEN 'Martes'
    WHEN 4
      THEN 'Miercoles'
    WHEN 5
      THEN 'Jueves'
    WHEN 6
      THEN 'Viernes'
    WHEN 7
      THEN 'Sabado'
    END                                                                         AS day_of_week_name,

    -------------------------------------------
    -------------------------------------------
    -------------------------------------------
    
    bas.day_of_month,
    ---------------------------------------
    ---------------------------------------
    ---------------------------------------
    bas.day_of_year,

    ----------------------------------------------------
    ----------------------------------------------------
    ----------------------------------------------------

    cast(to_char(bas.date,'WW') as int) as week,
    cast(to_char(bas.date,'IW') as int) as iso_week,

    -------------------------------------------------------
    -------------------------------------------------------
    -------------------------------------------------------

    ---------------------------------------------------------------
    ---------------------------------------------------------------
    ---------------------------------------------------------------

    DATEADD(day, 7 - (CONVERT(INT, bas.day_of_week)), bas.date)                 AS week_end_date,
    date_trunc('week', bas.date)                                                AS Week_start_date,

    bas.month,

    CASE bas.month
    WHEN 1
      THEN 'Enero'
    WHEN 2
      THEN 'Febrero'
    WHEN 3
      THEN 'Marzo'
    WHEN 4
      THEN 'Abril'
    WHEN 5
      THEN 'Mayo'
    WHEN 6
      THEN 'Junio'
    WHEN 7
      THEN 'Julio'
    WHEN 8
      THEN 'Agosto'
    WHEN 9
      THEN 'Septiembre'
    WHEN 10
      THEN 'Octubre'
    WHEN 11
      THEN 'Noviembre'
    WHEN 12
      THEN 'Diciembre'
    END                                                               AS month_name,
    last_day(bas.date)                                                AS month_end_date,
    date_trunc('month', bas.date)                                     AS month_start_date,

    bas.quarter,

    'Q' + CONVERT(VARCHAR(1), bas.quarter)                            AS quarter_name,

    bas.half_year,

    'S' + CONVERT(VARCHAR(1), bas.half_year)                          AS half_year_name,

    bas.year,
    
    DATEADD(day, -1, DATEADD(year, +1, date_trunc('year', bas.date))) AS year_end_date,
    date_trunc('year', bas.date)                                      AS year_start_date,

    bas.is_weekday,
    bas.is_weekend

  FROM (
        SELECT
            CONVERT(INT, TO_CHAR(DATEADD(day, num.number, '2013-01-01'), 'YYYYMMDD')) AS tk,
            CAST(DATEADD(day, num.number, '2013-01-01') AS DATE)                      AS "date",
            DATE_PART(dow, DATEADD(day, num.number, '2013-01-01')) + 1                AS day_of_week,
            DATEPART(day, DATEADD(day, num.number, '2013-01-01'))                     AS day_of_month,
            DATEPART(doy, DATEADD(day, num.number, '2013-01-01'))                     AS day_of_year,
            DATEPART(week, DATEADD(day, num.number, '2013-01-01'))                    AS week,
            DATEPART(month, DATEADD(day, num.number, '2013-01-01'))                   AS "month",
            DATEPART(quarter, DATEADD(day, num.number, '2013-01-01'))                 AS quarter,
            CASE WHEN DATEPART(qtr, DATEADD(day, num.number, '2013-01-01')) < 3
                THEN 1
            ELSE 2 END                                                                AS half_year,
            DATEPART(year, DATEADD(day, num.number, '2013-01-01'))                    AS "year",
            CASE WHEN DATEPART(dow, DATEADD(day, num.number, '2013-01-01')) IN (0, 6)
                THEN 0
            ELSE 1 END                                                                AS is_weekday,
            CASE WHEN DATEPART(dow, DATEADD(day, num.number, '2013-01-01')) IN (0, 6)
                THEN 1
            ELSE 0 END                                                                AS is_weekend
        FROM (
                SELECT *
                FROM numbers num
                LIMIT 10000  --en esta linea asignamos la cantidad de dias que se tomaran en cuenta desde el año de inicio que en este caso es 2013-01-01
            ) num 
    ) bas;

UPDATE dim_date
SET 
  mas_7 = DATEADD(day, 7, "fecha"),
  mas_14  = DATEADD(day, 14, "fecha"),
  mas_21  = DATEADD(day, 21, "fecha"),
  mas_28  = DATEADD(day, 28, "fecha"),
  mas_35  = DATEADD(day, 35, "fecha"),
  mas_42  = DATEADD(day, 42, "fecha"),
  mas_49  = DATEADD(day, 49, "fecha"),
  mas_56  = DATEADD(day, 56, "fecha"),
  mas_63  = DATEADD(day, 63, "fecha"),
  mas_70  = DATEADD(day, 70, "fecha"),
  mas_77  = DATEADD(day, 71, "fecha"),
  mas_84  = DATEADD(day, 84, "fecha"),
  mas_91  = DATEADD(day, 91, "fecha"),
  menos_7  = DATEADD(day, -7, "fecha"),
  menos_14 = DATEADD(day, -14, "fecha"),
  menos_21 = DATEADD(day, -21, "fecha"),
  menos_28 = DATEADD(day, -28, "fecha"),
  menos_35 = DATEADD(day, -35, "fecha"),
  menos_42 = DATEADD(day, -42, "fecha"),
  menos_49 = DATEADD(day, -49, "fecha"),
  menos_56 = DATEADD(day, -56, "fecha"),
  menos_63 = DATEADD(day, -63, "fecha"),
  menos_70 = DATEADD(day, -70, "fecha"),
  menos_77 = DATEADD(day, -71, "fecha"),
  menos_84 = DATEADD(day, -84, "fecha"),
  menos_91 = DATEADD(day, -91, "fecha")
WHERE "fecha" < '3499-12-31';

DROP TABLE IF EXISTS tt_month_rank;
CREATE TEMP TABLE tt_month_rank AS
  SELECT
    dim_date.fecha,
    ROW_NUMBER()
    OVER (
      PARTITION BY anio, mes, nombre_del_día_de_la_semana
      ORDER BY fecha )      AS month_day_name_rank,
    ROW_NUMBER()
    OVER (
      PARTITION BY anio, mes, nombre_del_día_de_la_semana
      ORDER BY fecha DESC ) AS month_day_name_reverse_rank
  FROM dim_date;

UPDATE dim_date
SET
  rango_del_dia_en_mes           = tt_month_rank.month_day_name_rank
  , rango_del_dia_en_mes_inverso = tt_month_rank.month_day_name_reverse_rank
FROM tt_month_rank
WHERE tt_month_rank.fecha = dim_date.fecha;

UPDATE dim_date
SET "identificador_festivo" =
CASE
--CASOS DE FERIADOS INVARIABLES
  WHEN nombre_del_mes = 'Mayo' AND día_del_mes = 1 THEN 'Día del Trabajo'
  WHEN nombre_del_mes = 'Enero'  AND día_del_mes = 1 THEN 'Año Nuevo'
  WHEN nombre_del_mes = 'Mayo' AND día_del_mes = 21 THEN 'Día de las Glorias Navales'
  WHEN nombre_del_mes = 'Junio' AND día_del_mes = 7 THEN 'Día de la Batalla de Arica (Arica y Paranicota)'
  WHEN nombre_del_mes = 'Junio' AND día_del_mes = 20 THEN 'Día Nacional de los Pueblos Indígenas'
  WHEN nombre_del_mes = 'Junio' AND día_del_mes = 29 THEN 'San Pedro y San Pablo'
  WHEN nombre_del_mes = 'Julio' AND día_del_mes = 16 THEN 'Día de la Virgen del Carmen'
  WHEN nombre_del_mes = 'Agosto' AND día_del_mes = 15 THEN 'Asunción de la Virgen'
  WHEN nombre_del_mes = 'Agosto' AND día_del_mes = 20 THEN 'Natalicio de Bernardo O’Higgins'
  WHEN nombre_del_mes = 'Septiembre' AND día_del_mes = 18 THEN 'Día de la Independencia Nacional'
  WHEN nombre_del_mes = 'Septiembre' AND día_del_mes = 19 THEN 'Día de las Glorias del Ejército'
  WHEN nombre_del_mes = 'Septiembre' AND día_del_mes = 20 THEN 'Viernes de las Fiestas Patrias (feriado adicional)'
  WHEN nombre_del_mes = 'Octubre' AND día_del_mes = 12 THEN 'Día del Encuentro de dos Mundos'
  WHEN nombre_del_mes = 'Octubre' AND día_del_mes = 31 THEN 'Día de las Iglesias Evangélicas y Protestantes'
  WHEN nombre_del_mes = 'Noviembre' AND día_del_mes = 1 THEN 'Día de Todos los Santos'
  WHEN nombre_del_mes = 'Diciembre' AND día_del_mes = 8 THEN 'Día de la Inmaculada Concepción'
  WHEN nombre_del_mes = 'Diciembre' AND día_del_mes = 25 THEN 'Día de Navidad'

  --CONDICIONES PARA FESTIVOS VARIABLES Y OCACIONALES
  --semana santa se utilizo la formula de gauss para el calculo del domingo de resurreccion
  -- ya sabiendo el domingo basta con restar para saber el viernes y sabado
   ---CUANDO ES EN MARZO 
  when nombre_del_mes = 'Marzo' 
  and día_del_mes = (22 + ((19*(anio%19)+24)%30) + ((2*(anio%4)+4*(anio%7)+6*((19*(anio%19)+24)%30)+5)%7))-2
  THEN 'viernes santo'
  when nombre_del_mes = 'Marzo' 
  and día_del_mes = (22 + ((19*(anio%19)+24)%30) + ((2*(anio%4)+4*(anio%7)+6*((19*(anio%19)+24)%30)+5)%7))-1
  THEN 'sabado santo'
  ---CUANDO ES EN ABRIL 
  when nombre_del_mes = 'Abril' 
  and día_del_mes = (((19*(anio%19)+24)%30) + ((2*(anio%4)+4*(anio%7)+6*((19*(anio%19)+24)%30)+5)%7)-9)-2
  THEN 'viernes santo'
  when nombre_del_mes = 'Abril' 
  and día_del_mes = (((19*(anio%19)+24)%30) + ((2*(anio%4)+4*(anio%7)+6*((19*(anio%19)+24)%30)+5)%7)-9)-1
  THEN 'sabado santo'


   
END;

UPDATE dim_date
SET es_día_hábil =
  CASE WHEN "identificador_festivo" IS NOT NULL OR es_fin_de_semana THEN FALSE
  ELSE TRUE END
;

COMMIT TRANSACTION ;