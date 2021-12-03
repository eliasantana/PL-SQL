--<DS_SCRIPT>
-- DESCRI��O..: Adicionando campos necess�rios para envio do RPS
-- RESPONSAVEL: Elias Santana
-- DATA.......: 25/11/2021
-- APLICA��O..: MVSAUDE V.155 PLANO-14372
--</DS_SCRIPT>

ALTER TABLE DBAPS.PRESTADOR_EVENTUAL DISABLE ALL TRIGGERS
/
ALTER TABLE DBAPS.PRESTADOR_EVENTUAL ADD  DT_INI_CONTRATO DATE NULL
/
ALTER TABLE DBAPS.PRESTADOR_EVENTUAL ADD  DT_INI_SERVICO DATE NULL
/
ALTER TABLE DBAPS.PRESTADOR_EVENTUAL ADD  CD_CNES VARCHAR2(20) NULL
/
ALTER TABLE DBAPS.PRESTADOR_EVENTUAL ADD  CD_MUNICIPIO NUMBER(10) NULL
/
ALTER TABLE DBAPS.PRESTADOR_EVENTUAL ADD  CD_CLASSIFICACAO  NUMBER(1,0) NULL
/
ALTER TABLE DBAPS.PRESTADOR_EVENTUAL ADD  CD_REGISTRO_ANS_INTERMED  VARCHAR2(6) NULL
/
ALTER TABLE DBAPS.PRESTADOR_EVENTUAL ADD  TP_DISPONIBILIDADE VARCHAR2(1) NULL
/
ALTER TABLE DBAPS.PRESTADOR_EVENTUAL ADD  TP_CONTRATUALIZACAO VARCHAR2(1) NULL
/
ALTER TABLE dbaps.prestador_eventual ADD  TP_CREDENCIAMENTO VARCHAR2(1) NULL
/
ALTER TABLE dbaps.prestador_eventual ADD URGENCIA_EMERGENCIA VARCHAR2(1) NULL
/
ALTER TABLE dbaps.PRESTADOR_EVENTUAL
  ADD CONSTRAINT cnt_prestevent1_ck CHECK (
    TP_DISPONIBILIDADE in ('T', 'P')
  )
/
ALTER TABLE dbaps.PRESTADOR_EVENTUAL
  ADD CONSTRAINT cnt_prestevent2_ck CHECK (
    urgencia_emergencia in ('U', 'E')
  )
/
ALTER TABLE dbaps.PRESTADOR_EVENTUAL
  ADD CONSTRAINT cnt_prestevent3ck CHECK (
   tp_contratualizacao in ('D', 'I')
  )
/
ALTER TABLE dbaps.prestador_eventual
  ADD CONSTRAINT cnt_prestevent_tp_credenc_ck CHECK (
    TP_CREDENCIAMENTO IN ('P', 'C', 'O', 'D', 'I', 'J')
  )
/
COMMENT ON COLUMN dbaps.PRESTADOR_EVENTUAL.dt_cancelamento IS 'Data de Cancelamenoto'
/
COMMENT ON COLUMN dbaps.PRESTADOR_EVENTUAL.dt_ini_contrato IS 'Data de inicio da Contratualiza��o'
/
COMMENT ON COLUMN dbaps.PRESTADOR_EVENTUAL.dt_ini_servico IS 'Data de inicio do Servi�o'
/
COMMENT ON COLUMN dbaps.PRESTADOR_EVENTUAL.cd_cnes IS 'C�digo CNES'
/
COMMENT ON COLUMN dbaps.PRESTADOR_EVENTUAL.cd_classificacao IS '1 � Assist�ncia Hospitalar / 2 � Servi�os de alta complexidade / 3 � demais estabelecimentos'
/
COMMENT ON COLUMN dbaps.PRESTADOR_EVENTUAL.cd_registro_ans_intermed IS 'C�digo de registro na ANS da operadora intermedi�ria na rela��o entre o prestador e a operadora.'
/
COMMENT ON COLUMN dbaps.PRESTADOR_EVENTUAL.tp_disponibilidade IS 'C�digo da disponibilidade de servi�o do prestador. <T> para Total e <P> para Parcial'
/
COMMENT ON COLUMN dbaps.PRESTADOR_EVENTUAL.urgencia_emergencia IS 'Sinaliza��o de urg�ncia/emerg�ncia do prestador. <S> para Sim e <N> para N�o.'
/
COMMENT ON COLUMN dbaps.PRESTADOR_EVENTUAL.tp_contratualizacao IS 'C�digo do tipo de contratualiza��o entre o prestador e a operadora. <D> Direta <I> Idireta'
/
COMMENT ON COLUMN dbaps.prestador_eventual.tp_credenciamento IS 'Classifica��o do prestador quanto ao tipo de credenciamento. Valores aceitos: P-Pr�rios,
C-Credenciamento, O-Outros, D-Cooperado, I-Intarc�mbio, J-Eventos Judiciais'
/
ALTER TABLE DBAPS.PRESTADOR_EVENTUAL ENABLE ALL TRIGGERS