--<DS_SCRIPT>
-- DESCRIÇÃO..: Adicionando condição lógica para retorno os reembolsos cujo o valor SN_ENVIO_MONIT_TISS='S'
-- RESPONSAVEL: Elias Santana
-- DATA.......: 24/09/2020
-- APLICAÇÃO..: MVSAUDE
--</DS_SCRIPT>
--<USUARIO=DBAPS>

CREATE OR REPLACE PACKAGE dbaps.pkg_monitoramento_tiss IS
	/**************************************************************
    <objeto>
      <nome>pkg_monitoramento_tiss</nome>
      <usuario>Athos Bonner, Bruno Felix, Antonio Andrade, Elias Santana</usuario>
      <alteracao>24/09/2020 15:19</alteracao>
      <descricao>Package responsavel por gerar o monitoramento tiss</descricao>
      <Alteracao>
              Adicionado filtro para os reembolsos cujo o tipo configurado em DBAPS.TIPO_REEMBOLSO no campo SN_ENVIO='S'.
              Este parâmetro é configurável na tela M_TIP_REEMBOLSO.
       </Alteracao>
      <parametro></parametro>
      <versao>1.10</versao>
      <tags>TISS, MONITORAMENTO TISS, MONITORAMENTOTISS</tags>
    </objeto>
  ***************************************************************/

  /* GUIA */
  TYPE ROW_GUIA IS RECORD(
    CD_CONTA_MEDICA NUMBER,
    TP_CONTA VARCHAR2(1),
    NR_GUIA_OPERADORA VARCHAR2(20),
    NR_MES VARCHAR2(2),
    NR_ANO VARCHAR2(4),
    CD_PRESTADOR NUMBER,
    TP_REGISTRO VARCHAR(1));
    TYPE TABLE_GUIA IS TABLE OF ROW_GUIA;
    FUNCTION GET_TABLE_GUIA(P_DT_COMPETENCIA IN DATE, P_CD_MULTI_EMPRESA IN NUMBER, P_CD_MONITORAMENTO_TISS IN NUMBER) RETURN TABLE_GUIA PIPELINED;
  /* GUIA */
  /* DADOS_GUIA */
  TYPE ROW_DADOS_GUIA IS RECORD(
    DS_VERSAO_TISS_PRESTADOR VARCHAR2(10),
    CD_CNES VARCHAR2(16),
    TP_IDENTIFICADOR_EXECUTANTE NUMBER(1,0),
    CD_CNPJ_CPF VARCHAR2(14),
    CD_PRESTADOR NUMBER(12, 0),
    CD_MUNICIPIO_EXECUTANTE NUMBER(6,0),
    NR_ANS_INTERMEDIARIO NUMBER(6,0),
    CD_TIPO_ATENDIMENTO_INTERMED NUMBER(10,0),
    NR_CARTAO_NACIONAL_SAUDE VARCHAR2(20),
    TP_SEXO NUMBER(1,0),
    DT_NASCIMENTO DATE,
    DS_MUNICIPIO_RESIDENCIA NUMBER(6,0),
    NR_REGISTRO_PLANO VARCHAR2(20),
    TP_EVENTO_ATENCAO NUMBER(1,0),
    TP_ORIGEM_EVENTO_ATENCAO NUMBER(1,0),
    NR_GUIA_PRESTADOR VARCHAR2(20),
    NR_GUIA_OPERADORA VARCHAR2(20),
    CD_IDENTIFICACAO_REEMBOLSO VARCHAR2(20),
    CD_IDENTIF_CT_VL_PRE_ESTAB VARCHAR2(20),
    NR_GUIA_SOLICITACAO_INTERNACAO VARCHAR2(20),
    DT_SOLICITACAO DATE,
    NR_GUIA_TEM VARCHAR2(20),
    DT_AUTORIZACAO DATE,
    DT_REALIZACAO DATE,
    DT_INICIAL_FATURAMENTO DATE,
    DT_FIM_PERIODO DATE,
    DT_PROTOCOLO_COBRANCA DATE,
    DT_PAGAMENTO DATE,
    TP_CONSULTA VARCHAR2(1),
    CD_CBO_EXECUTANTE VARCHAR2(6),
    SN_RECEM_NATO VARCHAR2(1),
    TP_ACIDENTE VARCHAR2(1),
    TP_CARATER_ATENDIMENTO VARCHAR2(1),
    TP_INTERNACAO VARCHAR2(1),
    TP_REGIME_INTERNACAO VARCHAR2(1),
    CD_CID_1 VARCHAR2(100),
    CD_CID_2 VARCHAR2(100),
    CD_CID_3 VARCHAR2(100),
    CD_CID_4 VARCHAR2(100),
    TP_ATENDIMENTO VARCHAR2(2),
    TP_FATURAMENTO VARCHAR2(1),
    DS_MOTIVO_SAIDA VARCHAR2(2),
    TP_TABELA VARCHAR2(2),
    CD_GRUPO_PROCEDIMENTO VARCHAR2(10),
    CD_PROCEDIMENTO VARCHAR2(12),
    TP_DENTE VARCHAR2(2),
    TP_REGIAO VARCHAR2(4),
    DS_DENTE_FACE VARCHAR2(5),
    QT_INFORMADA NUMBER,
    VL_INFORMADO NUMBER,
    QT_PAGA NUMBER,
    VL_PAGO_PROC NUMBER,
    CD_CONTA_MEDICA NUMBER(12, 0),
    CD_LANCAMENTO NUMBER(6,0),
    CD_LANCAMENTO_FILHO NUMBER(6,0),
    TP_CONTA VARCHAR2(1),
    VL_PAGO_FORNECEDOR NUMBER,
    NR_CNPJ_FORNECEDOR NUMBER(14,0),
    TP_GRU_PRO VARCHAR2(2),
    TP_NATUREZA VARCHAR2(3),
    CD_MATRICULA NUMBER(20,0),
    TP_GUIA VARCHAR2(1),
    NR_GUIA NUMBER(10,0),
    VL_TOTAL_COBRADO NUMBER,
    VL_TOTAL_PAGO NUMBER,
    VL_TOTAL_GLOSADO NUMBER,
    CD_FATURA NUMBER(5,0),
    NR_MES VARCHAR2(2),
    NR_ANO VARCHAR2(4),
    TP_SITUACAO_CONTA VARCHAR2(2),
    TP_SITUACAO_ITCONTA VARCHAR2(2),
    VL_FRANQUIA NUMBER,
    VL_TOTAL_FRANQUIA NUMBER,
    TP_ORIGEM VARCHAR(10),
    CD_REPASSE_PRESTADOR NUMBER,
    CD_ESPECIALIDADE NUMBER,
    CD_PTU_TIPO_VINCULO NUMBER,
    TP_ORIGEM_FATURA VARCHAR2(10),
    NR_FATURA_REFERENCIA VARCHAR2(50),
    NR_LOTE_REFERENCIA VARCHAR2(20),
    NR_NOTA_REFERENCIA VARCHAR2(20),
    NR_GUIA_PRESTADOR_REFERENCIA VARCHAR2(20),
    CD_UNIMED_EXECUTORA VARCHAR2(4),
    DS_FATURA VARCHAR2(100),
    CD_CONTA_MEDICA_A520 NUMBER,
    SN_PACOTE VARCHAR2(1),
    CD_PROTOCOLO_CTAMED NUMBER,
    TP_FATURA VARCHAR2(1),
    CD_CNPJ_CPF_EXEC VARCHAR2(14),
    CD_CNES_EXEC VARCHAR2(16),
    CD_MUNICIPIO_EXEC NUMBER(6,0),
    CD_PRESTADOR_PRINCIPAL NUMBER,
    TP_LOTE_CONTA_MEDICA VARCHAR2(1),
    CD_EXCECAO_PTU VARCHAR2(1),
    DT_EXTORNO_A520 DATE);
  TYPE TABLE_DADOS_GUIA IS TABLE OF ROW_DADOS_GUIA;
  FUNCTION GET_TABLE_DADOS_GUIA(P_CD_CONTA_MEDICA IN NUMBER, P_TP_CONTA IN VARCHAR2, P_CD_MULTI_EMPRESA IN NUMBER, P_CD_PRESTADOR IN NUMBER, P_NR_MES IN VARCHAR2, P_NR_ANO IN VARCHAR2, P_GERA_PROCED_PACOTE IN VARCHAR2) RETURN TABLE_DADOS_GUIA PIPELINED;
  /* DADOS_GUIA */
  /* TEMP_MONITORAMENTO */
  TYPE ROW_TEMP_MONITORAMENTO IS RECORD(
    TP_REGISTRO NUMBER(1,0),
    DS_VERSAO_TISS_PRESTADOR VARCHAR2(10),
    CD_CNES VARCHAR2(16),
    TP_IDENTIFICADOR_EXECUTANTE NUMBER(1,0),
    CD_CNPJ_CPF VARCHAR2(14),
    CD_PRESTADOR NUMBER(12, 0),
    CD_MUNICIPIO_EXECUTANTE NUMBER(6,0),
    NR_ANS_INTERMEDIARIO NUMBER(6,0),
    CD_TIPO_ATENDIMENTO_INTERMED NUMBER(10,0),
    NR_CARTAO_NACIONAL_SAUDE VARCHAR2(20),
    TP_SEXO NUMBER(1,0),
    DT_NASCIMENTO DATE,
    DS_MUNICIPIO_RESIDENCIA NUMBER(6,0),
    NR_REGISTRO_PLANO VARCHAR2(20),
    TP_EVENTO_ATENCAO NUMBER(1,0),
    TP_ORIGEM_EVENTO_ATENCAO NUMBER(1,0),
    NR_GUIA_PRESTADOR VARCHAR2(20),
    NR_GUIA_OPERADORA VARCHAR2(20),
    CD_IDENTIFICACAO_REEMBOLSO VARCHAR2(20),
    CD_IDENTIF_CT_VL_PRE_ESTAB VARCHAR2(20),
    NR_GUIA_SOLICITACAO_INTERNACAO VARCHAR2(20),
    DT_SOLICITACAO DATE,
    NR_GUIA_TEM VARCHAR2(20),
    DT_AUTORIZACAO DATE,
    DT_REALIZACAO DATE,
    DT_INICIAL_FATURAMENTO DATE,
    DT_FIM_PERIODO DATE,
    DT_PROTOCOLO_COBRANCA DATE,
    DT_PAGAMENTO DATE,
    TP_CONSULTA VARCHAR2(1),
    CD_CBO_EXECUTANTE VARCHAR2(6),
    SN_RECEM_NATO VARCHAR2(1),
    TP_ACIDENTE VARCHAR2(1),
    TP_CARATER_ATENDIMENTO VARCHAR2(1),
    TP_INTERNACAO VARCHAR2(1),
    TP_REGIME_INTERNACAO VARCHAR2(1),
    CD_CID_1 VARCHAR2(100),
    CD_CID_2 VARCHAR2(100),
    CD_CID_3 VARCHAR2(100),
    CD_CID_4 VARCHAR2(100),
    TP_ATENDIMENTO VARCHAR2(2),
    TP_FATURAMENTO VARCHAR2(1),
    DS_MOTIVO_SAIDA VARCHAR2(2),
    TP_TABELA VARCHAR2(2),
    CD_GRUPO_PROCEDIMENTO VARCHAR2(10),
    CD_PROCEDIMENTO VARCHAR2(12),
    TP_DENTE VARCHAR2(2),
    TP_REGIAO VARCHAR2(4),
    DS_DENTE_FACE VARCHAR2(5),
    QT_INFORMADA NUMBER,
    VL_INFORMADO NUMBER,
    QT_PAGA NUMBER,
    VL_PAGO_PROC NUMBER,
    CD_CONTA_MEDICA NUMBER(12, 0),
    CD_LANCAMENTO NUMBER(6,0),
    CD_LANCAMENTO_FILHO NUMBER(6,0),
    TP_CONTA VARCHAR2(1),
    VL_PAGO_FORNECEDOR NUMBER,
    NR_CNPJ_FORNECEDOR NUMBER(14,0),
    TP_GRU_PRO VARCHAR2(2),
    TP_NATUREZA VARCHAR2(3),
    CD_MATRICULA NUMBER(20,0),
    TP_GUIA VARCHAR2(1),
    NR_GUIA NUMBER(10,0),
    VL_TOTAL_COBRADO NUMBER,
    VL_TOTAL_PAGO NUMBER,
    VL_TOTAL_GLOSADO NUMBER,
    CD_FATURA NUMBER(5,0),
    NR_MES VARCHAR2(2),
    NR_ANO VARCHAR2(4),
    TP_SITUACAO_CONTA VARCHAR2(2),
    TP_SITUACAO_ITCONTA VARCHAR2(2),
    VL_FRANQUIA NUMBER,
    VL_TOTAL_FRANQUIA NUMBER,
    TP_FORMA_ENVIO VARCHAR2(10),
    SN_PACOTE VARCHAR2(1),
    CD_REPASSE_PRESTADOR NUMBER,
    CD_ESPECIALIDADE NUMBER,
    CD_PTU_TIPO_VINCULO NUMBER,
    TP_ORIGEM_FATURA VARCHAR2(10),
    NR_FATURA_REFERENCIA VARCHAR2(50),
    NR_LOTE_REFERENCIA VARCHAR2(20),
    NR_NOTA_REFERENCIA VARCHAR2(20),
    NR_GUIA_PRESTADOR_REFERENCIA VARCHAR2(20),
    CD_UNIMED_EXECUTORA VARCHAR2(4),
    DS_FATURA VARCHAR2(100),
    CD_PROTOCOLO_CTAMED NUMBER,
    TP_FATURA VARCHAR2(1),
    CD_CNPJ_CPF_EXEC VARCHAR2(14),
    CD_CNES_EXEC VARCHAR2(16),
    CD_MUNICIPIO_EXEC NUMBER(6,0),
    CD_PRESTADOR_PRINCIPAL NUMBER,
    CD_CONTA_MEDICA_A520 NUMBER,
    CD_MULTI_EMPRESA NUMBER,
    CD_EXCECAO_PTU VARCHAR2(1),
    DT_EXTORNO_A520 DATE);
  TYPE TABLE_TEMP_MONITORAMENTO IS TABLE OF ROW_TEMP_MONITORAMENTO;
  FUNCTION GET_TABLE_TEMP_MONITORAMENTO(P_DT_COMPETENCIA IN DATE, P_CD_MULTI_EMPRESA IN NUMBER) RETURN TABLE_TEMP_MONITORAMENTO PIPELINED;
  /* TEMP_MONITORAMENTO */
  /* REEMBOLSO */
  TYPE ROW_REEMBOLSO IS RECORD(
    CD_REEMBOLSO NUMBER,
    CD_CNES VARCHAR2(16),
    TP_IDENTIFICADOR_EXECUTANTE NUMBER(1,0),
    CD_CNPJ_CPF VARCHAR2(14),
    CD_PRESTADOR NUMBER(12, 0),
    CD_MUNICIPIO_EXECUTANTE NUMBER(6,0),
    NR_ANS_INTERMEDIARIO NUMBER(6,0),
    CD_TIPO_ATENDIMENTO_INTERMED NUMBER(10,0),
    NR_CARTAO_NACIONAL_SAUDE VARCHAR2(20),
    TP_SEXO NUMBER(1,0),
    DT_NASCIMENTO DATE,
    DS_MUNICIPIO_RESIDENCIA NUMBER(6,0),
    NR_REGISTRO_PLANO VARCHAR2(20),
    TP_EVENTO_ATENCAO NUMBER(1,0),
    TP_ORIGEM_EVENTO_ATENCAO NUMBER(1,0),
    CD_IDENTIF_CT_VL_PRE_ESTAB VARCHAR2(20),
    DT_SOLICITACAO DATE,
    NR_GUIA_TEM VARCHAR2(20),
    DT_AUTORIZACAO DATE,
    DT_REALIZACAO DATE,
    DT_INICIAL_FATURAMENTO DATE,
    DT_PROTOCOLO_COBRANCA DATE,
    DT_PAGAMENTO DATE,
    CD_CBO_EXECUTANTE VARCHAR2(6),
    CD_MATRICULA NUMBER(20,0),
    CD_ESPECIALIDADE NUMBER,
    SN_RECUSADO VARCHAR(1),
    DT_FIM_PERIODO DATE,
    CD_PROTOCOLO_CTAMED NUMBER
    );
  TYPE TABLE_REEMBOLSO IS TABLE OF ROW_REEMBOLSO;
  FUNCTION GET_TABLE_REEMBOLSO(P_DT_COMPETENCIA IN DATE, P_CD_MULTI_EMPRESA IN NUMBER, P_CD_MONITORAMENTO_TISS IN NUMBER) RETURN TABLE_REEMBOLSO PIPELINED;
  /* REEMBOLSO */
  /* IT_REEMBOLSO */
  TYPE ROW_IT_REEMBOLSO IS RECORD(
    TP_TABELA VARCHAR2(2), --
    CD_GRUPO_PROCEDIMENTO VARCHAR2(10), --
    CD_PROCEDIMENTO VARCHAR2(12), --
    TP_DENTE VARCHAR2(2), --
    TP_REGIAO VARCHAR2(4), --
    DS_DENTE_FACE VARCHAR2(5), --
    QT_INFORMADA NUMBER,
    VL_INFORMADO NUMBER,
    QT_PAGA NUMBER,
    VL_PAGO_PROC NUMBER, --
    VL_PAGO_FORNECEDOR NUMBER,
    NR_CNPJ_FORNECEDOR NUMBER(14,0),
    SN_PACOTE VARCHAR2(1),
    TP_GRU_PRO VARCHAR2(2),
    TP_NATUREZA VARCHAR2(3));
  TYPE TABLE_IT_REEMBOLSO IS TABLE OF ROW_IT_REEMBOLSO;
  FUNCTION GET_TABLE_IT_REEMBOLSO(P_CD_REEMBOLSO IN NUMBER) RETURN TABLE_IT_REEMBOLSO PIPELINED;
  /* IT_REEMBOLSO */
  /* MONIT_TISS_GUIA */
  TYPE ROW_MONIT_TISS_GUIA IS RECORD(
    CD_MONIT_TISS_GUIA             NUMBER(38,0),
    CD_MONITORAMENTO_TISS          NUMBER(38,0),
    TP_REGISTRO                    VARCHAR2(10),
    DS_VERSAO_TISS_PRESTADOR       VARCHAR2(40),
    CD_CNES                        VARCHAR2(40),
    TP_IDENTIFICADOR_EXECUTANTE    VARCHAR2(1),
    CD_CNPJ_CPF                    VARCHAR2(40),
    CD_MUNICIPIO_EXECUTANTE        VARCHAR2(40),
    NR_CARTAO_NACIONAL_SAUDE       VARCHAR2(40),
    TP_SEXO                        VARCHAR2(1),
    DT_NASCIMENTO                  DATE,
    DS_MUNICIPIO_RESIDENCIA        VARCHAR2(10),
    NR_REGISTRO_PLANO              VARCHAR2(30),
    TP_EVENTO_ATENCAO              VARCHAR2(10),
    TP_ORIGEM_EVENTO_ATENCAO       VARCHAR2(10),
    NR_GUIA_PRESTADOR              VARCHAR2(40),
    NR_GUIA_OPERADORA              VARCHAR2(40),
    CD_IDENTIFICACAO_REEMBOLSO     VARCHAR2(40),
    NR_GUIA_SOLICITACAO_INTERNACAO VARCHAR2(40),
    DT_SOLICITACAO                 DATE,
    DT_AUTORIZACAO                 DATE,
    DT_REALIZACAO                  DATE,
    DT_INICIAL_FATURAMENTO         DATE,
    DT_FIM_PERIODO                 DATE,
    DT_PROTOCOLO_COBRANCA          DATE,
    DT_PAGAMENTO                   DATE,
    DT_PROCESSAMENTO_GUIA          DATE,
    TP_CONSULTA                    VARCHAR2(10),
    CD_CBO_EXECUTANTE              VARCHAR2(20),
    SN_RECEM_NATO                  VARCHAR2(1),
    TP_ACIDENTE                    VARCHAR2(2),
    TP_CARATER_ATENDIMENTO         VARCHAR2(2),
    TP_INTERNACAO                  VARCHAR2(2),
    TP_REGIME_INTERNACAO           VARCHAR2(2),
    CD_CID_1                       VARCHAR2(10),
    CD_CID_2                       VARCHAR2(10),
    CD_CID_3                       VARCHAR2(10),
    CD_CID_4                       VARCHAR2(10),
    TP_ATENDIMENTO                 VARCHAR2(10),
    TP_FATURAMENTO                 VARCHAR2(10),
    NR_DIARIAS_ACOMPANHANTE        NUMBER,
    NR_DIARIAS_UTI                 NUMBER,
    DS_MOTIVO_SAIDA                VARCHAR2(10),
    VL_TOTAL_INFORMADO             NUMBER,
    VL_PROCESSADO                  NUMBER,
    VL_TOTAL_PAGO_PROCEDIMENTO     NUMBER,
    VL_TOTAL_DIARIA                INTEGER,
    VL_TOTAL_TAXA                  NUMBER,
    VL_TOTAL_MATERIAL              NUMBER,
    VL_TOTAL_OPME                  NUMBER,
    VL_TOTAL_MEDICAMENTO           NUMBER,
    VL_GLOSA_GUIA                  NUMBER,
    VL_PAGO_GUIA                   NUMBER,
    VL_PAGO_FORNECEDOR             NUMBER,
    VL_TOTAL_TABELA_PROPRIA        NUMBER,
    SN_ENVIAR                      VARCHAR2(1),
    NR_SEQUENCIAL                  NUMBER(10,0),
    CD_REEMBOLSO                   NUMBER(13,0),
    SN_INCONSISTENCIA              VARCHAR2(1),
    SN_ALTERADO                    VARCHAR2(1),
    CD_CONTA_MEDICA                NUMBER(12,0),
    CD_LANCAMENTO                  NUMBER(5,0),
    CD_LANCAMENTO_FILHO            NUMBER(5,0),
    TP_CONTA                       VARCHAR2(1),
    TP_SITUACAO                    VARCHAR2(2),
    VL_TOTAL_FRANQUIA              NUMBER,
    TP_FORMA_ENVIO                 NUMBER,
    BKP_VL_TOTAL_DIARIA            NUMBER,
    NR_ANS_INTERMEDIARIO           NUMBER(6,0) ,
    CD_TIPO_ATENDIMENTO_INTERMED   NUMBER(10,0),
    NR_GUIA_TEM                    VARCHAR2(20),
    CD_IDENTIF_CT_VL_PRE_ESTAB     VARCHAR2(20),
    CD_PRESTADOR                   NUMBER,
    CD_ESPECIALIDADE               NUMBER,
    CD_MATRICULA                   NUMBER);
  TYPE TABLE_MONIT_TISS_GUIA IS TABLE OF ROW_MONIT_TISS_GUIA;
  FUNCTION GET_TABLE_MONIT_TISS_GUIA(P_CD_MONITORAMENTO_TISS IN NUMBER, P_CD_MONIT_TISS_GUIA IN NUMBER DEFAULT NULL) RETURN TABLE_MONIT_TISS_GUIA PIPELINED;
  /* MONIT_TISS_GUIA_EXCLUSAO */
  TYPE ROW_MONIT_TISS_EXCL_CM IS RECORD(
    CD_CONTA_MEDICA  NUMBER,
    TP_CONTA         VARCHAR2(1),
    CD_LOTE          NUMBER,
    CD_FATURA        NUMBER,
    DT_COMPETENCIA   VARCHAR2(6),
    SN_A520          VARCHAR2(1),
    CD_MULTI_EMPRESA NUMBER(4,0),
    CD_MONIT_TISS_GUIA NUMBER,
    CD_MONITORAMENTO_TISS NUMBER);
  TYPE TABLE_MONIT_TISS_EXCL_CM IS TABLE OF ROW_MONIT_TISS_EXCL_CM;
  FUNCTION GET_TABLE_MONIT_TISS_EXCL_CM(P_CD_MONITORAMENTO_TISS IN NUMBER, P_CD_MULTI_EMPRESA IN NUMBER) RETURN TABLE_MONIT_TISS_EXCL_CM PIPELINED;
