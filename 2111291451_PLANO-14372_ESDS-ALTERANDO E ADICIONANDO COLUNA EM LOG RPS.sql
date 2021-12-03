--<DS_SCRIPT>
-- DESCRIÇÃO..: Alterando a coluna cd_prestador e adicionando cd_presador eventual
-- RESPONSAVEL: Elias Santana
-- DATA.......: 29/11/2021
-- APLICAÇÃO..: MVSAUDE V.155 PLANO-14372
--</DS_SCRIPT>

ALTER TABLE dbaps.LOG_VINCULACAO_RPS_ANS ADD CD_PRESTADOR_EVENTUAL NUMBER(20)
/
ALTER TABLE dbaps.log_vinculacao_rps_ans
  ADD CONSTRAINT cnt_log_vinc_rps_prest_ev_fk FOREIGN KEY (
    cd_prestador_eventual
  ) REFERENCES dbaps.prestador_eventual (
    cd_prestador_eventual
  )
/
ALTER TABLE dbaps.LOG_VINCULACAO_RPS_ANS MODIFY CD_PRESTADOR NULL
/
COMMENT ON COLUMN dbaps.log_vinculacao_rps_ans.cd_prestador_eventual IS ' CODIGO DO PRESTADOR EVENTUAL'
