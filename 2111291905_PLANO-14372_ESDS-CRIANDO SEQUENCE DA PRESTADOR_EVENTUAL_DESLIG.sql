--<DS_SCRIPT>
-- DESCRI��O..: Criano sequence
-- RESPONSAVEL: Elias Santana
-- DATA.......: 29/11/2021
-- APLICA��O..: MVSAUDE V.155 PLANO-14372
--</DS_SCRIPT>

CREATE SEQUENCE dbaps.seq_prestador_eventual_deslig
  MINVALUE 1
  MAXVALUE 999999999999999999999999999
  INCREMENT BY 1
  NOCYCLE
  NOORDER
  NOCACHE
/
GRANT SELECT ON dbaps.seq_prestador_eventual_deslig TO dbamv
/
GRANT SELECT ON dbaps.seq_prestador_eventual_deslig TO dbasgu
/
GRANT SELECT ON dbaps.seq_prestador_eventual_deslig TO mv2000
/
GRANT SELECT ON dbaps.seq_prestador_eventual_deslig TO mvintegra
