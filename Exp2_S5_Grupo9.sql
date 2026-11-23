-- =========================================================================
-- CASO 1: LISTADO DE CLIENTES
-- =========================================================================
SELECT 
    TO_CHAR(c.numrun, '99G999G999') || '-' || c.dvrun AS "RUT Cliente",
    INITCAP(c.pnombre || ' ' || c.appaterno) AS "Nombre Cliente",
    UPPER(po.nombre_prof_ofic) AS "Profesión Cliente",
    TO_CHAR(c.fecha_inscripcion, 'DD-MM-YYYY') AS "Fecha de Inscripción",
    INITCAP(c.direccion) AS "Dirección Cliente"
FROM cliente c
JOIN tipo_cliente tc ON c.cod_tipo_cliente = tc.cod_tipo_cliente
JOIN profesion_oficio po ON c.cod_prof_ofic = po.cod_prof_ofic
WHERE UPPER(tc.nombre_tipo_cliente) = 'TRABAJADORES DEPENDIENTES'
  AND UPPER(po.nombre_prof_ofic) IN ('CONTADOR', 'VENDEDOR')
  AND EXTRACT(YEAR FROM c.fecha_inscripcion) > (
      SELECT ROUND(AVG(EXTRACT(YEAR FROM fecha_inscripcion)))
      FROM cliente
  )
ORDER BY c.numrun ASC;


-- =========================================================================
-- CASO 2: AUMENTO DE CRÉDITO (CREACIÓN DE TABLA Y CONSULTA)
-- =========================================================================
CREATE TABLE clientes_cupos_compra AS
SELECT 
    c.numrun || '-' || c.dvrun AS "RUT_CLIENTE",
    TRUNC(MONTHS_BETWEEN(SYSDATE, c.fecha_nacimiento) / 12) AS "EDAD",
    TO_CHAR(tc.cupo_disp_compra, '$99G999G999') AS "CUPO_DISPONIBLE_COMPRA",
    UPPER(tcl.nombre_tipo_cliente) AS "TIPO_CLIENTE"
FROM cliente c
JOIN tarjeta_cliente tc ON c.numrun = tc.numrun
JOIN tipo_cliente tcl ON c.cod_tipo_cliente = tcl.cod_tipo_cliente
WHERE tc.cupo_disp_compra >= (
    SELECT MAX(cupo_disp_compra)
    FROM tarjeta_cliente
    WHERE EXTRACT(YEAR FROM fecha_solic_tarjeta) = EXTRACT(YEAR FROM SYSDATE) - 1
)
ORDER BY "EDAD" ASC;

-- Consulta para verificar los datos almacenados en la nueva tabla
SELECT * FROM clientes_cupos_compra;
