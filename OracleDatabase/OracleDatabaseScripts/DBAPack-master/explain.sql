set autotrace off timing off
SET VERIFY OFF
--DEFINE SIFUS=USR_SIAFI_OLD

--alter session set current_schema=usr_folhacd;

/*
ALTER SESSION SET NLS_SORT='BINARY'
/
ALTER SESSION SET NLS_COMP='BINARY'
/

ALTER SESSION SET NLS_SORT='WEST_EUROPEAN'
/
ALTER SESSION SET NLS_COMP='ANSI'
/
*/

--CREATE INDEX USR_FOLHACD.IX_FFI_BENE_FF_RUBR
--ON  USR_FOLHACD.fichafinanceiraitem(idebeneficiario, idefichafinanceira,iderubrica)
--TABLESPACE TBSI_FOLHACD
--/

--ALTER SESSION SET OPTIMIZER_FEATURES_ENABLE='12.1.0.2';
--ALTER SESSION SET OPTIMIZER_FEATURES_ENABLE='11.2.0.2';
--alter session enable parallel dml;

EXPLAIN PLAN SET STATEMENT_ID='&1.' INTO sys.plan_table$ FOR
update /*+ rule */ usr_dw_sisconle.ft_etapa_situacao_solicitacao 
set ide_dim_ultima_situacao_mes = 800
where (ide_dim_etapa_solicitacao_trab,ide_data_etapa) in 
(select etapa_ante.ide_dim_etapa_solicitacao_trab, etapa_ante.ide_data_etapa --,etapa_ante.ide_dim_solicitacao_trabalho
from usr_dw_sisconle.ft_etapa_situacao_solicitacao etapa_ante
inner join usr_dw_corporativo.dimtempo dimtempo_ante
        on dimtempo_ante.IDETEMPO = etapa_ante.ide_data_etapa
inner join (select etapa_final.ide_dim_solicitacao_trabalho, etapa_final.ide_Dim_situacao_etapa, etapa_final.ide_data_etapa, dimtempo.CODANO, dimtempo.codmes  
                from usr_dw_sisconle.ft_etapa_situacao_solicitacao etapa_final
                  inner join usr_dw_corporativo.dimtempo dimtempo
                          on dimtempo.IDETEMPO = etapa_final.ide_data_etapa
                  where etapa_final.ide_Dim_situacao_etapa = 800) etapa_final -- Retorna todas etapas Canceladas
      on etapa_final.ide_dim_solicitacao_trabalho = etapa_ante.IDE_DIM_SOLICITACAO_TRABALHO
      and etapa_final.codano = dimtempo_ante.codano
      and etapa_final.codmes = dimtempo_ante.codmes
where etapa_ante.ide_dim_ultima_situacao_mes not in (800,9999)) -- altera etapas diferentes de Canceladas ou Ajustes no mesmo dia da etapa Cancelada
/
