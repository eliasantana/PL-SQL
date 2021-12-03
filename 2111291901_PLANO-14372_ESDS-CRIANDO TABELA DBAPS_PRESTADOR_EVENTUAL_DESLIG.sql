--<DS_SCRIPT>
-- DESCRIÇÃO..: Criando tabela para controle de ativação/reativação do prestador eventual.
-- RESPONSAVEL: Elias Santana
-- DATA.......: 22/10/2021
-- APLICAÇÃO..: MVSAUDE   PLANO-14372
--</DS_SCRIPT>
--<USUARIO=DBAPS>

CREATE TABLE DBAPS.PRESTADOR_EVENTUAL_DESLIG (

  CD_PRESTADOR_EVENTUAL_DELISG NUMBER NOT NULL,
  CD_PRESTADOR_EVENTUAL NUMBER NULL,
  DT_DESLIGAMENTO DATE,
  DT_REATIVACAO DATE
)
/
ALTER TABLE DBAPS.PRESTADOR_EVENTUAL_DESLIG
    ADD CONSTRAINT CNT_PREST_EVENT_DESL_PK PRIMARY KEY (CD_PRESTADOR_EVENTUAL_DELISG)
/
ALTER TABLE DBAPS.PRESTADOR_EVENTUAL_DESLIG
    ADD CONSTRAINT CNT_PREST_EVENT_DESL_FK FOREIGN KEY (cd_prestador_eventual)
    REFERENCES dbaps.prestador_eventual (cd_prestador_eventual)
/
COMMENT ON COLUMN dbaps.prestador_eventual_deslig.cd_prestador_eventual IS 'Código do Prestador Eventual'
/
COMMENT ON COLUMN dbaps.prestador_eventual_deslig.dt_desligamento IS 'Data de Desligamento do Prestador Eventual'
/
COMMENT ON COLUMN dbaps.prestador_eventual_deslig.dt_reativacao IS 'Data de reativação do cadastro do Prestador Eventual'
/
GRANT DELETE,INSERT,REFERENCES,SELECT,UPDATE ON dbaps.prestador_eventual_deslig TO dbamv
/
GRANT DELETE,INSERT,REFERENCES,SELECT,UPDATE ON dbaps.prestador_eventual_deslig TO dbasgu
/
GRANT DELETE,INSERT,SELECT,UPDATE ON dbaps.prestador_eventual_deslig TO mv2000
/
GRANT DELETE,INSERT,REFERENCES,SELECT,UPDATE ON dbaps.prestador_eventual_deslig TO mvintegra
/
