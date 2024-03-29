USE [BFPMARKETING]
GO
/****** Object:  StoredProcedure [dbo].[sp_FVE_GENERATE_UPD_TT_COMERCIAL]    Script Date: 25/04/2022 15:49:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[sp_FVE_GENERATE_UPD_TT_COMERCIAL] 
as
begin

		
;with mae_mesas as (
	SELECT * FROM
		(
			SELECT rtrim(A.Administrador) as Administrador,A.AgenciaAdmin,A.iGrupoAdmin,a.fecdesem3,
			ROW_NUMBER() OVER(PARTITION BY A.Administrador ORDER BY A.fecdesem3 DESC) AS Orden
			FROM
			--JR_sf_negocios_bkp.dbo.TT_COMERCIAL A
			dbo.TT_COMERCIAL A
			WHERE
			A.STATUSCREDITO in ('VIGENTE','CANCELADO') AND
			A.SITUACION='DESEMBOLSADO' AND
			A.IFLAGCASTIGO='0' AND
			(A.AGENCIAADMIN NOT IN ('AGENCIA GNV') OR A.AGENCIAADMIN IS NULL) and
			a.Administrador<>''
			--GROUP BY rtrim(A.Administrador),A.AgenciaAdmin,A.iGrupoAdmin
		) A WHERE A.Orden=1
) ,
fact_saldo_sm as (
--130
	SELECT A.numexp,B.vIDIBSCredito,A.CargoEva,rtrim(A.Evaluador) Evaluador,A.CargoAdmin,rtrim(A.Administrador) Administrador,
			A.AgenciaAdmin,A.fecdesem3,A.TasaInteres,A.SaldoCartsoles,A.iGrupoAdmin,b.dcSaldoPrinSoles
	FROM
	dbo.TT_COMERCIAL A
		LEFT JOIN dbo.TM_CREDITO B on A.NUMEXP=B.IIDEXPEDIENTE
	WHERE
	A.STATUSCREDITO in ('') AND
	A.SITUACION='DESEMBOLSADO' AND
	--A.IFLAGCASTIGO='0' AND
	A.AGENCIAADMIN NOT IN ('AGENCIA GNV')
),
fact_saldo_ibs as
(
	select a.NumeroOperacion,a.TasaInteres,a.FechaAperturaOriginal,a.SaldoActual from dbo.maesaldos a --Cambio solo para replicar cierre
	where a.SaldoActual is not null
),
hc_tt_comercial as
(
select * from (
select
a.numexp as NUM_EXP,
a.vIDIBSCredito AS IBS_CREDITO,
'VIGENTE' AS STATUS_CREDITO,
a.CargoEva AS CARGO_EVAL_ADMIN,
a.Evaluador as EVAL_ADMIN,
b.AgenciaAdmin as AGENCIA_ADMIN,
b.iGrupoAdmin as GRUPO_ADMIN,
c.FechaAperturaOriginal as FECHA_VTA,
c.SaldoActual as SALDO_ACTUAL,
c.TasaInteres as TASA_INTERES
from fact_saldo_sm a
left join mae_mesas b on rtrim(a.Evaluador)=rtrim(b.Administrador)
left join fact_saldo_ibs c on a.vIDIBSCredito*1=c.NumeroOperacion*1
) a
where
a.SALDO_ACTUAL is not null
)
--SELECT A.StatusCredito,A.SaldoCartsoles,A.TasaInteres,A.CargoAdmin,A.Administrador,A.iGrupoAdmin,A.AgenciaAdmin,A.fecdesem3
--FROM
--DBO.TT_COMERCIAL A INNER JOIN hc_tt_comercial B ON A.numexp=B.NUM_EXP
UPDATE A
SET
A.StatusCredito=B.STATUS_CREDITO,
A.SaldoCartsoles=B.SALDO_ACTUAL,
A.TasaInteres=B.TASA_INTERES,
A.CargoAdmin=B.CARGO_EVAL_ADMIN,
A.Administrador=B.EVAL_ADMIN,
A.iGrupoAdmin=B.GRUPO_ADMIN,
A.AgenciaAdmin=B.AGENCIA_ADMIN,
A.fecdesem3=B.FECHA_VTA
FROM
DBO.TT_COMERCIAL A INNER JOIN hc_tt_comercial B ON A.numexp=B.NUM_EXP


UPDATE DBO.TT_COMERCIAL
SET AGENCIAADMIN = 'AGENCIA COLONIAL'
WHERE numexp = '11088940'

--11070490
--11081580
--11088430

 

UPDATE DBO.TT_COMERCIAL
SET AGENCIAADMIN = 'AGENCIA GAMARRA'
WHERE numexp = '11070490'


 

UPDATE DBO.TT_COMERCIAL
SET AGENCIAADMIN = 'AGENCIA ICA'
WHERE numexp = '11081580'

UPDATE DBO.TT_COMERCIAL
SET AGENCIAADMIN = 'AGENCIA PUENTE PIEDRA'
WHERE numexp = '11088430'


 

UPDATE DBO.TT_COMERCIAL
SET AGENCIAADMIN = 'AGENCIA JULIACA'
WHERE numexp = '11022650'


--### OPERACIONES NULL -> AGENCIAADMIN 
	
	----SELECT A.numexp,B.vIDIBSCredito,A.CargoEva,rtrim(A.Evaluador) Evaluador,A.CargoAdmin,rtrim(A.Administrador) Administrador,A.AgenciaAdmin,A.fecdesem3,A.TasaInteres,A.SaldoCartsoles,A.iGrupoAdmin,
	----b.dcSaldoPrinSoles	
	UPDATE DBO.TT_COMERCIAL  
	SET AGENCIAADMIN = 'ERROR_SIN_AGENCIA' 
	FROM DBO.TT_COMERCIAL A 
	LEFT  JOIN dbo.TM_CREDITO B on A.NUMEXP=B.IIDEXPEDIENTE 
	WHERE 
	A.STATUSCREDITO in ('VIGENTE') AND
	A.SITUACION='DESEMBOLSADO' AND
	A.IFLAGCASTIGO='0' AND
	--A.AGENCIAADMIN NOT IN ('AGENCIA GNV') and
	a.AgenciaAdmin is null

END