END pkg_monitoramento_tiss;
/

CREATE OR REPLACE PACKAGE BODY dbaps.pkg_monitoramento_tiss IS
  --GUIA
  FUNCTION GET_TABLE_GUIA(P_DT_COMPETENCIA IN DATE, P_CD_MULTI_EMPRESA IN NUMBER, P_CD_MONITORAMENTO_TISS IN NUMBER)
		RETURN TABLE_GUIA
		PIPELINED IS
    CURSOR cGuia IS
      SELECT * FROM (SELECT TP_CONTA,
                            CD_CONTA_MEDICA,
                            CD_PRESTADOR,
                            TP_REGISTRO,
                            NR_MES,
                            NR_ANO
                      FROM (SELECT RP.CD_REMESSA CD_CONTA_MEDICA,
                                   'A' TP_CONTA,
                                   F.NR_MES NR_MES,
                                   F.NR_ANO NR_ANO,
                                   NULL CD_PRESTADOR,
                                   NULL TP_REGISTRO
                              FROM DBAPS.REMESSA_PRESTADOR RP,
                                   DBAPS.LOTE              L,
                                   DBAPS.FATURA            F
                             WHERE RP.CD_LOTE = L.CD_LOTE
                               AND L.CD_FATURA = F.CD_FATURA
                               AND L.TP_LOTE NOT IN ('D')
                               AND Nvl(P_CD_MONITORAMENTO_TISS, 0) = 0
                               AND F.NR_ANO || F.NR_MES = To_Char(P_DT_COMPETENCIA, 'YYYYMM')
                               AND F.CD_MULTI_EMPRESA = P_CD_MULTI_EMPRESA
                             UNION ALL
                            SELECT CH.CD_CONTA_HOSPITALAR CD_CONTA_MEDICA,
                                   'I' TP_CONTA,
                                   F.NR_MES NR_MES,
                                   F.NR_ANO NR_ANO,
                                   NULL CD_PRESTADOR,
                                   NULL TP_REGISTRO
                              FROM DBAPS.CONTA_HOSPITALAR CH,
                                   DBAPS.LOTE             L,
                                   DBAPS.FATURA           F
                             WHERE CH.CD_LOTE = L.CD_LOTE
                               AND L.CD_FATURA = F.CD_FATURA
                               AND L.TP_LOTE NOT IN ('D')
                               AND Nvl(P_CD_MONITORAMENTO_TISS, 0) = 0
                               AND F.NR_ANO || F.NR_MES = To_Char(P_DT_COMPETENCIA, 'YYYYMM')
                               AND F.CD_MULTI_EMPRESA = P_CD_MULTI_EMPRESA)
                      UNION ALL
                      SELECT DISTINCT
                             Nvl(MTGCM.TP_CONTA_MEDICA, MTG.TP_CONTA) TP_CONTA,
                             Nvl(MTGCM.CD_CONTA_MEDICA, MTG.CD_CONTA_MEDICA) CD_CONTA_MEDICA,
                             Nvl(MTGCM.CD_PRESTADOR, MTG.CD_PRESTADOR) CD_PRESTADOR,
                             MTG.TP_REGISTRO,
                             TO_CHAR(MTG.DT_PROCESSAMENTO_GUIA, 'MM') AS NR_MES,
                             TO_CHAR(MTG.DT_PROCESSAMENTO_GUIA, 'YYYY') AS NR_ANO
                        FROM DBAPS.MONIT_TISS_GUIA MTG,
                             DBAPS.MONIT_TISS_GUIA_CONTA_MEDICA MTGCM
                       WHERE MTG.CD_MONIT_TISS_GUIA = MTGCM.CD_MONIT_TISS_GUIA (+)
                         AND MTG.CD_MONITORAMENTO_TISS = P_CD_MONITORAMENTO_TISS
                         AND MTG.SN_INCONSISTENCIA = 'S'
                         AND MTG.TP_REGISTRO IN ('1', '2')
                         AND MTG.CD_REEMBOLSO IS NULL)
      ORDER BY CD_CONTA_MEDICA ASC;
    rGuia ROW_GUIA;
  BEGIN
    FOR r IN cGuia LOOP
      rGuia.CD_CONTA_MEDICA   := r.CD_CONTA_MEDICA;
      rGuia.TP_CONTA          := r.TP_CONTA;
      rGuia.CD_PRESTADOR      := r.CD_PRESTADOR;
      rGuia.TP_REGISTRO       := r.TP_REGISTRO;
      rGuia.NR_MES            := r.NR_MES;
      rGuia.NR_ANO            := r.NR_ANO;
    PIPE ROW(rGuia);
    END LOOP;
    RETURN;
  END;

  --DADOS GUIA
  FUNCTION GET_TABLE_DADOS_GUIA(P_CD_CONTA_MEDICA IN NUMBER, P_TP_CONTA IN VARCHAR2, P_CD_MULTI_EMPRESA IN NUMBER, P_CD_PRESTADOR IN NUMBER, P_NR_MES IN VARCHAR2, P_NR_ANO IN VARCHAR2, P_GERA_PROCED_PACOTE IN VARCHAR2)
		RETURN TABLE_DADOS_GUIA
		PIPELINED IS
    CURSOR cDadosGuia IS
      SELECT DISTINCT *
        FROM (SELECT DBAPS.FNC_VERSAO_TISS_PRESTADOR(g.cd_versao_tiss) DS_VERSAO_TISS_PRESTADOR  --Vers?o do padr?o utilizada pelo prestador
                     ,
                     regexp_replace(Nvl(Decode(ta.tp_guia, 'I', cexp.cd_cnes, cex.cd_cnes), '9999999'),'[^[:digit:]]+') CD_CNES --Codigo no Cadastro Nacional de Estabelecimentos de Saude do executante
                     ,
                     Decode(Decode(ta.tp_guia, 'I', cexp.tp_prestador, cex.tp_prestador), 'F', 2, 'J', 1, 1) AS TP_IDENTIFICADOR_EXECUTANTE --Indicador da identificac?o do prestador executante (escolhido por padrao 1 pois campo nao pode ser null)
                     ,
                     regexp_replace(Decode(ta.tp_guia, 'I', cexp.nr_cpf_cgc, cex.nr_cpf_cgc), '[^[:digit:]]+') AS CD_CNPJ_CPF --Numero de cadastro do prestador executante na Receita Federal
                     ,
                     Decode(ta.tp_guia, 'I', cexp.cd_prestador, cex.cd_prestador) CD_PRESTADOR -- codigo do prestador (para a verificacao de guia atual ou nao)
                     ,
                     NULL AS CD_MUNICIPIO_EXECUTANTE --Municipio de localizac?o do prestador executante (IBGE)
                     ,
                     CASE WHEN VCM.CD_UNIMED_EXECUTORA <> DBAPS.PKG_UNIMED.LE_UNIMED THEN
                       Nvl(cex.cd_registro_ans_intermed, cexp.cd_registro_ans_intermed)
                     END NR_ANS_INTERMEDIARIO --Registro ANS operadora intermediaria
                     ,
                     CASE WHEN VCM.CD_UNIMED_EXECUTORA <> DBAPS.PKG_UNIMED.LE_UNIMED AND To_Date('01/' || f.nr_mes || '/' || f.nr_ano, 'DD/MM/YYYY') > To_Date('01/12/2017', 'DD/MM/YYYY') THEN
                       Decode(DBAPS.FNC_ATENDIMENTO_INTERMEDIARIA(u.cd_matricula,Decode(ta.tp_guia, 'I', cexp.cd_prestador, cex.cd_prestador),VCM.CD_MULTI_EMPRESA,VCM.TP_BENEFICIARIO,'S', VCM.NR_CARTEIRA_BENEFICIARIO ,VCM.DT_REALIZADO), '1', '1', '2', '2', '1')
                     END CD_TIPO_ATENDIMENTO_INTERMED -- Tipo de atendimento por operadora intermediaria
                     ,
                     regexp_replace(u.nr_cns, '[^[:digit:]]+') AS NR_CARTAO_NACIONAL_SAUDE --Cart?o Nacional de Saude
                     ,
                     Decode(u.tp_sexo, 'M', '1', 'F', '3') TP_SEXO --Sexo do beneficiario, conforme tabela de dominio vigente na vers?o que a guia foi enviada (vers?o da tiss - tabela de dominio)
                     ,
                     u.dt_nascimento DT_NASCIMENTO --Data de nascimento do beneficiario (YYYY-MM-DD)
                     ,
                     Nvl(SubStr(U.CD_CIDADE, 0, 6), '000000') DS_MUNICIPIO_RESIDENCIA --Municipio de residencia do beneficiario (IBGE)
                     ,
                     Nvl(Decode(PLA.SN_REGISTRADO_ANS, 'S', Decode(Nvl(to_Char(PLA.CD_REGISTRO_MS), '0'), '0', SubStr(pla.CD_PLANO_OPERADORA, 1, 20), to_Char(PLA.CD_REGISTRO_MS)), Decode(pla.TP_PERIODO_IMPLANTACAO, 1, SubStr(pla.CD_PLANO_OPERADORA, 1, 20), 2, pla.CD_REGISTRO_MS)), '000000') AS NR_REGISTRO_PLANO --Numero de identificac?o do plano do beneficiario na ANS (RPS / SCPA)
                     ,
                     Decode(ta.tp_guia, 'C', '1', 'S', '2', 'I', '3', 'D', '4', 'X', '2', 'H', '5', '2') AS TP_EVENTO_ATENCAO --Tipo de guia
                     ,
                     Decode(Decode(ta.tp_guia, 'I', cexp.tp_credenciamento, cex.tp_credenciamento), 'P', 3, 'C', 1, 'O', 3, 'D', 2, 1) AS TP_ORIGEM_EVENTO_ATENCAO --Origem da guia (1 - Rede Contratada referenciada ou credenciada, 2 - Rede Propria - Cooperados, 3 -Rede Propria - Demais, prestadores, 4 - Reembolso ao beneficiario)
                     ,
                     SUBSTR(Nvl(vcm.nr_guia_prestador, Nvl(vcm.cd_guia_externa, To_Char(vcm.nr_guia))), 1, 20) NR_GUIA_PRESTADOR --Numero da guia no prestador (00000000000000000000)
                     ,
                     SUBSTR(Nvl(To_Char(g.nr_guia), vcm.cd_guia_externa), 1, 20) NR_GUIA_OPERADORA --Numero da guia atribuido pela operadora (00000000000000000000)
                     ,
                     '00000000000000000000' AS CD_IDENTIFICACAO_REEMBOLSO --Identificac?o do reembolso na operadora
                     ,
                     NULL CD_IDENTIF_CT_VL_PRE_ESTAB --Identificador de contratac?o por valor pre-estabelecido
                     ,
                     Decode(ta.tp_guia,
                             'I',
                             regexp_replace(Nvl(vcm.nr_guia_tem, Nvl(g.nr_guia_tem, g.nr_guia)), '[^[:digit:]]+'),
                             'H',
                             regexp_replace(Nvl(vcm.nr_guia_tem, Nvl(g.nr_guia_tem, g.nr_guia)), '[^[:digit:]]+'),
                             'S',
                             Decode((SELECT tat.cd_tiss
                                       FROM dbaps.itremessa_prestador   i,
                                           dbaps.tipo_atendimento_tiss tat
                                     WHERE i.cd_tipo_atendimento_tiss = tat.cd_tipo_atendimento
                                       AND i.cd_remessa = vcm.cd_conta_medica
                                       AND (i.nr_guia = vcm.nr_guia OR i.cd_guia_externa = vcm.cd_guia_externa)
                                       AND ROWNUM = 1),
                                   '07',
                                   regexp_replace(Nvl(vcm.nr_guia_tem, Nvl(g.nr_guia_tem, g.nr_guia)), '[^[:digit:]]+')) -- se for Sadt apenas se paciente estiver internado (07 - Internac?o)
                             ) NR_GUIA_SOLICITACAO_INTERNACAO --Numero da guia de solicitac?o de internac?o
                     ,
                     Nvl(g.dt_emissao, Nvl(vcm.dt_realizado, vcm.DT_APRESENTACAO)) DT_SOLICITACAO --Data da solicitac?o
                     ,
                     Nvl(CASE WHEN ta.tp_guia IN ('S', 'D') THEN
                           Nvl(vcm.NR_GUIA_TEM, g.NR_GUIA_TEM)
                         END,
                         NULL) NR_GUIA_TEM --Numero da guia principal de SP/SADT ou de tratamento odontologico
                     ,
                     Least(Trunc(g.dt_autorizacao), Nvl(vcm.dt_realizado, vcm.DT_APRESENTACAO)) DT_AUTORIZACAO --Data da autorizac?o
                     ,
                     Nvl(vcm.dt_realizado, Nvl(g.dt_autorizacao, vcm.DT_APRESENTACAO)) DT_REALIZACAO --Data de realizac?o ou DATA inicial do periodo de atendimento (Se for nulo considera a autorizacao)
                     ,
                     Decode(ta.tp_guia, 'I', nvl(vcm.dt_entrada, vcm.dt_inicial)) DT_INICIAL_FATURAMENTO --Data de inicio do faturamento
                     ,
                     Decode(ta.tp_guia, 'I', nvl(vcm.dt_saida, vcm.dt_final)) DT_FIM_PERIODO --Data final do periodo de atendimento ou data do fim do faturamento
                     ,
                     Nvl((SELECT pc.dt_envio_lote
                             FROM dbaps.protocolo_ctamed pc,
                                 dbaps.lote             l
                           WHERE pc.cd_protocolo_ctamed = l.cd_protocolo_ctamed
                             AND l.cd_lote = vcm.cd_lote),
                         vcm.dt_lancamento) DT_PROTOCOLO_COBRANCA -- Data do protocolo da cobranca
                     ,
                     vcm.dt_vencimento DT_PAGAMENTO -- Data do pagamento
                     ,
                     Nvl(CASE WHEN ta.tp_guia IN ('C', 'S') THEN
                           (SELECT tc.cd_tiss
                             FROM dbaps.itremessa_prestador i,
                                   dbaps.tipo_consulta       tc
                             WHERE i.cd_tipo_consulta = tc.cd_tipo_consulta
                               AND i.cd_remessa = vcm.cd_conta_medica
                               AND (i.nr_guia = vcm.nr_guia OR i.cd_guia_externa = vcm.cd_guia_externa)
                               AND ROWNUM = 1)
                         END,
                         '1') TP_CONSULTA --Tipo de consulta (vers?o da tiss - tabela de dominio)
                     ,
                     Decode(nvl(g.cd_especialidade, vcm.cd_especialidade), NULL, Decode(ta.tp_guia, 'C', '225125', '999999'), dbaps.fnc_retorna_cbos(nvl(g.cd_especialidade, vcm.cd_especialidade), 'N', 'S')) CD_CBO_EXECUTANTE --Codigo na Classificac?o Brasileira de Ocupac?es (CBO) do executante (vers?o da tiss - tabela de dominio)
                     ,
                     nvl(g.sn_atendimento_recem_nato, 'N') AS SN_RECEM_NATO --Indicador de atendimento ao recem-nato
                     ,
                     Nvl(ia.cd_tiss, '2') TP_ACIDENTE --Indicac?o de acidente ou doenca relacionada (vers?o da tiss - tabela de dominio)
                     ,
                     Nvl(Decode(ch.TP_CARATER_INTERNACAO, 'E', '1', 'U', '2'), Nvl(Decode(g.tp_carater_solic_inter, 'E', '1', 'U', '2'), '1')) TP_CARATER_ATENDIMENTO --Carater do atendimento (vers?o da tiss - tabela de dominio)
                     ,
                     Decode(ta.tp_guia, 'I', Nvl(ti.cd_tiss, '1')) TP_INTERNACAO --Tipo de Internac?o (vers?o da tiss - tabela de dominio)
                     ,
                     Decode(ta.tp_guia, 'I', nvl(ri.cd_tiss, '1')) TP_REGIME_INTERNACAO --Regime de internac?o (vers?o da tiss - tabela de dominio)
                     ,
                     Decode(ta.tp_guia, 'I', (SELECT regexp_replace(nvl(cd_tiss, cd_cid), '[^[:alnum:]]+')
                                                 FROM dbaps.cid
                                               WHERE cd_cid = nvl(vcm.cd_cid, g.cd_cid)), NULL) AS CD_CID_1 --Diagnostico principal
                     ,
                     Decode(ta.tp_guia, 'I',(SELECT regexp_replace(nvl(cd_tiss, cd_cid), '[^[:alnum:]]+')
                                               FROM dbaps.cid
                                             WHERE cd_cid = nvl(ch.cd_cid2, g.cd_cid2)
                                               AND cd_cid NOT IN (nvl(ch.cd_cid, g.cd_cid))), NULL) AS CD_CID_2 --Diagnostico secundario
                     ,
                     Decode(ta.tp_guia, 'I',(SELECT regexp_replace(nvl(cd_tiss, cd_cid), '[^[:alnum:]]+')
                                               FROM dbaps.cid
                                               WHERE cd_cid = nvl(ch.cd_cid3, g.cd_cid3)
                                                 AND cd_cid NOT IN (nvl(ch.cd_cid, g.cd_cid), g.cd_cid2)), NULL) AS CD_CID_3 --Terceiro diagnostico
                     ,
                     Decode(ta.tp_guia, 'I',(SELECT regexp_replace(nvl(cd_tiss, cd_cid), '[^[:alnum:]]+')
                                               FROM dbaps.cid
                                               WHERE cd_cid = nvl(ch.cd_cid4, g.cd_cid4)
                                                 AND cd_cid NOT IN (nvl(ch.cd_cid, g.cd_cid), g.cd_cid2, g.cd_cid3)), NULL) AS CD_CID_4 --Quarto diagnostico
                     ,
                     Decode(Nvl(ta.tp_guia, '05'),
                             'S',
                             Nvl(LPad((SELECT Decode(tat.cd_tiss, '12', '05', tat.cd_tiss) cd_tiss
                                         FROM dbaps.itremessa_prestador   i,
                                             dbaps.tipo_atendimento_tiss tat
                                       WHERE i.cd_tipo_atendimento_tiss = tat.cd_tipo_atendimento
                                         AND i.cd_remessa = vcm.cd_conta_medica
                                         AND (i.nr_guia = vcm.nr_guia OR i.cd_guia_externa = vcm.cd_guia_externa)
                                         AND ROWNUM = 1), 2, '0'),
                                 '05'),
                             '05') TP_ATENDIMENTO --Tipo de atendimento (vers?o da tiss - tabela de dominio)
                     ,
                     CASE WHEN (regexp_replace(Nvl(g.cd_versao_tiss, '30100'), '[^[:digit:]]+')) >= 30100 THEN
                       Decode(ch.cd_tipo_faturamento, 'P', '1', 'F', '2', 'C', '3', '4')
                     ELSE
                       Decode(ch.cd_tipo_faturamento, 'P', 'P', 'T', 'T', 'T')
                     END AS TP_FATURAMENTO --Tipo de faturamento (vers?o da tiss - tabela de dominio)
                     ,
                     CASE WHEN ta.tp_guia IN ('S', 'I') THEN
                       Nvl(ma.cd_tiss, '11')
                     END AS DS_MOTIVO_SAIDA --Motivo de encerramento (tabela de dominio)
                     --------------------------------------------------
                     -- PROCEDIMENTOS
                     --------------------------------------------------
                     ,
                     Decode(p.cd_procedimento,
                             NULL,
                             '00', -- procedimento n existe e 00
                             Decode(Decode(P_GERA_PROCED_PACOTE, 'N', 'N', p.sn_pacote), 'S', '98', dbaps.fnc_tabela_tuss(Nvl(p.cd_procedimento_tuss, vcm.cd_procedimento)))) TP_TABELA --Tabela TUSS do procedimento
                     ,
                     DBAPS.FNC_GRUPO_PROCED_TUSS(Nvl(p.cd_procedimento_tuss, vcm.cd_procedimento), gp.tp_gru_pro) CD_GRUPO_PROCEDIMENTO--Codigo do grupo do procedimento ou item assistencial
                     ,
                     Nvl(p.cd_procedimento_tuss, vcm.cd_procedimento) CD_PROCEDIMENTO --Codigo do procedimento realizado ou item assistencial utilizado
                     ,
                     SubStr(vcm.CD_DENTE, 0, 2) AS TP_DENTE --Identificac?o do dente
                     ,
                     Decode(vcm.CD_DENTE, NULL, SubStr(vcm.CD_REGIAO, 0, 4), NULL) AS TP_REGIAO --Identificac?o da regi?o da boca
                     ,
                     Decode(ta.tp_guia, 'D', SubStr(vcm.CD_FACE, 0, 5)) AS DS_DENTE_FACE --Identificac?o da face do dente
                     ,
                     trunc(Decode(Decode(ta.tp_guia, 'I', cexp.cd_ptu_tipo_vinculo, cex.cd_ptu_tipo_vinculo), 2, vcm.qt_pago, vcm.qt_cobrado), 4) QT_INFORMADA --Quantidade informada de procedimentos ou itens assistenciais
                     ,
                     trunc(Decode(Decode(ta.tp_guia, 'I', cexp.cd_ptu_tipo_vinculo, cex.cd_ptu_tipo_vinculo), 2, vcm.vl_unit_pago, vcm.vl_unit_cobrado), 2) VL_INFORMADO --Valor informado de procedimentos ou itens assistenciais
                     ,
                     CASE WHEN trunc(vcm.vl_unit_pago, 2) = 0 THEN
                      0
                     ELSE
                      trunc(vcm.qt_pago, 4)
                     END QT_PAGA
                     --trunc(vcm.qt_pago, 4) QT_PAGA --Quantidade paga de procedimentos ou itens assistenciais
                     ,
                     trunc(vcm.vl_unit_pago, 2) VL_PAGO_PROC --Valor pago ao prestador executante ou reembolsado ao beneficiario.
                     ,
                     vcm.cd_conta_medica -- CONTA MEDIA
                     ,
                     vcm.cd_lancamento -- LANCAMENTO
                     ,
                     vcm.cd_lancamento_filho -- LANC. FILHO
                     ,
                     vcm.tp_conta --TP_CONTA
                     ,
                     0 AS vl_pago_fornecedor --Valor pago diretamente ao fornecedor
                     ,
                     NULL AS NR_CNPJ_FORNECEDOR --Numero de cadastro do fornecedor na Receita Federal
                     ,
                     GP.tp_gru_pro
                     ,
                     p.TP_NATUREZA
                     ,
                     u.cd_matricula
                     ,
                     ta.tp_guia
                     ,
                     g.nr_guia
                     ,
                     trunc(Decode(Decode(ta.tp_guia, 'I', cexp.cd_ptu_tipo_vinculo, cex.cd_ptu_tipo_vinculo), 2, vcm.vl_total_pago, vcm.vl_total_cobrado), 2) vl_total_cobrado
                     ,
                     trunc(vcm.vl_total_pago, 2) vl_total_pago
                     ,
                     trunc(Decode(Decode(ta.tp_guia, 'I', cexp.cd_ptu_tipo_vinculo, cex.cd_ptu_tipo_vinculo), 2, 0, vcm.vl_total_glosado), 2) vl_total_glosado
                     ,
                     vcm.cd_fatura
                     ,
                     f.nr_mes
                     ,
                     f.nr_ano
                     ,
                     vcm.tp_situacao_conta
                     ,
                     vcm.tp_situacao_itconta
                     ,
                     CASE WHEN ta.tp_guia IN ('H', 'I', 'S') THEN
                       0
                     ELSE
                       Nvl(vcm.vl_franquia, 0)
                     END vl_franquia
                     ,
                     CASE WHEN ta.tp_guia IN ('H') THEN
                       0
                     ELSE
                       Nvl(vcm.vl_total_franquia, 0)
                     END vl_total_franquia
                     ,
                     g.tp_origem
                     ,
                     vcm.cd_repasse_prestador
                     ,
                     nvl(g.cd_especialidade, vcm.cd_especialidade) cd_especialidade
                     ,
                     Decode(ta.tp_guia, 'I', cexp.cd_ptu_tipo_vinculo, cex.cd_ptu_tipo_vinculo) cd_ptu_tipo_vinculo
                     ,
                     vcm.tp_origem_fatura tp_origem_fatura
                     ,
                     f.nr_fatura_referencia nr_fatura_referencia
                     ,
                     vcm.nr_lote_referencia_ptu nr_lote_referencia
                     ,
                     vcm.nr_nota_referencia nr_nota_referencia
                     ,
                     vcm.nr_guia_prestador nr_guia_prestador_referencia
                     ,
                     vcm.cd_unimed_executora cd_unimed_executora
                     ,
                     SubStr(f.ds_fatura, 0, 23) ds_fatura
                     ,
                     vcm.cd_conta_medica_a520 cd_conta_medica_a520
                     ,
                     p.sn_pacote sn_pacote
                     ,
                     vcm.cd_protocolo_ctamed cd_protocolo_ctamed
                     ,
                     vcm.tp_fatura tp_fatura
                     ,
                     vcm.nr_cpf_cnpj_prestador_exec cd_cnpj_cpf_exec
                     ,
                     vcm.cd_cnes_prestador_exec cd_cnes_exec
                     ,
                     SubStr(vcm.cd_munic_prestador_exec, 0, 6) cd_municipio_exec
                     ,
                     vcm.cd_prestador_principal cd_prestador_principal
                     ,
                     vcm.cd_excecao_ptu cd_excecao_ptu
                     ,
                     vcm.dt_extorno_a520 dt_extorno_a520
                FROM dbaps.v_ctas_medicas     vcm,
                     dbaps.fatura             f,
                     dbaps.guia               g,
                     dbaps.tipo_atendimento   ta,
                     dbaps.tipo_internacao    ti,
                     dbaps.regime_internacao  ri,
                     dbaps.usuario            u,
                     dbaps.plano              pla,
                     dbaps.prestador          cex, --Contratado Executante
                     dbaps.prestador          cexp, --Contratado Executante principal
                     dbaps.indicador_acidente ia,
                     dbaps.conta_hospitalar   ch,
                     dbaps.procedimento       p,
                     dbaps.grupo_procedimento gp,
                     dbaps.motivo_alta        ma
               WHERE vcm.cd_conta_medica = ch.cd_conta_hospitalar(+)
                 AND vcm.cd_fatura = f.cd_fatura
                 AND vcm.nr_guia = g.nr_guia(+)
                 AND vcm.cd_tipo_atendimento = ta.cd_tipo_atendimento
                 AND vcm.tp_internacao = ti.ds_sigla_internacao(+)
                 AND ch.cd_regime_internacao = ri.cd_regime_internacao(+)
                 AND g.cd_indicador_acidente = ia.cd_indicador_acidente(+)
                 AND vcm.cd_matricula = u.cd_matricula
                 AND u.cd_plano = pla.cd_plano
                 AND DBAPS.fnc_mvs_retorna_prestador_rep(vcm.cd_prestador_principal, vcm.cd_prestador) = cex.cd_prestador(+) --Contratado Executante
                 AND ch.cd_prestador = cexp.cd_prestador (+) --Contratado Principal
                 AND vcm.cd_procedimento = p.cd_procedimento
                 AND p.cd_grupo_procedimento = gp.cd_grupo_procedimento(+)
                 AND vcm.cd_motivo_alta = ma.cd_motivo_alta(+)
                 AND vcm.cd_conta_medica = P_CD_CONTA_MEDICA
                 AND VCM.tp_conta = P_TP_CONTA
                 AND PLA.SN_MONITORAMENTO_TISS = 'S'
                 AND Nvl(Trunc(Decode(Decode(ta.tp_guia, 'I', cexp.cd_ptu_tipo_vinculo, cex.cd_ptu_tipo_vinculo), 2, vcm.vl_total_pago, vcm.vl_total_cobrado), 2), 0) > 0
                 /* @todo - esse trecho comentado vai enviar para ANS guias em estudo - verificar implementac?o para enviar o pagamento da guia em outra competencia */
                 AND Nvl(Trunc(vcm.vl_total_pago, 2), 0) >= 0
                 AND vcm.cd_procedimento IS NOT NULL
                 AND (VCM.TP_BENEFICIARIO IS NULL OR VCM.TP_BENEFICIARIO IN ('LO', 'LC', 'LR', 'RE', 'ID')) --em nov/2018 OBRIGACAO ANS quem envia e unimed detentora do contrato fica de fora ('RC', 'RP', 'RD', 'RE')
               ORDER BY VCM.CD_GUIA_EXTERNA,
                        VCM.NR_GUIA,
                        VCM.CD_PROCEDIMENTO)
       WHERE (CD_PRESTADOR = Nvl(P_CD_PRESTADOR, CD_PRESTADOR))
         AND (NR_MES || NR_ANO) = (P_NR_MES || P_NR_ANO)
       ORDER BY NR_GUIA_PRESTADOR,
                NR_GUIA_OPERADORA,
                CD_PRESTADOR,
                CD_CONTA_MEDICA;
    rDadosGuia ROW_DADOS_GUIA;
  BEGIN
    FOR r IN cDadosGuia LOOP
      rDadosGuia.DS_VERSAO_TISS_PRESTADOR       := r.DS_VERSAO_TISS_PRESTADOR;
      rDadosGuia.CD_CNES                        := r.CD_CNES;
      rDadosGuia.TP_IDENTIFICADOR_EXECUTANTE    := r.TP_IDENTIFICADOR_EXECUTANTE;
      rDadosGuia.CD_CNPJ_CPF                    := r.CD_CNPJ_CPF;
      rDadosGuia.CD_PRESTADOR                   := r.CD_PRESTADOR;
      rDadosGuia.CD_MUNICIPIO_EXECUTANTE        := r.CD_MUNICIPIO_EXECUTANTE;
      rDadosGuia.NR_ANS_INTERMEDIARIO           := r.NR_ANS_INTERMEDIARIO;
      rDadosGuia.CD_TIPO_ATENDIMENTO_INTERMED   := r.CD_TIPO_ATENDIMENTO_INTERMED;
      rDadosGuia.NR_CARTAO_NACIONAL_SAUDE       := r.NR_CARTAO_NACIONAL_SAUDE;
      rDadosGuia.TP_SEXO                        := r.TP_SEXO;
      rDadosGuia.DT_NASCIMENTO                  := r.DT_NASCIMENTO;
      rDadosGuia.DS_MUNICIPIO_RESIDENCIA        := r.DS_MUNICIPIO_RESIDENCIA;
      rDadosGuia.NR_REGISTRO_PLANO              := r.NR_REGISTRO_PLANO;
      rDadosGuia.TP_EVENTO_ATENCAO              := r.TP_EVENTO_ATENCAO;
      rDadosGuia.TP_ORIGEM_EVENTO_ATENCAO       := r.TP_ORIGEM_EVENTO_ATENCAO;
      rDadosGuia.NR_GUIA_PRESTADOR              := r.NR_GUIA_PRESTADOR;
      rDadosGuia.NR_GUIA_OPERADORA              := r.NR_GUIA_OPERADORA;
      rDadosGuia.CD_IDENTIFICACAO_REEMBOLSO     := r.CD_IDENTIFICACAO_REEMBOLSO;
      rDadosGuia.CD_IDENTIF_CT_VL_PRE_ESTAB     := r.CD_IDENTIF_CT_VL_PRE_ESTAB;
      rDadosGuia.NR_GUIA_SOLICITACAO_INTERNACAO := r.NR_GUIA_SOLICITACAO_INTERNACAO;
      rDadosGuia.DT_SOLICITACAO                 := r.DT_SOLICITACAO;
      rDadosGuia.NR_GUIA_TEM                    := r.NR_GUIA_TEM;
      rDadosGuia.DT_AUTORIZACAO                 := r.DT_AUTORIZACAO;
      rDadosGuia.DT_REALIZACAO                  := r.DT_REALIZACAO;
      rDadosGuia.DT_INICIAL_FATURAMENTO         := r.DT_INICIAL_FATURAMENTO;
      rDadosGuia.DT_FIM_PERIODO                 := r.DT_FIM_PERIODO;
      rDadosGuia.DT_PROTOCOLO_COBRANCA          := r.DT_PROTOCOLO_COBRANCA;
      rDadosGuia.DT_PAGAMENTO                   := r.DT_PAGAMENTO;
      rDadosGuia.TP_CONSULTA                    := r.TP_CONSULTA;
      rDadosGuia.CD_CBO_EXECUTANTE              := r.CD_CBO_EXECUTANTE;
      rDadosGuia.SN_RECEM_NATO                  := r.SN_RECEM_NATO;
      rDadosGuia.TP_ACIDENTE                    := r.TP_ACIDENTE;
      rDadosGuia.TP_CARATER_ATENDIMENTO         := r.TP_CARATER_ATENDIMENTO;
      rDadosGuia.TP_INTERNACAO                  := r.TP_INTERNACAO;
      rDadosGuia.TP_REGIME_INTERNACAO           := r.TP_REGIME_INTERNACAO;
      rDadosGuia.CD_CID_1                       := r.CD_CID_1;
      rDadosGuia.CD_CID_2                       := r.CD_CID_2;
      rDadosGuia.CD_CID_3                       := r.CD_CID_3;
      rDadosGuia.CD_CID_4                       := r.CD_CID_4;
      rDadosGuia.TP_ATENDIMENTO                 := r.TP_ATENDIMENTO;
      rDadosGuia.TP_FATURAMENTO                 := r.TP_FATURAMENTO;
      rDadosGuia.DS_MOTIVO_SAIDA                := r.DS_MOTIVO_SAIDA;
      rDadosGuia.TP_TABELA                      := r.TP_TABELA;
      rDadosGuia.CD_GRUPO_PROCEDIMENTO          := r.CD_GRUPO_PROCEDIMENTO;
      rDadosGuia.CD_PROCEDIMENTO                := r.CD_PROCEDIMENTO;
      rDadosGuia.TP_DENTE                       := r.TP_DENTE;
      rDadosGuia.TP_REGIAO                      := r.TP_REGIAO;
      rDadosGuia.DS_DENTE_FACE                  := r.DS_DENTE_FACE;
      rDadosGuia.QT_INFORMADA                   := r.QT_INFORMADA;
      rDadosGuia.VL_INFORMADO                   := r.VL_INFORMADO;
      rDadosGuia.QT_PAGA                        := r.QT_PAGA;
      rDadosGuia.VL_PAGO_PROC                   := r.VL_PAGO_PROC;
      rDadosGuia.CD_CONTA_MEDICA                := r.CD_CONTA_MEDICA;
      rDadosGuia.CD_LANCAMENTO                  := r.CD_LANCAMENTO;
      rDadosGuia.CD_LANCAMENTO_FILHO            := r.CD_LANCAMENTO_FILHO;
      rDadosGuia.TP_CONTA                       := r.TP_CONTA;
      rDadosGuia.VL_PAGO_FORNECEDOR             := r.VL_PAGO_FORNECEDOR;
      rDadosGuia.NR_CNPJ_FORNECEDOR             := r.NR_CNPJ_FORNECEDOR;
      rDadosGuia.TP_GRU_PRO                     := r.TP_GRU_PRO;
      rDadosGuia.TP_NATUREZA                    := r.TP_NATUREZA;
      rDadosGuia.CD_MATRICULA                   := r.CD_MATRICULA;
      rDadosGuia.TP_GUIA                        := r.TP_GUIA;
      rDadosGuia.NR_GUIA                        := r.NR_GUIA;
      rDadosGuia.VL_TOTAL_COBRADO               := r.VL_TOTAL_COBRADO;
      rDadosGuia.VL_TOTAL_PAGO                  := r.VL_TOTAL_PAGO;
      rDadosGuia.VL_TOTAL_GLOSADO               := r.VL_TOTAL_GLOSADO;
      rDadosGuia.CD_FATURA                      := r.CD_FATURA;
      rDadosGuia.NR_MES                         := r.NR_MES;
      rDadosGuia.NR_ANO                         := r.NR_ANO;
      rDadosGuia.TP_SITUACAO_CONTA              := r.TP_SITUACAO_CONTA;
      rDadosGuia.TP_SITUACAO_ITCONTA            := r.TP_SITUACAO_ITCONTA;
      rDadosGuia.VL_FRANQUIA                    := r.VL_FRANQUIA;
      rDadosGuia.VL_TOTAL_FRANQUIA              := r.VL_TOTAL_FRANQUIA;
      rDadosGuia.TP_ORIGEM                      := r.TP_ORIGEM;
      rDadosGuia.CD_REPASSE_PRESTADOR           := r.CD_REPASSE_PRESTADOR;
      rDadosGuia.CD_ESPECIALIDADE               := r.CD_ESPECIALIDADE;
      rDadosGuia.CD_PTU_TIPO_VINCULO            := r.CD_PTU_TIPO_VINCULO;
      rDadosGuia.TP_ORIGEM_FATURA               := r.TP_ORIGEM_FATURA;
      rDadosGuia.NR_FATURA_REFERENCIA           := r.NR_FATURA_REFERENCIA;
      rDadosGuia.NR_LOTE_REFERENCIA             := r.NR_LOTE_REFERENCIA;
      rDadosGuia.NR_NOTA_REFERENCIA             := r.NR_NOTA_REFERENCIA;
      rDadosGuia.NR_GUIA_PRESTADOR_REFERENCIA   := r.NR_GUIA_PRESTADOR_REFERENCIA;
      rDadosGuia.CD_UNIMED_EXECUTORA            := r.CD_UNIMED_EXECUTORA;
      rDadosGuia.DS_FATURA                      := r.DS_FATURA;
      rDadosGuia.CD_CONTA_MEDICA_A520           := r.CD_CONTA_MEDICA_A520;
      rDadosGuia.SN_PACOTE                      := r.SN_PACOTE;
      rDadosGuia.CD_PROTOCOLO_CTAMED            := r.CD_PROTOCOLO_CTAMED;
      rDadosGuia.TP_FATURA                      := r.TP_FATURA;
      rDadosGuia.CD_CNPJ_CPF_EXEC               := r.CD_CNPJ_CPF_EXEC;
      rDadosGuia.CD_CNES_EXEC                   := r.CD_CNES_EXEC;
      rDadosGuia.CD_MUNICIPIO_EXEC              := r.CD_MUNICIPIO_EXEC;
      rDadosGuia.CD_PRESTADOR_PRINCIPAL         := r.CD_PRESTADOR_PRINCIPAL;
      rDadosGuia.CD_EXCECAO_PTU                 := r.CD_EXCECAO_PTU;
      rDadosGuia.DT_EXTORNO_A520                := r.DT_EXTORNO_A520;
    PIPE ROW(rDadosGuia);
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN NO_DATA_NEEDED THEN NULL;
    WHEN OTHERS THEN
      Raise_Application_Error(-20001, 'Erro na package Monitoramento Tiss (rDadosGuia): ' || SQLERRM || '. Detalhe: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  END;
  --TEMP_MONITORAMENTO
  FUNCTION GET_TABLE_TEMP_MONITORAMENTO(P_DT_COMPETENCIA IN DATE, P_CD_MULTI_EMPRESA IN NUMBER)
		RETURN TABLE_TEMP_MONITORAMENTO
		PIPELINED IS
    CURSOR cTempMonitoramento IS
      SELECT TP_REGISTRO,
             DT_COMPETENCIA,
             CD_MULTI_EMPRESA,
             DS_VERSAO_TISS_PRESTADOR,
             CD_CNES,
             TP_IDENTIFICADOR_EXECUTANTE,
             CD_CNPJ_CPF,
             CD_PRESTADOR,
             CD_MUNICIPIO_EXECUTANTE,
             NR_ANS_INTERMEDIARIO,
             CD_TIPO_ATENDIMENTO_INTERMED,
             NR_CARTAO_NACIONAL_SAUDE,
             TP_SEXO,
             DT_NASCIMENTO,
             DS_MUNICIPIO_RESIDENCIA,
             NR_REGISTRO_PLANO,
             TP_EVENTO_ATENCAO,
             TP_ORIGEM_EVENTO_ATENCAO,
             NR_GUIA_PRESTADOR,
             NR_GUIA_OPERADORA,
             CD_IDENTIFICACAO_REEMBOLSO,
             CD_IDENTIF_CT_VL_PRE_ESTAB,
             NR_GUIA_SOLICITACAO_INTERNACAO,
             DT_SOLICITACAO,
             NR_GUIA_TEM,
             DT_AUTORIZACAO,
             DT_REALIZACAO,
             DT_INICIAL_FATURAMENTO,
             DT_FIM_PERIODO,
             DT_PROTOCOLO_COBRANCA,
             DT_PAGAMENTO,
             TP_CONSULTA,
             CD_CBO_EXECUTANTE,
             SN_RECEM_NATO,
             TP_ACIDENTE,
             TP_CARATER_ATENDIMENTO,
             TP_INTERNACAO,
             TP_REGIME_INTERNACAO,
             CD_CID_1,
             CD_CID_2,
             CD_CID_3,
             CD_CID_4,
             TP_ATENDIMENTO,
             TP_FATURAMENTO,
             DS_MOTIVO_SAIDA,
             TP_TABELA,
             CD_GRUPO_PROCEDIMENTO,
             CD_PROCEDIMENTO,
             TP_DENTE,
             TP_REGIAO,
             DS_DENTE_FACE,
             trunc(QT_INFORMADA, 4) QT_INFORMADA,
             trunc(VL_INFORMADO, 2) VL_INFORMADO,
             Decode(trunc(VL_PAGO_PROC, 2), 0, 0, trunc(QT_PAGA, 4)) QT_PAGA ,
             --trunc(QT_PAGA, 4) QT_PAGA,
             trunc(VL_PAGO_PROC, 2) VL_PAGO_PROC,
             CD_CONTA_MEDICA,
             CD_LANCAMENTO,
             CD_LANCAMENTO_FILHO,
             TP_CONTA,
             trunc(VL_PAGO_FORNECEDOR, 2) VL_PAGO_FORNECEDOR,
             NR_CNPJ_FORNECEDOR,
             SN_PACOTE,
             TP_GRU_PRO,
             TP_NATUREZA,
             CD_MATRICULA,
             TP_GUIA,
             NR_GUIA,
             trunc(VL_TOTAL_PAGO, 2) VL_TOTAL_PAGO,
             trunc(VL_TOTAL_GLOSADO, 2) VL_TOTAL_GLOSADO,
             trunc(vl_total_cobrado, 2) vl_total_cobrado,
             CD_FATURA,
             NR_MES,
             NR_ANO,
             TP_SITUACAO_CONTA,
             TP_SITUACAO_ITCONTA,
             VL_TOTAL_FRANQUIA,
             VL_FRANQUIA,
             TP_FORMA_ENVIO,
             CD_REPASSE_PRESTADOR,
             CD_ESPECIALIDADE,
             CD_PTU_TIPO_VINCULO,
             TP_ORIGEM_FATURA,
             NR_FATURA_REFERENCIA,
             NR_LOTE_REFERENCIA,
             NR_NOTA_REFERENCIA,
             NR_GUIA_PRESTADOR_REFERENCIA,
             CD_UNIMED_EXECUTORA,
             DS_FATURA,
             CD_PROTOCOLO_CTAMED,
             TP_FATURA,
             CD_CNPJ_CPF_EXEC,
             CD_CNES_EXEC,
             CD_MUNICIPIO_EXEC,
             CD_PRESTADOR_PRINCIPAL,
             TP_LOTE_CONTA_MEDICA,
             CD_CONTA_MEDICA_A520,
             CD_EXCECAO_PTU,
             DT_EXTORNO_A520
        FROM DBAPS.TEMP_MONITORAMENTO_TISS
       WHERE DT_COMPETENCIA = P_DT_COMPETENCIA
         AND CD_MULTI_EMPRESA = P_CD_MULTI_EMPRESA
    ORDER BY NR_GUIA_PRESTADOR,
             NR_GUIA_OPERADORA,
             CD_PRESTADOR,
             CD_CONTA_MEDICA;
    rTempMonitoramento ROW_TEMP_MONITORAMENTO;
  BEGIN
    FOR r IN cTempMonitoramento LOOP
      rTempMonitoramento.TP_REGISTRO                    := r.TP_REGISTRO;
      rTempMonitoramento.DS_VERSAO_TISS_PRESTADOR       := r.DS_VERSAO_TISS_PRESTADOR;
      rTempMonitoramento.CD_CNES                        := r.CD_CNES;
      rTempMonitoramento.TP_IDENTIFICADOR_EXECUTANTE    := r.TP_IDENTIFICADOR_EXECUTANTE;
      rTempMonitoramento.CD_CNPJ_CPF                    := r.CD_CNPJ_CPF;
      rTempMonitoramento.CD_PRESTADOR                   := r.CD_PRESTADOR;
      rTempMonitoramento.CD_MUNICIPIO_EXECUTANTE        := r.CD_MUNICIPIO_EXECUTANTE;
      rTempMonitoramento.NR_ANS_INTERMEDIARIO           := r.NR_ANS_INTERMEDIARIO;
      rTempMonitoramento.CD_TIPO_ATENDIMENTO_INTERMED   := r.CD_TIPO_ATENDIMENTO_INTERMED;
      rTempMonitoramento.NR_CARTAO_NACIONAL_SAUDE       := r.NR_CARTAO_NACIONAL_SAUDE;
      rTempMonitoramento.TP_SEXO                        := r.TP_SEXO;
      rTempMonitoramento.DT_NASCIMENTO                  := r.DT_NASCIMENTO;
      rTempMonitoramento.DS_MUNICIPIO_RESIDENCIA        := r.DS_MUNICIPIO_RESIDENCIA;
      rTempMonitoramento.NR_REGISTRO_PLANO              := r.NR_REGISTRO_PLANO;
      rTempMonitoramento.TP_EVENTO_ATENCAO              := r.TP_EVENTO_ATENCAO;
      rTempMonitoramento.TP_ORIGEM_EVENTO_ATENCAO       := r.TP_ORIGEM_EVENTO_ATENCAO;
      rTempMonitoramento.NR_GUIA_PRESTADOR              := r.NR_GUIA_PRESTADOR;
      rTempMonitoramento.NR_GUIA_OPERADORA              := r.NR_GUIA_OPERADORA;
      rTempMonitoramento.CD_IDENTIFICACAO_REEMBOLSO     := r.CD_IDENTIFICACAO_REEMBOLSO;
      rTempMonitoramento.CD_IDENTIF_CT_VL_PRE_ESTAB     := r.CD_IDENTIF_CT_VL_PRE_ESTAB;
      rTempMonitoramento.NR_GUIA_SOLICITACAO_INTERNACAO := r.NR_GUIA_SOLICITACAO_INTERNACAO;
      rTempMonitoramento.DT_SOLICITACAO                 := r.DT_SOLICITACAO;
      rTempMonitoramento.NR_GUIA_TEM                    := r.NR_GUIA_TEM;
      rTempMonitoramento.DT_AUTORIZACAO                 := r.DT_AUTORIZACAO;
      rTempMonitoramento.DT_REALIZACAO                  := r.DT_REALIZACAO;
      rTempMonitoramento.DT_INICIAL_FATURAMENTO         := r.DT_INICIAL_FATURAMENTO;
      rTempMonitoramento.DT_FIM_PERIODO                 := r.DT_FIM_PERIODO;
      rTempMonitoramento.DT_PROTOCOLO_COBRANCA          := r.DT_PROTOCOLO_COBRANCA;
      rTempMonitoramento.DT_PAGAMENTO                   := r.DT_PAGAMENTO;
      rTempMonitoramento.TP_CONSULTA                    := r.TP_CONSULTA;
      rTempMonitoramento.CD_CBO_EXECUTANTE              := r.CD_CBO_EXECUTANTE;
      rTempMonitoramento.SN_RECEM_NATO                  := r.SN_RECEM_NATO;
      rTempMonitoramento.TP_ACIDENTE                    := r.TP_ACIDENTE;
      rTempMonitoramento.TP_CARATER_ATENDIMENTO         := r.TP_CARATER_ATENDIMENTO;
      rTempMonitoramento.TP_INTERNACAO                  := r.TP_INTERNACAO;
      rTempMonitoramento.TP_REGIME_INTERNACAO           := r.TP_REGIME_INTERNACAO;
      rTempMonitoramento.CD_CID_1                       := r.CD_CID_1;
      rTempMonitoramento.CD_CID_2                       := r.CD_CID_2;
      rTempMonitoramento.CD_CID_3                       := r.CD_CID_3;
      rTempMonitoramento.CD_CID_4                       := r.CD_CID_4;
      rTempMonitoramento.TP_ATENDIMENTO                 := r.TP_ATENDIMENTO;
      rTempMonitoramento.TP_FATURAMENTO                 := r.TP_FATURAMENTO;
      rTempMonitoramento.DS_MOTIVO_SAIDA                := r.DS_MOTIVO_SAIDA;
      rTempMonitoramento.TP_TABELA                      := r.TP_TABELA;
      rTempMonitoramento.CD_GRUPO_PROCEDIMENTO          := r.CD_GRUPO_PROCEDIMENTO;
      rTempMonitoramento.CD_PROCEDIMENTO                := r.CD_PROCEDIMENTO;
      rTempMonitoramento.TP_DENTE                       := r.TP_DENTE;
      rTempMonitoramento.TP_REGIAO                      := r.TP_REGIAO;
      rTempMonitoramento.DS_DENTE_FACE                  := r.DS_DENTE_FACE;
      rTempMonitoramento.QT_INFORMADA                   := r.QT_INFORMADA;
      rTempMonitoramento.VL_INFORMADO                   := r.VL_INFORMADO;
      rTempMonitoramento.QT_PAGA                        := r.QT_PAGA;
      rTempMonitoramento.VL_PAGO_PROC                   := r.VL_PAGO_PROC;
      rTempMonitoramento.CD_CONTA_MEDICA                := r.CD_CONTA_MEDICA;
      rTempMonitoramento.CD_LANCAMENTO                  := r.CD_LANCAMENTO;
      rTempMonitoramento.CD_LANCAMENTO_FILHO            := r.CD_LANCAMENTO_FILHO;
      rTempMonitoramento.TP_CONTA                       := r.TP_CONTA;
      rTempMonitoramento.VL_PAGO_FORNECEDOR             := r.VL_PAGO_FORNECEDOR;
      rTempMonitoramento.NR_CNPJ_FORNECEDOR             := r.NR_CNPJ_FORNECEDOR;
      rTempMonitoramento.TP_GRU_PRO                     := r.TP_GRU_PRO;
      rTempMonitoramento.TP_NATUREZA                    := r.TP_NATUREZA;
      rTempMonitoramento.CD_MATRICULA                   := r.CD_MATRICULA;
      rTempMonitoramento.TP_GUIA                        := r.TP_GUIA;
      rTempMonitoramento.NR_GUIA                        := r.NR_GUIA;
      rTempMonitoramento.VL_TOTAL_COBRADO               := r.VL_TOTAL_COBRADO;
      rTempMonitoramento.VL_TOTAL_PAGO                  := r.VL_TOTAL_PAGO;
      rTempMonitoramento.VL_TOTAL_GLOSADO               := r.VL_TOTAL_GLOSADO;
      rTempMonitoramento.CD_FATURA                      := r.CD_FATURA;
      rTempMonitoramento.NR_MES                         := r.NR_MES;
      rTempMonitoramento.NR_ANO                         := r.NR_ANO;
      rTempMonitoramento.TP_SITUACAO_CONTA              := r.TP_SITUACAO_CONTA;
      rTempMonitoramento.TP_SITUACAO_ITCONTA            := r.TP_SITUACAO_ITCONTA;
      rTempMonitoramento.VL_FRANQUIA                    := r.VL_FRANQUIA;
      rTempMonitoramento.VL_TOTAL_FRANQUIA              := r.VL_TOTAL_FRANQUIA;
      rTempMonitoramento.TP_FORMA_ENVIO                 := r.TP_FORMA_ENVIO;
      rTempMonitoramento.SN_PACOTE                      := r.SN_PACOTE;
      rTempMonitoramento.CD_REPASSE_PRESTADOR           := r.CD_REPASSE_PRESTADOR;
      rTempMonitoramento.CD_ESPECIALIDADE               := r.CD_ESPECIALIDADE;
      rTempMonitoramento.CD_PTU_TIPO_VINCULO            := r.CD_PTU_TIPO_VINCULO;
      rTempMonitoramento.TP_ORIGEM_FATURA               := r.TP_ORIGEM_FATURA;
      rTempMonitoramento.NR_FATURA_REFERENCIA           := r.NR_FATURA_REFERENCIA;
      rTempMonitoramento.NR_LOTE_REFERENCIA             := r.NR_LOTE_REFERENCIA;
      rTempMonitoramento.NR_NOTA_REFERENCIA             := r.NR_NOTA_REFERENCIA;
      rTempMonitoramento.NR_GUIA_PRESTADOR_REFERENCIA   := r.NR_GUIA_PRESTADOR_REFERENCIA;
      rTempMonitoramento.CD_UNIMED_EXECUTORA            := r.CD_UNIMED_EXECUTORA;
      rTempMonitoramento.DS_FATURA                      := r.DS_FATURA;
      rTempMonitoramento.CD_PROTOCOLO_CTAMED            := r.CD_PROTOCOLO_CTAMED;
      rTempMonitoramento.TP_FATURA                      := r.TP_FATURA;
      rTempMonitoramento.CD_CNPJ_CPF_EXEC               := r.CD_CNPJ_CPF_EXEC;
      rTempMonitoramento.CD_CNES_EXEC                   := r.CD_CNES_EXEC;
      rTempMonitoramento.CD_MUNICIPIO_EXEC              := r.CD_MUNICIPIO_EXEC;
      rTempMonitoramento.CD_PRESTADOR_PRINCIPAL         := r.CD_PRESTADOR_PRINCIPAL;
      rTempMonitoramento.CD_CONTA_MEDICA_A520           := r.CD_CONTA_MEDICA_A520;
      rTempMonitoramento.CD_MULTI_EMPRESA               := r.CD_MULTI_EMPRESA;
      rTempMonitoramento.CD_EXCECAO_PTU                 := r.CD_EXCECAO_PTU;
      rTempMonitoramento.DT_EXTORNO_A520                 := r.DT_EXTORNO_A520;
    PIPE ROW(rTempMonitoramento);
    END LOOP;
    RETURN;
  END;
  --REEMBOLSO
  FUNCTION GET_TABLE_REEMBOLSO(P_DT_COMPETENCIA IN DATE, P_CD_MULTI_EMPRESA IN NUMBER, P_CD_MONITORAMENTO_TISS IN NUMBER)
		RETURN TABLE_REEMBOLSO
		PIPELINED IS
    CURSOR cReembolso IS
      SELECT CD_REEMBOLSO,
             Trim(Nvl(p.cd_cnes, '9999999')) CD_CNES
             ,
             Decode(p.tp_prestador, NULL, Decode(r.tp_pessoa, 'F', 2, 1), decode(p.tp_prestador, 'F', 2, 1)) TP_IDENTIFICADOR_EXECUTANTE
             ,
             Nvl(p.nr_cpf_cgc, r.nr_cpf_cnpj) CD_CNPJ_CPF
             ,
             Nvl(SubStr(R.CD_MUNICIPIO, 0, 6), '000000') CD_MUNICIPIO_EXECUTANTE
             ,
             NULL NR_ANS_INTERMEDIARIO
             ,
             NULL CD_TIPO_ATENDIMENTO_INTERMED
             ,
             regexp_replace(u.nr_cns, '[^[:digit:]]+') AS NR_CARTAO_NACIONAL_SAUDE --Cart?o Nacional de Saude
             ,
             decode(u.tp_sexo, 'M', '1', 'F', '3') tp_sexo --Sexo do beneficiario, conforme tabela de dominio vigente na vers?o que a guia foi enviada (vers?o da tiss - tabela de dominio)
             ,
             u.dt_nascimento DT_NASCIMENTO --Data de nascimento do beneficiario (YYYY-MM-DD)
             ,
             Nvl(SubStr(U.CD_CIDADE, 0, 6), '000000') DS_MUNICIPIO_RESIDENCIA --Municipio de residencia do beneficiario (IBGE)
             ,
             Nvl(Decode(PLA.SN_REGISTRADO_ANS, 'S', Nvl(To_Char(PLA.CD_REGISTRO_MS), SubStr(pla.CD_PLANO_OPERADORA, 1, 20)), DECODE(pla.TP_PERIODO_IMPLANTACAO, 1, SubStr(pla.CD_PLANO_OPERADORA, 1, 20), 2, pla.CD_REGISTRO_MS)), '000000') AS NR_REGISTRO_PLANO --Numero de identificac?o do plano do beneficiario na ANS (RPS / SCPA)
             ,
             NULL CD_IDENTIF_CT_VL_PRE_ESTAB
             ,
             decode(ta.tp_guia, 'C', '1', 'S', '2', 'I', '3', 'D', '4', 'X', '2', 'H', '5', 2) AS TP_EVENTO_ATENCAO --Tipo de guia
             ,
             4 AS TP_ORIGEM_EVENTO_ATENCAO --Origem da guia (1 - Rede Contratada referenciada ou credenciada, 2 - Rede Propria - Cooperados, 3 - Rede Propria - Demais, prestadores, 4 - Reembolso ao beneficiario)
             ,
             trunc(r.dt_inclusao) DT_SOLICITACAO
             ,
             NULL NR_GUIA_TEM
             ,
             trunc(r.dt_inclusao) DT_AUTORIZACAO
             ,
             nvl(r.dt_atendimento, r.dt_inclusao) DT_REALIZACAO
             ,
             DECODE(ta.tp_guia, 'I', nvl(r.dt_atendimento, r.dt_inclusao)) DT_INICIAL_FATURAMENTO
             ,
             DECODE(ta.tp_guia, 'I', r.dt_ALTA) DT_FIM_PERIODO
             ,
             trunc(r.dt_inclusao) DT_PROTOCOLO_COBRANCA
             ,
             (SELECT pagcon_pag.dt_pagamento
                 FROM dbamv.itcon_pag,
                     dbamv.pagcon_pag
               WHERE itcon_pag.cd_itcon_pag = pagcon_pag.cd_itcon_pag
                 AND itcon_pag.cd_con_pag = r.cd_con_pag
                 AND ROWNUM = 1) DT_PAGAMENTO
             ,
             Decode(r.cd_especialidade, NULL, Decode(ta.tp_guia, 'C', '225125', '999999'), dbaps.fnc_retorna_cbos(r.cd_especialidade, 'N', 'S')) CD_CBO_EXECUTANTE --Codigo na Classificac?o Brasileira de Ocupac?es (CBO) do executante (vers?o da tiss - tabela de dominio)
             ,
             r.sn_recusado
             ,
             r.cd_prestador
             ,
             r.cd_matricula
             ,
             r.cd_especialidade
        FROM dbaps.reembolso          r,
             dbaps.usuario            u,
             dbaps.plano              pla,
             dbaps.prestador          p,
             dbaps.tipo_atendimento   ta
       WHERE r.cd_matricula = u.cd_matricula
         AND u.cd_plano = pla.cd_plano
         AND r.cd_prestador = p.cd_prestador (+)
         AND r.CD_TIPO_ATENDIMENTO = ta.cd_tipo_atendimento
         AND r.cd_multi_empresa = P_CD_MULTI_EMPRESA
         AND pla.sn_monitoramento_tiss = 'S'
         AND NOT EXISTS (
           SELECT 1 FROM DBAPS.TIPO_REEMBOLSO
           WHERE cd_tipo_reembolso = r.cd_tipo_reembolso
            AND sn_envio_monit_tiss = 'N'
         )
         AND (P_CD_MONITORAMENTO_TISS IS NULL OR r.CD_REEMBOLSO IN (SELECT CD_REEMBOLSO
                                                                      FROM DBAPS.MONIT_TISS_GUIA
                                                                     WHERE CD_MONITORAMENTO_TISS = P_CD_MONITORAMENTO_TISS
                                                                       AND SN_INCONSISTENCIA = 'S'
                                                                       AND TP_REGISTRO = '1'
                                                                       AND CD_REEMBOLSO IS NOT NULL))
         AND TO_CHAR(r.dt_inclusao, 'YYYYMM') = TO_CHAR(P_DT_COMPETENCIA, 'YYYYMM');
    rReembolso ROW_REEMBOLSO;
  BEGIN
    FOR r IN cReembolso LOOP
      rReembolso.CD_REEMBOLSO                 := r.CD_REEMBOLSO;
      rReembolso.CD_CNES                      := r.CD_CNES;
      rReembolso.TP_IDENTIFICADOR_EXECUTANTE  := r.TP_IDENTIFICADOR_EXECUTANTE;
      rReembolso.CD_CNPJ_CPF                  := r.CD_CNPJ_CPF;
      rReembolso.CD_PRESTADOR                 := r.CD_PRESTADOR;
      rReembolso.CD_MUNICIPIO_EXECUTANTE      := r.CD_MUNICIPIO_EXECUTANTE;
      rReembolso.NR_ANS_INTERMEDIARIO         := r.NR_ANS_INTERMEDIARIO;
      rReembolso.CD_TIPO_ATENDIMENTO_INTERMED := r.CD_TIPO_ATENDIMENTO_INTERMED;
      rReembolso.NR_CARTAO_NACIONAL_SAUDE     := r.NR_CARTAO_NACIONAL_SAUDE;
      rReembolso.TP_SEXO                      := r.TP_SEXO;
      rReembolso.DT_NASCIMENTO                := r.DT_NASCIMENTO;
      rReembolso.DS_MUNICIPIO_RESIDENCIA      := r.DS_MUNICIPIO_RESIDENCIA;
      rReembolso.NR_REGISTRO_PLANO            := r.NR_REGISTRO_PLANO;
      rReembolso.TP_EVENTO_ATENCAO            := r.TP_EVENTO_ATENCAO;
      rReembolso.TP_ORIGEM_EVENTO_ATENCAO     := r.TP_ORIGEM_EVENTO_ATENCAO;
      rReembolso.CD_IDENTIF_CT_VL_PRE_ESTAB   := r.CD_IDENTIF_CT_VL_PRE_ESTAB;
      rReembolso.DT_SOLICITACAO               := r.DT_SOLICITACAO;
      rReembolso.NR_GUIA_TEM                  := r.NR_GUIA_TEM;
      rReembolso.DT_AUTORIZACAO               := r.DT_AUTORIZACAO;
      rReembolso.DT_REALIZACAO                := r.DT_REALIZACAO;
      rReembolso.DT_INICIAL_FATURAMENTO       := r.DT_INICIAL_FATURAMENTO;
      rReembolso.DT_PROTOCOLO_COBRANCA        := r.DT_PROTOCOLO_COBRANCA;
      rReembolso.DT_PAGAMENTO                 := r.DT_PAGAMENTO;
      rReembolso.CD_CBO_EXECUTANTE            := r.CD_CBO_EXECUTANTE;
      rReembolso.CD_MATRICULA                 := r.CD_MATRICULA;
      rReembolso.CD_ESPECIALIDADE             := r.CD_ESPECIALIDADE;
      rReembolso.SN_RECUSADO                  := r.SN_RECUSADO;
      rReembolso.DT_FIM_PERIODO               := r.DT_FIM_PERIODO;
    PIPE ROW(rReembolso);
    END LOOP;
    RETURN;
  END;
  --IT_REEMBOLSO
  FUNCTION GET_TABLE_IT_REEMBOLSO(P_CD_REEMBOLSO IN NUMBER)
		RETURN TABLE_IT_REEMBOLSO
		PIPELINED IS
    CURSOR cItReembolso IS
      SELECT Decode(p.cd_procedimento,
                    NULL,
                    '00', -- procedimento n existe e 00
                    Decode(p.sn_pacote, 'S', '98', dbaps.fnc_tabela_tuss(Nvl(p.cd_procedimento_tuss, itr.cd_procedimento)))) TP_TABELA --Tabela TUSS do procedimento
             ,
             DBAPS.FNC_GRUPO_PROCED_TUSS(Nvl(p.cd_procedimento_tuss, itr.cd_procedimento), gp.tp_gru_pro) CD_GRUPO_PROCEDIMENTO--Codigo do grupo do procedimento ou item assistencial
             ,
             Nvl(p.cd_procedimento_tuss, itr.cd_procedimento) CD_PROCEDIMENTO --Codigo do procedimento realizado ou item assistencial utilizado
             ,
             '' AS TP_DENTE --Identificac?o do dente
             ,
             '' AS TP_REGIAO --Identificac?o da regi?o da boca
             ,
             '' AS DS_DENTE_FACE --Identificac?o da face do dente
             ,
             trunc(itr.qt_cobrado, 4) QT_INFORMADA --Quantidade informada de procedimentos ou itens assistenciais
             ,
             trunc(itr.vl_cobrado, 2) VL_INFORMADO --Valor informado de procedimentos ou itens assistenciais
             ,
             Decode(itr.vl_procedimento, 0, 0, trunc(itr.qt_cobrado, 4)) QT_PAGA --Quantidade paga de procedimentos ou itens assistenciais
             ,
             trunc(itr.vl_procedimento, 2) VL_PAGO_PROC --Valor pago ao prestador executante ou reembolsado ao beneficiario.
             ,
             0 AS vl_pago_fornecedor --Valor pago diretamente ao fornecedor
             ,
             NULL AS NR_CNPJ_FORNECEDOR --Numero de cadastro do fornecedor na Receita Federal
             ,
             p.SN_PACOTE --Procedimento e um pacote
             ,
             gp.tp_gru_pro
             ,
             p.TP_NATUREZA
        FROM DBAPS.ITREEMBOLSO        itr,
             DBAPS.PROCEDIMENTO       P,
             DBAPS.GRUPO_PROCEDIMENTO gp
       WHERE itr.CD_REEMBOLSO = P_CD_REEMBOLSO
         AND itr.CD_PROCEDIMENTO = P.CD_PROCEDIMENTO(+)
         AND P.CD_GRUPO_PROCEDIMENTO = gp.CD_GRUPO_PROCEDIMENTO(+)
         AND itr.VL_COBRADO > 0 ;
    rItReembolso ROW_IT_REEMBOLSO;
  BEGIN
    FOR r IN cItReembolso LOOP
      rItReembolso.TP_TABELA             := r.TP_TABELA;
      rItReembolso.CD_GRUPO_PROCEDIMENTO := r.CD_GRUPO_PROCEDIMENTO;
      rItReembolso.CD_PROCEDIMENTO       := r.CD_PROCEDIMENTO;
      rItReembolso.TP_DENTE              := r.TP_DENTE;
      rItReembolso.TP_REGIAO             := r.TP_REGIAO;
      rItReembolso.DS_DENTE_FACE         := r.DS_DENTE_FACE;
      rItReembolso.QT_INFORMADA          := r.QT_INFORMADA;
      rItReembolso.VL_INFORMADO          := r.VL_INFORMADO;
      rItReembolso.QT_PAGA               := r.QT_PAGA;
      rItReembolso.VL_PAGO_PROC          := r.VL_PAGO_PROC;
      rItReembolso.VL_PAGO_FORNECEDOR    := r.VL_PAGO_FORNECEDOR;
      rItReembolso.NR_CNPJ_FORNECEDOR    := r.NR_CNPJ_FORNECEDOR;
      rItReembolso.SN_PACOTE             := r.SN_PACOTE;
      rItReembolso.TP_GRU_PRO            := r.TP_GRU_PRO;
      rItReembolso.TP_NATUREZA           := r.TP_NATUREZA;
    PIPE ROW(rItReembolso);
    END LOOP;
    RETURN;
  END;
  --MONIT_TISS_GUIA
  FUNCTION GET_TABLE_MONIT_TISS_GUIA(P_CD_MONITORAMENTO_TISS IN NUMBER, P_CD_MONIT_TISS_GUIA IN NUMBER DEFAULT NULL)
		RETURN TABLE_MONIT_TISS_GUIA
		PIPELINED IS
    CURSOR cMonitTissGuia IS
      SELECT *
        FROM DBAPS.MONIT_TISS_GUIA
       WHERE CD_MONITORAMENTO_TISS = P_CD_MONITORAMENTO_TISS
         AND CD_MONIT_TISS_GUIA = Nvl(P_CD_MONIT_TISS_GUIA, CD_MONIT_TISS_GUIA);
    rMonitTissGuia ROW_MONIT_TISS_GUIA;
  BEGIN
    FOR r IN cMonitTissGuia LOOP
    rMonitTissGuia.CD_MONIT_TISS_GUIA             := r.CD_MONIT_TISS_GUIA;
    rMonitTissGuia.CD_MONITORAMENTO_TISS          := r.CD_MONITORAMENTO_TISS;
    rMonitTissGuia.TP_REGISTRO                    := r.TP_REGISTRO;
    rMonitTissGuia.DS_VERSAO_TISS_PRESTADOR       := r.DS_VERSAO_TISS_PRESTADOR;
    rMonitTissGuia.CD_CNES                        := r.CD_CNES;
    rMonitTissGuia.TP_IDENTIFICADOR_EXECUTANTE    := r.TP_IDENTIFICADOR_EXECUTANTE;
    rMonitTissGuia.CD_CNPJ_CPF                    := r.CD_CNPJ_CPF;
    rMonitTissGuia.CD_MUNICIPIO_EXECUTANTE        := r.CD_MUNICIPIO_EXECUTANTE;
    rMonitTissGuia.NR_CARTAO_NACIONAL_SAUDE       := r.NR_CARTAO_NACIONAL_SAUDE;
    rMonitTissGuia.TP_SEXO                        := r.TP_SEXO;
    rMonitTissGuia.DT_NASCIMENTO                  := r.DT_NASCIMENTO;
    rMonitTissGuia.DS_MUNICIPIO_RESIDENCIA        := r.DS_MUNICIPIO_RESIDENCIA;
    rMonitTissGuia.NR_REGISTRO_PLANO              := r.NR_REGISTRO_PLANO;
    rMonitTissGuia.TP_EVENTO_ATENCAO              := r.TP_EVENTO_ATENCAO;
    rMonitTissGuia.TP_ORIGEM_EVENTO_ATENCAO       := r.TP_ORIGEM_EVENTO_ATENCAO;
    rMonitTissGuia.NR_GUIA_PRESTADOR              := r.NR_GUIA_PRESTADOR;
    rMonitTissGuia.NR_GUIA_OPERADORA              := r.NR_GUIA_OPERADORA;
    rMonitTissGuia.CD_IDENTIFICACAO_REEMBOLSO     := r.CD_IDENTIFICACAO_REEMBOLSO;
    rMonitTissGuia.NR_GUIA_SOLICITACAO_INTERNACAO := r.NR_GUIA_SOLICITACAO_INTERNACAO;
    rMonitTissGuia.DT_SOLICITACAO                 := r.DT_SOLICITACAO;
    rMonitTissGuia.DT_AUTORIZACAO                 := r.DT_AUTORIZACAO;
    rMonitTissGuia.DT_REALIZACAO                  := r.DT_REALIZACAO;
    rMonitTissGuia.DT_INICIAL_FATURAMENTO         := r.DT_INICIAL_FATURAMENTO;
    rMonitTissGuia.DT_FIM_PERIODO                 := r.DT_FIM_PERIODO;
    rMonitTissGuia.DT_PROTOCOLO_COBRANCA          := r.DT_PROTOCOLO_COBRANCA;
    rMonitTissGuia.DT_PAGAMENTO                   := r.DT_PAGAMENTO;
    rMonitTissGuia.DT_PROCESSAMENTO_GUIA          := r.DT_PROCESSAMENTO_GUIA;
    rMonitTissGuia.TP_CONSULTA                    := r.TP_CONSULTA;
    rMonitTissGuia.CD_CBO_EXECUTANTE              := r.CD_CBO_EXECUTANTE;
    rMonitTissGuia.SN_RECEM_NATO                  := r.SN_RECEM_NATO;
    rMonitTissGuia.TP_ACIDENTE                    := r.TP_ACIDENTE;
    rMonitTissGuia.TP_CARATER_ATENDIMENTO         := r.TP_CARATER_ATENDIMENTO;
    rMonitTissGuia.TP_INTERNACAO                  := r.TP_INTERNACAO;
    rMonitTissGuia.TP_REGIME_INTERNACAO           := r.TP_REGIME_INTERNACAO;
    rMonitTissGuia.CD_CID_1                       := r.CD_CID_1;
    rMonitTissGuia.CD_CID_2                       := r.CD_CID_2;
    rMonitTissGuia.CD_CID_3                       := r.CD_CID_3;
    rMonitTissGuia.CD_CID_4                       := r.CD_CID_4;
    rMonitTissGuia.TP_ATENDIMENTO                 := r.TP_ATENDIMENTO;
    rMonitTissGuia.TP_FATURAMENTO                 := r.TP_FATURAMENTO;
    rMonitTissGuia.NR_DIARIAS_ACOMPANHANTE        := r.NR_DIARIAS_ACOMPANHANTE;
    rMonitTissGuia.NR_DIARIAS_UTI                 := r.NR_DIARIAS_UTI;
    rMonitTissGuia.DS_MOTIVO_SAIDA                := r.DS_MOTIVO_SAIDA;
    rMonitTissGuia.VL_TOTAL_INFORMADO             := r.VL_TOTAL_INFORMADO;
    rMonitTissGuia.VL_PROCESSADO                  := r.VL_PROCESSADO;
    rMonitTissGuia.VL_TOTAL_PAGO_PROCEDIMENTO     := r.VL_TOTAL_PAGO_PROCEDIMENTO;
    rMonitTissGuia.VL_TOTAL_DIARIA                := r.VL_TOTAL_DIARIA;
    rMonitTissGuia.VL_TOTAL_TAXA                  := r.VL_TOTAL_TAXA;
    rMonitTissGuia.VL_TOTAL_MATERIAL              := r.VL_TOTAL_MATERIAL;
    rMonitTissGuia.VL_TOTAL_OPME                  := r.VL_TOTAL_OPME;
    rMonitTissGuia.VL_TOTAL_MEDICAMENTO           := r.VL_TOTAL_MEDICAMENTO;
    rMonitTissGuia.VL_GLOSA_GUIA                  := r.VL_GLOSA_GUIA;
    rMonitTissGuia.VL_PAGO_GUIA                   := r.VL_PAGO_GUIA;
    rMonitTissGuia.VL_PAGO_FORNECEDOR             := r.VL_PAGO_FORNECEDOR;
    rMonitTissGuia.VL_TOTAL_TABELA_PROPRIA        := r.VL_TOTAL_TABELA_PROPRIA;
    rMonitTissGuia.SN_ENVIAR                      := r.SN_ENVIAR;
    rMonitTissGuia.NR_SEQUENCIAL                  := r.NR_SEQUENCIAL;
    rMonitTissGuia.CD_REEMBOLSO                   := r.CD_REEMBOLSO;
    rMonitTissGuia.SN_INCONSISTENCIA              := r.SN_INCONSISTENCIA;
    rMonitTissGuia.SN_ALTERADO                    := r.SN_ALTERADO;
    rMonitTissGuia.CD_CONTA_MEDICA                := r.CD_CONTA_MEDICA;
    rMonitTissGuia.CD_LANCAMENTO                  := r.CD_LANCAMENTO;
    rMonitTissGuia.CD_LANCAMENTO_FILHO            := r.CD_LANCAMENTO_FILHO;
    rMonitTissGuia.TP_CONTA                       := r.TP_CONTA;
    rMonitTissGuia.TP_SITUACAO                    := r.TP_SITUACAO;
    rMonitTissGuia.VL_TOTAL_FRANQUIA              := r.VL_TOTAL_FRANQUIA;
    rMonitTissGuia.TP_FORMA_ENVIO                 := r.TP_FORMA_ENVIO;
    rMonitTissGuia.BKP_VL_TOTAL_DIARIA            := r.BKP_VL_TOTAL_DIARIA;
    rMonitTissGuia.NR_ANS_INTERMEDIARIO           := r.NR_ANS_INTERMEDIARIO;
    rMonitTissGuia.CD_TIPO_ATENDIMENTO_INTERMED   := r.CD_TIPO_ATENDIMENTO_INTERMED;
    rMonitTissGuia.NR_GUIA_TEM                    := r.NR_GUIA_TEM;
    rMonitTissGuia.CD_IDENTIF_CT_VL_PRE_ESTAB     := r.CD_IDENTIF_CT_VL_PRE_ESTAB;
    rMonitTissGuia.CD_PRESTADOR                   := r.CD_PRESTADOR;
    rMonitTissGuia.CD_ESPECIALIDADE               := r.CD_ESPECIALIDADE;
    rMonitTissGuia.CD_MATRICULA                   := r.CD_MATRICULA;
    PIPE ROW(rMonitTissGuia);
    END LOOP;
    RETURN;
  END;
  --MONIT_TISS_GUIA_EXCLUSAO
  FUNCTION GET_TABLE_MONIT_TISS_EXCL_CM(P_CD_MONITORAMENTO_TISS IN NUMBER,
                                        P_CD_MULTI_EMPRESA IN NUMBER)
		RETURN TABLE_MONIT_TISS_EXCL_CM
		PIPELINED IS
    CURSOR cMonitTissGuiaExclusao IS
      SELECT *
        FROM DBAPS.MONIT_TISS_EXCL_CONTA_MEDICA T
       WHERE CD_MULTI_EMPRESA = P_CD_MULTI_EMPRESA
         AND (CD_MONITORAMENTO_TISS IS NULL
             OR CD_MONITORAMENTO_TISS = P_CD_MONITORAMENTO_TISS);
    rMonitTissGuiaExclusao ROW_MONIT_TISS_EXCL_CM;
  BEGIN
    FOR r IN cMonitTissGuiaExclusao LOOP
    rMonitTissGuiaExclusao.CD_CONTA_MEDICA  := r.CD_CONTA_MEDICA;
    rMonitTissGuiaExclusao.TP_CONTA         := r.TP_CONTA;
    rMonitTissGuiaExclusao.CD_FATURA        := r.CD_FATURA;
    rMonitTissGuiaExclusao.CD_LOTE          := r.CD_LOTE;
    rMonitTissGuiaExclusao.DT_COMPETENCIA   := r.DT_COMPETENCIA;
    rMonitTissGuiaExclusao.SN_A520          := r.SN_A520;
    rMonitTissGuiaExclusao.CD_MULTI_EMPRESA := r.CD_MULTI_EMPRESA;
    rMonitTissGuiaExclusao.CD_MONIT_TISS_GUIA := r.CD_MONIT_TISS_GUIA;
    rMonitTissGuiaExclusao.CD_MONITORAMENTO_TISS := r.CD_MONITORAMENTO_TISS;
    PIPE ROW(rMonitTissGuiaExclusao);
    END LOOP;
    RETURN;
  END;
END;
/

GRANT EXECUTE ON dbaps.pkg_monitoramento_tiss TO dbamv
/
GRANT EXECUTE ON dbaps.pkg_monitoramento_tiss TO dbasgu
/
GRANT EXECUTE ON dbaps.pkg_monitoramento_tiss TO mv2000
/
GRANT EXECUTE ON dbaps.pkg_monitoramento_tiss TO mvintegra
/
