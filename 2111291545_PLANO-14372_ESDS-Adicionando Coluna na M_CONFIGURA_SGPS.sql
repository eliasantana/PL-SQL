--<DS_SCRIPT>
-- DESCRIÇÃO..: Adicionando o campo de controle de envio do prestador eventual para o RPS
-- RESPONSAVEL: Elias Santana
-- DATA.......: 25/11/2021
-- APLICAÇÃO..: MVSAUDE V.155 PLANO-14372
--</DS_SCRIPT>
ALTER TABLE DBAPS.PLANO_DE_SAUDE DISABLE ALL TRIGGERS
/
ALTER TABLE DBAPS.PLANO_DE_SAUDE ADD sn_env_prestevt_rps VARCHAR2(1) DEFAULT 'N'
/
ALTER TABLE DBAPS.PLANO_DE_SAUDE ADD CONSTRAINT
    cnt_sn_envprest_rps_chk CHECK(
     sn_env_prestevt_rps IN ('S','N')
    )

/
COMMENT ON COLUMN DBAPS.PLANO_DE_SAUDE.sn_env_prestevt_rps IS 'Determina se o prestador Eventual será enviado para o RPS'
/
ALTER TABLE DBAPS.PLANO_DE_SAUDE ENABLE ALL TRIGGERS