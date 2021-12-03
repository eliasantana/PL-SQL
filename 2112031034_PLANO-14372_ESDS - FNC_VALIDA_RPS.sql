--<DS_SCRIPT>
-- DESCRIÇÃO..: Adicionando dados do prestador eventual
-- RESPONSAVEL: Elias Santana
-- DATA.......: 03/12/2021
-- APLICAÇÃO..: MVSAUDE V.155 PLANO-14372
--</DS_SCRIPT>
CREATE OR REPLACE FUNCTION dbaps.fnc_valida_rps(P_CD_LOTE IN NUMBER, P_TP_MVTO_CADASTRAL IN VARCHAR2) RETURN VARCHAR2 IS

  /**************************************************************
    <objeto>
     <nome>prc_valida_rps</nome>
     <usuario>ELIAS SANTANA</usuario>
     <alteracao>03/12/2021 10:36</alteracao>
     <descricao>procedure responsavel por validar os campos do processo da ans do rps</descricao>
     <alteracao>
          - Adicionando dados do prestador eventual aos cursores cRpsAnsIncAlt e cRpsAnsExc
     </alteracao>
     <parametro> P_CD_LOTE IN NUMBER,
                 P_TP_MVTO_CADASTRAL IN VARCHAR2 </parametro>
	   <tags></tags>
     <versao>1.4</versao>
    </objeto>
  ***************************************************************/

  /*******************************************************************************************************************
  ** CURSOR cExisteLote - Ao processar a critia, se houver um mesmo lote e movimento, deletar o registro anterior.
  *******************************************************************************************************************/
  CURSOR  cExisteLote IS
    SELECT 1 LOTE
      FROM DBAPS.RPS_CABECALHO_ERRO
     WHERE NR_LOTE = P_CD_LOTE
       AND   TP_MVTO_CADASTRAL = P_TP_MVTO_CADASTRAL;

  /*******************************************************************************************************************
  ** CURSOR cRpsAnsIncAlt -  DO RPS.
  *******************************************************************************************************************/
  CURSOR cCabecalhoRps IS
   SELECT NR_ANS REGISTRO_ANS,
          NR_CGC_ANS CNPJ_OPERADORA,
          NVL(SN_ISENCAO_ONUS_RPS, 'N') SN_ISENCAO_ONUS_RPS,
          NULL NOSSO_NUMERO
     FROM DBAMV.MULTI_EMPRESAS_MV_SAUDE
    WHERE CD_MULTI_EMPRESA = DBAMV.PKG_MV2000.LE_EMPRESA;

  /*******************************************************************************************************************
  ** CURSOR cRpsAnsIncAlt - OBTER OS PRESTADORES INCLUIDOS OU ALTERADOS(VERIFIQUE O PARAMETRO MVTO CADASTRAL) DO RPS.
  *******************************************************************************************************************/
  CURSOR cRpsAnsIncAlt IS
    SELECT P.CD_PRESTADOR				                                                    CD_PRESTADOR,
		       MVS.SN_ISENCAO_ONUS_RPS                                                  SN_ISENCAO_ONUS_RPS,
		       NVL(P.CD_CLASSIFICACAO, 3)                                               CD_CLASSIFICACAO,
		       NVL(P.NR_CPF_CGC, P.NR_CPF_CGC)                                          NR_CPF_CGC,
		       Nvl(P.CD_CNES, PE.CD_CNES)                                               CD_CNES,
		       PE.CD_UF                                                                 CD_UF,
		       PE.CD_MUNICIPIO                                                          CD_MUNICIPIO,
		       P.NM_PRESTADOR                                                           NM_PRESTADOR,
		       P.TP_CREDENCIAMENTO                                                      TP_CREDENCIAMENTO,
		       DECODE(P.TP_CREDENCIAMENTO, 'C', NVL(P.TP_CONTRATUALIZACAO,null), null)  TP_CONTRATUALIZACAO,
			     --NVL(DECODE(P.TP_CREDENCIAMENTO, 'P', '1', TO_CHAR(P.DT_CADASTRO,'DD/MM/YYYY')),NULL)   DT_CONTRATUALIZACAO,
           CASE WHEN P.TP_CREDENCIAMENTO = 'P'
                     OR ( P.DT_CADASTRO > To_Date('07/07/2003','DD/MM/YYYY') AND P.CD_CLASSIFICACAO = 1 )
                     OR ( P.DT_CADASTRO > To_Date('01/12/2003','DD/MM/YYYY') AND  P.CD_CLASSIFICACAO = 2)
                     OR P.CD_CLASSIFICACAO = 3 THEN
            NULL
           END                                                                      DT_CONTRATUALIZACAO,
			     NVL(TO_CHAR(P.DT_CADASTRO,  'DD/MM/YYYY'), NULL)                                       DT_CADASTRO,
			     P.TP_DISPONIBILIDADE                                                                   TP_DISPONIBILIDADE,
			     P.SN_URGENCIA_EMERGENCIA                                                               SN_URGENCIA_EMERGENCIA,
			     LVR.TP_MVTO_CADASTRAL                                                                  TP_MVTO_CADASTRAL,
			     LVR.CD_LOG_PROCESSO_MVS                                                                CD_LOG,
			     LVR.CD_REGISTRO_ANS_INTERMED                                                           CD_REGISTRO_ANS_INTERMED,
			     LVR.CD_LOG_VINCULACAO_RPS_ANS  														                            CD_LOG_VINCULACAO_RPS_ANS,
           LVR.CD_VINCULACAO_RPS_ANS                                                              CD_VINCULACAO_RPS_ANS
		  FROM DBAPS.LOG_VINCULACAO_RPS_ANS  LVR,
			     DBAPS.PRESTADOR               P,
			     DBAPS.PRESTADOR_ENDERECO      PE,
			     DBAMV.MULTI_EMPRESAS_MV_SAUDE MVS
		 WHERE LVR.CD_PRESTADOR                       = P.CD_PRESTADOR
			 AND LVR.CD_MULTI_EMPRESA                   = P.CD_MULTI_EMPRESA
			 AND P.CD_PRESTADOR                         = PE.CD_PRESTADOR
			 AND P.CD_MULTI_EMPRESA                     = MVS.CD_MULTI_EMPRESA
			 AND LVR.CD_VINCULACAO_RPS_ANS IS NOT NULL
			 AND LVR.TP_MVTO_CADASTRAL                  = P_TP_MVTO_CADASTRAL
			 AND NVL(LVR.SN_CONFIRMA_ENVIO, 'N')        = 'S'
			 AND NVL(PE.SN_PRINCIPAL, 'N')              = 'S'
			 AND LVR.CD_VINCULACAO_RPS_ANS              = P_CD_LOTE
			 AND P.CD_MULTI_EMPRESA                     = DBAMV.PKG_MV2000.LE_EMPRESA
    UNION ALL
    --INCLUINDO DADOS DO PRESTADOR EVENTUAL
    SELECT PE.CD_PRESTADOR_EVENTUAL				                                              CD_PRESTADOR,
		      MVS.SN_ISENCAO_ONUS_RPS                                                      SN_ISENCAO_ONUS_RPS,
		      NVL(null, 3)                                                                 CD_CLASSIFICACAO,
		      PE.nr_cnpj_cei  NR_CPF_CGC,
		      Nvl(PE.CD_CNES,999999)                                                       CD_CNES,
		      (SELECT CD_UF FROM DBAPS.MUNICIPIO WHERE CD_MUNICIPIO = PE.CD_MUNICIPIO) CD_UF,
		      PE.CD_MUNICIPIO                                                              CD_MUNICIPIO,
		      PE.ds_nome                                                                   NM_PRESTADOR,
		      PE.TP_CREDENCIAMENTO                                                         TP_CREDENCIAMENTO,
		      DECODE(PE.TP_CREDENCIAMENTO, 'C', NVL(PE.TP_CONTRATUALIZACAO,null), null)    TP_CONTRATUALIZACAO,
			        CASE WHEN PE.TP_CREDENCIAMENTO = 'P'
                    OR ( PE.dt_inclusao > To_Date('07/07/2003','DD/MM/YYYY') AND PE.CD_CLASSIFICACAO = 1 )
                    OR ( PE.dt_inclusao > To_Date('01/12/2003','DD/MM/YYYY') AND  PE.CD_CLASSIFICACAO = 2)
                    OR PE.CD_CLASSIFICACAO = 3 THEN
            NULL
          END                                                                          DT_CONTRATUALIZACAO,
			    NVL(TO_CHAR(PE.dt_inclusao,  'DD/MM/YYYY'), NULL)                            DT_CADASTRO,
			    PE.TP_DISPONIBILIDADE                                                        TP_DISPONIBILIDADE,
			    PE.URGENCIA_EMERGENCIA                                                       SN_URGENCIA_EMERGENCIA,
			    LVR.TP_MVTO_CADASTRAL                                                        TP_MVTO_CADASTRAL,
			    LVR.CD_LOG_PROCESSO_MVS                                                      CD_LOG,
			    LVR.CD_REGISTRO_ANS_INTERMED                                                 CD_REGISTRO_ANS_INTERMED,
			    LVR.CD_LOG_VINCULACAO_RPS_ANS  														                  CD_LOG_VINCULACAO_RPS_ANS,
          LVR.CD_VINCULACAO_RPS_ANS                                                    CD_VINCULACAO_RPS_ANS
    FROM  DBAPS.LOG_VINCULACAO_RPS_ANS  LVR,
			    DBAPS.PRESTADOR_EVENTUAL      PE,
			    DBAMV.MULTI_EMPRESAS_MV_SAUDE MVS
    WHERE LVR.CD_PRESTADOR_EVENTUAL = PE.CD_PRESTADOR_EVENTUAL
	    AND LVR.CD_MULTI_EMPRESA                   = MVS.CD_MULTI_EMPRESA
	    AND LVR.CD_VINCULACAO_RPS_ANS IS NOT NULL
	    AND LVR.TP_MVTO_CADASTRAL                  = P_TP_MVTO_CADASTRAL
	    AND NVL(LVR.SN_CONFIRMA_ENVIO, 'N')        = 'S'
	    AND LVR.CD_VINCULACAO_RPS_ANS              = P_CD_LOTE
	    AND LVR.CD_MULTI_EMPRESA                   = DBAMV.PKG_MV2000.LE_EMPRESA
      AND (SELECT sn_env_prestevt_rps FROM dbaps.plano_de_saude  )  ='S';

  /*******************************************************************************************************************
  ** CURSOR cVinculacao - OBTER AS VINCULAÇÕES NOS PLANOS DOS PRESTADORES(VERIFIQUE O PARAMETRO MVTO CADASTRAL) DO RPS.
  *******************************************************************************************************************/
  CURSOR cVinculacao(P_CD_LOG_VINC_RPS_ANS_TEM IN NUMBER, P_CD_PRESTADOR IN NUMBER) IS
  SELECT LVR.CD_PRESTADOR            CD_PRESTADOR,
			   P.CD_PLANO                  CD_PLANO,
		     P.CD_REGISTRO_MS            CD_REGISTRO_MS,
	       P.CD_PLANO_OPERADORA	       CD_PLANO_OPERADORA,
	       P.TP_PERIODO_IMPLANTACAO    TP_PERIODO_IMPLANTACAO
    FROM DBAPS.PLANO                  P,
			   DBAPS.LOG_VINCULACAO_RPS_ANS LVR
	 WHERE LVR.CD_MULTI_EMPRESA                = P.CD_MULTI_EMPRESA
	   AND LVR.CD_PLANO                        = P.CD_PLANO
	   AND NVL(LVR.SN_CONFIRMA_ENVIO, 'N')     = 'S'
	   AND P.SN_ATIVO                          = 'S'
	   AND LVR.TP_MVTO_CADASTRAL               = 'V'
	   AND LVR.CD_LOG_VINCULACAO_RPS_ANS_TEM   = P_CD_LOG_VINC_RPS_ANS_TEM
	   AND LVR.CD_PRESTADOR                    = P_CD_PRESTADOR
	   AND P.CD_MULTI_EMPRESA                  = DBAMV.PKG_MV2000.LE_EMPRESA
     AND (SELECT sn_env_prestevt_rps FROM dbaps.plano_de_saude  )  ='S';
  /*******************************************************************************************************************
  ** CURSOR cRpsAnsExc - OBTER OS PRESTADORES EXCLUIDOS(VERIFIQUE O PARAMETRO MVTO CADASTRAL) DO RPS.
  *******************************************************************************************************************/
  CURSOR cRpsAnsExc IS
   SELECT NVL(LVR.NR_CPF_CGC, P.NR_CPF_CGC) CNPJ_CPF,
			    Nvl(P.CD_CNES, PE.CD_CNES)        CNES,
			    PE.CD_MUNICIPIO                   CODIGO_MUNICIPIO_IBGE
    FROM DBAPS.PRESTADOR              P,
	 		   DBAPS.PRESTADOR_ENDERECO     PE,
			   DBAPS.LOG_VINCULACAO_RPS_ANS LVR
   WHERE P.CD_PRESTADOR 			 = PE.CD_PRESTADOR
     AND P.CD_PRESTADOR 			 = LVR.CD_PRESTADOR
     AND P.CD_MULTI_EMPRESA 	 = LVR.CD_MULTI_EMPRESA
     AND LVR.TP_MVTO_CADASTRAL = P_TP_MVTO_CADASTRAL
     AND LVR.SN_CONFIRMA_ENVIO = 'S'
     AND NVL(PE.SN_PRINCIPAL, 'N') 	= 'S'
     AND LVR.CD_VINCULACAO_RPS_ANS IS NOT NULL
     AND LVR.CD_VINCULACAO_RPS_ANS = P_CD_LOTE
     AND P.CD_MULTI_EMPRESA = DBAMV.PKG_MV2000.LE_EMPRESA
  UNION ALL
    --Buscando dados do prestador Eventual
    SELECT NVL(LVR.NR_CPF_CGC, P.nr_cnpj_cei)   CNPJ_CPF,
			        Nvl(P.CD_CNES,999999)             CNES,
			        P.CD_MUNICIPIO                    CODIGO_MUNICIPIO_IBGE
        FROM DBAPS.PRESTADOR_EVENTUAL           P,
			      DBAPS.LOG_VINCULACAO_RPS_ANS        LVR
      WHERE P.CD_PRESTADOR_EVENTUAL  = LVR.CD_PRESTADOR_EVENTUAL
        AND LVR.CD_MULTI_EMPRESA 	   = DBAMV.PKG_MV2000.LE_EMPRESA
        AND LVR.TP_MVTO_CADASTRAL    = P_TP_MVTO_CADASTRAL
        AND LVR.SN_CONFIRMA_ENVIO    = 'S'
        AND LVR.CD_VINCULACAO_RPS_ANS IS NOT NULL
        AND LVR.CD_VINCULACAO_RPS_ANS = P_CD_LOTE
        AND (SELECT sn_env_prestevt_rps FROM dbaps.plano_de_saude  )  ='S';

  -- VARIAVEIS DOS CURSORES
  rCabecalhoRps cCabecalhoRps%ROWTYPE;
  rRpsAnsIncAlt cRpsAnsIncAlt%ROWTYPE;
  rVinculacao   cVinculacao%ROWTYPE;
  rRpsAnsExc    cRpsAnsExc%ROWTYPE;
  rExisteLote   cExisteLote%ROWTYPE;

  -- VARIAVEIS DO CABECALHO
  nNrRegistroAns VARCHAR2(6);
  nNrCgcCnpjOperadora VARCHAR2(14);
  vSnIsencaoOnus VARCHAR2(1);
  nNossoNumero VARCHAR2(1);

  -- VARIAVEIS DO PRESTADOR
  nCdPrestador NUMBER;
  vSnIsencaoOnusRps VARCHAR2(1);
  nCdClassificacao NUMBER;
  vNrCpfCgc VARCHAR2(100);
  vCdCnes VARCHAR2(100);
  vCdUf VARCHAR2(6);
  nCdMunicipio NUMBER;
  vNmPrestador VARCHAR2(200);
  vTpCredenciamento VARCHAR2(1);
  vTpContratualizacao VARCHAR2(1);
  dDtContratualizacao VARCHAR2(30);
  dDtCadastro VARCHAR(30);
  vTpDisponibilidade VARCHAR2(1);
  vSnUrgenciaEmergencia VARCHAR2(1);
  vTpMvtoCadastral VARCHAR2(1);
  nCdLog NUMBER;
  nCdRegistroAnsIntermendiario NUMBER;
  nCdLogVinculacaoRpsAns NUMBER;
  nCdVinculacaoRpsAns NUMBER;

  -- USADAS NAS SEQUENCES
  nSeqRpsCabecalho NUMBER;
  nSeqRpsPrestadorErro NUMBER;
  nSeqRpsCampoErro NUMBER;

  -- VARIÁVEL DE RETORNO
  bIsError VARCHAR(1);

BEGIN

  bIsError := 'N';

  -- IF INCLUSAO OU ALTERACAO
  IF P_TP_MVTO_CADASTRAL = 'I' OR P_TP_MVTO_CADASTRAL = 'U'  THEN

    -- VALIDA SE O LOTE INFORMADO JÁ EXISTE. SE EXISTIR, DELETAR O REGISTRO ANTERIOR.
    OPEN  cExisteLote;
    FETCH cExisteLote INTO rExisteLote;
    CLOSE cExisteLote;

    IF rExisteLote.LOTE IS NOT NULL THEN

      DELETE DBAPS.RPS_CABECALHO_ERRO
        WHERE NR_LOTE = P_CD_LOTE
        AND   TP_MVTO_CADASTRAL = P_TP_MVTO_CADASTRAL;
    END IF;

    -- VALIDA CAMPOS DO CABECALHO
    OPEN  cCabecalhoRps;
    FETCH cCabecalhoRps INTO rCabecalhoRps;
    CLOSE cCabecalhoRps;

    nNrRegistroAns      := LPad(rCabecalhoRps.REGISTRO_ANS, 6, '0');
    nNrCgcCnpjOperadora := LPad(rCabecalhoRps.CNPJ_OPERADORA, 14, '0');
    vSnIsencaoOnus      := rCabecalhoRps.SN_ISENCAO_ONUS_RPS;
    nNossoNumero        := rCabecalhoRps.NOSSO_NUMERO;

    SELECT DBAPS.SEQ_RPS_CABECALHO_ERRO.NEXTVAL INTO nSeqRpsCabecalho FROM DUAL;
    INSERT INTO DBAPS.RPS_CABECALHO_ERRO(CD_RPS_CABECALHO_ERRO
                                        ,NR_ANS
                                        ,NR_CGC_ANS
                                        ,SN_ISENCAO_ONUS_RPS
                                        ,NR_NOSSO_NUMERO
                                        ,NR_LOTE
                                        ,TP_MVTO_CADASTRAL)
                                  VALUES(nSeqRpsCabecalho
                                        ,nNrRegistroAns
                                        ,nNrCgcCnpjOperadora
                                        ,vSnIsencaoOnus
                                        ,nNossoNumero
                                        ,P_CD_LOTE
                                        ,P_TP_MVTO_CADASTRAL);

    -- VALIDA REGISTRO ANS
    IF nNrRegistroAns IS NULL OR Length(nNrRegistroAns) < 6 OR Length(nNrRegistroAns) > 6 THEN
      bIsError := 'S';
      Raise_Application_Error(-20999,'FALTA CONFIGURACAO DE REGISTRO ANS NA TELA DE CONFIGURAÇÃO DO SISTEMA [DBAMV.MULTI_EMPRESAS_MV_SAUDE.NR_ANS]');
    END IF;

    -- VALIDA CNPJ OPERADORA
    IF nNrCgcCnpjOperadora IS NULL OR Length(nNrCgcCnpjOperadora) < 14 OR Length(nNrCgcCnpjOperadora) > 14 THEN
      bIsError := 'S';
      Raise_Application_Error(-20999,'FALTA CONFIGURACAO DO CNPJ DA OPERADORA NA TELA DE CONFIGURACOES GERAIS [DBAMV.MULTI_EMPRESAS_MV_SAUDE.NR_CGC_ANS]');
    END IF;

    -- VALIDA ISENCAO ONUS
    IF vSnIsencaoOnus IS NULL THEN
      bIsError := 'S';
      Raise_Application_Error(-20999,'FALTA CONFIGURACAO DE ISENÇÃO ONUS [DBAMV.MULTI_EMPRESAS_MV_SAUDE.SN_ISENCAO_ONUS_RPS]');
    END IF;

    -- FIM VALIDA CAMPO CABECALHO

    -- LOOP RPS INCL/ALT
    OPEN  cRpsAnsIncAlt;
    FETCH cRpsAnsIncAlt INTO rRpsAnsIncAlt;
    CLOSE cRpsAnsIncAlt;

    IF rRpsAnsIncAlt.CD_PRESTADOR IS NOT NULL THEN
      FOR rRpsAnsIncAlt IN cRpsAnsIncAlt
      LOOP

        nCdPrestador          := rRpsAnsIncAlt.CD_PRESTADOR;
        vSnIsencaoOnusRps     := rRpsAnsIncAlt.SN_ISENCAO_ONUS_RPS;
        nCdClassificacao      := rRpsAnsIncAlt.CD_CLASSIFICACAO;
        vNrCpfCgc             := rRpsAnsIncAlt.NR_CPF_CGC;
        vCdCnes               := rRpsAnsIncAlt.CD_CNES;
        vCdUf                 := rRpsAnsIncAlt.CD_UF;
        nCdMunicipio          := rRpsAnsIncAlt.CD_MUNICIPIO;
        vNmPrestador          := rRpsAnsIncAlt.NM_PRESTADOR;
        vTpCredenciamento     := rRpsAnsIncAlt.TP_CREDENCIAMENTO;
        vTpContratualizacao   := rRpsAnsIncAlt.TP_CONTRATUALIZACAO;
        dDtContratualizacao   := rRpsAnsIncAlt.DT_CONTRATUALIZACAO;
        dDtCadastro           := rRpsAnsIncAlt.DT_CADASTRO;
        vTpDisponibilidade    := rRpsAnsIncAlt.TP_DISPONIBILIDADE;
        vSnUrgenciaEmergencia := rRpsAnsIncAlt.SN_URGENCIA_EMERGENCIA;
        vTpMvtoCadastral      := rRpsAnsIncAlt.TP_MVTO_CADASTRAL;
        nCdLog                := rRpsAnsIncAlt.CD_LOG;
        nCdRegistroAnsIntermendiario := rRpsAnsIncAlt.CD_REGISTRO_ANS_INTERMED;
        nCdLogVinculacaoRpsAns := rRpsAnsIncAlt.CD_LOG_VINCULACAO_RPS_ANS;
        nCdVinculacaoRpsAns    := rRpsAnsIncAlt.CD_VINCULACAO_RPS_ANS;

        SELECT DBAPS.SEQ_RPS_PRESTADOR_ERRO.NEXTVAL INTO nSeqRpsPrestadorErro FROM DUAL;
        INSERT INTO DBAPS.RPS_PRESTADOR_ERRO(CD_RPS_PRESTADOR_ERRO
                                            ,CD_RPS_CABECALHO_ERRO
                                            ,CD_PRESTADOR
                                            ,NM_PRESTADOR
                                            ,TP_MVTO_CADASTRAL
                                            ,NR_LOTE  )
                                      VALUES(nSeqRpsPrestadorErro
                                            ,nSeqRpsCabecalho
                                            ,nCdPrestador,vNmPrestador
                                            ,P_TP_MVTO_CADASTRAL
                                            ,nCdVinculacaoRpsAns);

        -- INICIO DAS VALIDACOES DOS CAMPOS OBRIGATORIOS. SE HOUVER ERROS, INSERIR NAS TABELAS DE REGISTROS DE ERROS DO RPS.
        -- IF MOVIMENTO CADASTRAL INCLUSAO
        IF P_TP_MVTO_CADASTRAL = 'I' THEN

          -- VALIDACAO CLASSIFICACAO
           IF nCdClassificacao IS NULL THEN
            bIsError := 'S';
            nSeqRpsCampoErro := NULL;
            SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
            INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
            VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'CLASSIFICACAO','Este campo e obrigatório.', 'S');
          END IF;
          IF nCdClassificacao < 1 OR nCdClassificacao > 3 THEN
            bIsError := 'S';
            nSeqRpsCampoErro := NULL;
            SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
            INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
            VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'CLASSIFICACAO: ' || nCdClassificacao,'Os seguintes valores são aceitos: ''1'' para Assistência Hospitalar, ''2'' para Serviços de Alta Complexidade e ''3'' para Demais Estabelecimentos.', 'S');
          END IF;

          -- VALIDACAO CPF/CNPJ

          IF vNrCpfCgc IS NULL THEN
            bIsError := 'S';
            nSeqRpsCampoErro := NULL;
            SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
            INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
            VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'CNPJ/CPF','Este campo é obrigatório.', 'S');
          END IF;

          IF Length(vNrCpfCgc) < 11 OR Length(vNrCpfCgc) > 14  THEN
            bIsError := 'S';
            nSeqRpsCampoErro := NULL;
            SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
            INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
            VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'CNPJ/CPF: ' || vNrCpfCgc,'Valor informado inválido. 11 (onze) caracteres para CPF e 14 (quatorze) caracteres para CNPJ.', 'S');
          END IF;

          --VALIDACAO CNES
          /*
          IF vCdCnes IS NULL THEN
            bIsError := 'N';
            nSeqRpsCampoErro := NULL;
            SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
            INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
            VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'CNES','Campo não informado (não obrigatório). Obrigatório apenas para o prestador que possuir registro CNES.', 'N');
          END IF;
          */
          IF Length(vCdCnes) <> 7 THEN
            bIsError := 'S';
            nSeqRpsCampoErro := NULL;
            SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
            INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
            VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'CNES: ' || vCdCnes,'O campo CNES só pode conter 7 (sete) dígitos.', 'S');
          END IF;

          --VALIDACAO DA UF
          IF vCdUf IS NULL THEN
            bIsError := 'S';
            nSeqRpsCampoErro := NULL;
            SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
            INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
            VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'UF','Este campo é obrigatório.', 'S');
          END IF;
          IF Length(vCdUf) <> 2 THEN
            bIsError := 'S';
            nSeqRpsCampoErro := NULL;
            SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
            INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
            VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'UF: ' || vCdUf,'O campo só pode conter apenas dois carcteres.', 'S');
          END IF;

          -- VALIDACAO CODIGO MUNICIPIO IBGE
          IF nCdMunicipio IS NULL THEN
            bIsError := 'S';
            nSeqRpsCampoErro := NULL;
            SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
            INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
            VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'CODIGO MUNICIPIO IBGE','Este campo é obrigatório', 'S');
          END IF;
          IF Length(nCdMunicipio) <> 6 THEN
            bIsError := 'S';
            nSeqRpsCampoErro := NULL;
            SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
            INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
            VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'CODIGO MUNICIPIO IBGE: ' || nCdMunicipio,'Fornecer apenas os 6 (seis) primeiros dígitos do código (sem dígito verificador).', 'S');
          END IF;

          -- VALIDACAO RAZAO SOCIAL
          IF vNmPrestador IS NULL THEN
            bIsError := 'S';
            nSeqRpsCampoErro := NULL;
            SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
            INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
            VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'RAZAO SOCIAL','Este campo é obrigatório', 'S');
          END IF;
          IF Length(vNmPrestador) > 60 THEN
            bIsError := 'S';
            nSeqRpsCampoErro := NULL;
            SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
            INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
            VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'RAZAO SOCIAL: ' || vNmPrestador,'O campo só pode conter 60 caracteres', 'S');
          END IF;

          -- VALIDACAO RELACAO OPERADORA
          IF vTpCredenciamento IS NULL THEN
            bIsError := 'S';
            nSeqRpsCampoErro := NULL;
            SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
            INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
            VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'RELACÃO OPERADORA','Campo Obrigatório', 'S');
          END IF;
          IF vTpCredenciamento NOT IN('P', 'C', 'D')  THEN
            bIsError := 'S';
            nSeqRpsCampoErro := NULL;
            SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
            INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
            VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'RELACÃO OPERADORA: ' || vTpCredenciamento,'valor inválido. Os seguintes valores são aceitos: ''P'' para Próprio, ''C'' para Contratualizado e ''D'' para Cooperado', 'S');
          END IF;

          --VALIDACAO TIPO CONTRATUALIZACAO
          IF vTpCredenciamento = 'C' THEN -- Obrigatório quando a tag 'relacaoOperadora' é 'C'
            IF vTpContratualizacao IS NULL THEN
              bIsError := 'S';
              nSeqRpsCampoErro := NULL;
              SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
              INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
              VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'TIPO CONTRATUALIZACAO' || vTpContratualizacao,'Campo não informado. Obrigatório quando Relação Operadora é ''C'' Contratualizado.', 'S');
            END IF;
            IF vTpContratualizacao != 'D' AND  vTpContratualizacao != 'I' THEN
              bIsError := 'S';
              nSeqRpsCampoErro := NULL;
              SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
              INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
              VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'TIPO CONTRATUALIZACAO: ' || vTpContratualizacao,'Valor informado inválido. Os seguintes valores são aceitos: ''D'' para direto ''I'' para indireto', 'S');
            END IF;
          ELSIF vTpCredenciamento IN ('D', 'P') AND vTpContratualizacao IS NOT NULL THEN
             bIsError := 'S';
             nSeqRpsCampoErro := NULL;
             SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
             INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
             VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'TIPO CONTRATUALIZACAO: ' || vTpContratualizacao,'Não permitido quando Relação Operadora é ''P'' (Próprio)', 'S');
          END IF;

          -- VALIDACAO REGISTRO ANS OPERADORA INTERMEDIARIA
          IF vTpCredenciamento = 'C' AND vTpContratualizacao = 'I' THEN -- Obrigatório quando a tag 'relacaoOperadora' é 'C' (Contratualizado) e o tipo de contratualização é 'I' (Indireto)

            IF nCdRegistroAnsIntermendiario IS NULL THEN
              bIsError := 'S';
              nSeqRpsCampoErro := NULL;
              SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
              INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
              VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'REGISTRO ANS OPERADORA INTERMEDIARIA','Obrigatório quando a tag ''Relacao Operadora'' é ''C'' (Contratualizado) e o tipo de contratualização é ''I'' (Indireto)', 'S');
            END IF;
          ELSIF (vTpContratualizacao = 'D' OR vTpContratualizacao = 'P') AND  nCdRegistroAnsIntermendiario IS NOT NULL THEN
              bIsError := 'S';
              nSeqRpsCampoErro := NULL;
              SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
              INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
              VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'REGISTRO ANS OPERADORA INTERMEDIARIA: ' || nCdRegistroAnsIntermendiario,'Valor inválido. Não permitido quando Relação Operadora  é ''P'' (Próprio) ou ''D'' (Direto).', 'S');
          END IF;

          -- VALIDACAO DATA CONTRATUALIZACAO
          /*
          IF vTpCredenciamento = 'P' OR (dDtContratualizacao > To_Date('07072013','ddmmyyyy') AND nCdClassificacao = 1)
                                     OR (dDtContratualizacao > To_Date('01122013','ddmmyyyy') AND nCdClassificacao = 2)
                                     OR nCdClassificacao = 3 THEN
          END IF;
          */

          -- VALIDACAO DATA INICIO PRESTACAO

          --validacao

        END IF;
        -- FIM IF MOVIMENTO CADASTRAL INCLUSAO

        -- IF MONVIMENTO CADASTRAL DE ALTERACAO
        IF P_TP_MVTO_CADASTRAL = 'U' THEN

              -- VALIDACAO CLASSIFICACAO
              IF nCdClassificacao IS NOT NULL THEN
                  IF nCdClassificacao < 1 OR nCdClassificacao > 3 THEN
                    bIsError := 'S';
                    nSeqRpsCampoErro := NULL;
                    SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
                    INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
                    VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'CLASSIFICACAO: ' || nCdClassificacao,'Os seguintes valores são aceitos: ''1'' para Assistência Hospitalar, ''2'' para Serviços de Alta Complexidade e ''3'' para Demais Estabelecimentos.', 'S');
                  END IF;
               END IF;

               -- VALIDACAO CPF/CNPJ
               IF vNrCpfCgc IS NOT NULL THEN
                  IF Length(vNrCpfCgc) < 11 OR Length(vNrCpfCgc) > 14  THEN
                    bIsError := 'S';
                    nSeqRpsCampoErro := NULL;
                    SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
                    INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
                    VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'CNPJ/CPF: ' || vNrCpfCgc,'Valor informado inválido. 11 (onze) caracteres para CPF e 14 (quatorze) caracteres para CNPJ.', 'S');
                  END IF;
               END IF;

               -- VALIDACAO CNES
               IF vCdCnes IS NOT NULL THEN
                IF Length(vCdCnes) <> 7 THEN
                  bIsError := 'S';
                  nSeqRpsCampoErro := NULL;
                  SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
                  INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
                  VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'CNES: ' || vCdCnes,'O campo CNES só pode conter 7 (sete) dígitos.', 'S');
                END IF;
               END IF;

              -- VALIDACAO CODIGO MUNICIPIO IBGE
              IF nCdMunicipio IS NOT NULL THEN
                IF Length(nCdMunicipio) <> 6 THEN
                  bIsError := 'S';
                  nSeqRpsCampoErro := NULL;
                  SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
                  INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
                  VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'CODIGO MUNICIPIO IBGE: ' || nCdMunicipio,'Fornecer apenas os 6 (seis) primeiros dígitos do código (sem dígito verificador).', 'S');
                END IF;
              END IF;

              -- VALIDACAO UF
              IF vCdUf IS NOT NULL THEN
                 IF vCdUf IS NULL THEN
                    bIsError := 'S';
                    nSeqRpsCampoErro := NULL;
                    SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
                    INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
                    VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'UF','Este campo é obrigatório quando o código do município for informado.', 'S');
                 END IF;
              END IF;

              -- VALIDACAO RAZAO SOCIAL. OPCIONAL SEM RESTRICOES

              -- VALIDACAO RELACAO OPERADORA
              IF vTpCredenciamento IS NOT NULL THEN
                  IF vTpCredenciamento NOT IN('P', 'C', 'D')  THEN
                    bIsError := 'S';
                    nSeqRpsCampoErro := NULL;
                    SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
                    INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
                    VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'RELACÃO OPERADORA: ' || vTpCredenciamento,'valor inválido. Os seguintes valores são aceitos: ''P'' para Próprio e ''C'' para Contratualizado e ''D'' para Cooperado', 'S');
                  END IF;
              END IF;

              -- VALIDACAO TIPO CONTRATUALIZACAO
              IF vTpCredenciamento = 'C' THEN -- Obrigatório quando a tag 'relacaoOperadora' é 'C'
                 IF Trim(vTpContratualizacao) != To_Char('D') AND Trim(vTpContratualizacao) != To_Char('I') THEN
                    bIsError := 'S';
                    nSeqRpsCampoErro := NULL;
                    SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
                    INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
                    VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'TIPO CONTRATUALIZACAO: ' || vTpContratualizacao,'Valor informado inválido. Os seguintes valores são aceitos: ''D'' para direto ''I'' para indireto', 'S');
                 END IF;
              END IF;
             IF vTpCredenciamento IN ('D', 'P') AND vTpContratualizacao IS NOT NULL THEN
                bIsError := 'S';
                nSeqRpsCampoErro := NULL;
                SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
                INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
                VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'TIPO CONTRATUALIZACAO: ' || vTpContratualizacao,'Não permitido informar quando Relação Operadora é ''P'' (Próprio)', 'S');
             END IF;

             -- VALIDACAO REGISTRO ANS OPERADORA INTERMEDIARIA
             IF vTpCredenciamento = 'C' AND vTpContratualizacao = 'I' THEN -- Obrigatório quando a tag 'relacaoOperadora' é 'C' (Contratualizado) e o tipo de contratualização é 'I' (Indireto)
                IF nCdRegistroAnsIntermendiario IS NULL THEN
                  bIsError := 'S';
                  nSeqRpsCampoErro := NULL;
                  SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
                  INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
                  VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'REGISTRO ANS OPERADORA INTERMEDIARIA','Obrigatório quando a tag ''Relacao Operadora'' é ''C'' (Contratualizado) e o tipo de contratualização é ''I'' (Indireto)', 'S');
                END IF;
             ELSIF (vTpContratualizacao = 'D' OR vTpContratualizacao = 'P') AND  nCdRegistroAnsIntermendiario IS NOT NULL THEN
                bIsError := 'S';
                nSeqRpsCampoErro := NULL;
                SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
                INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
                VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'REGISTRO ANS OPERADORA INTERMEDIARIA: ' || nCdRegistroAnsIntermendiario,'Valor inválido. Não permitido quando Relação Operadora  é ''P'' (Próprio) ou ''D'' (Direto).', 'S');
             END IF;

        END IF;
        -- FIM IF MOVIMENTO CADASTRAL DE ALTERACAO

        -- IF MOVIMENTO CADASTRAL EXCLUSAO
          IF P_TP_MVTO_CADASTRAL = 'D' THEN

             -- VALIDACAO CPF/CNPJ
             IF vNrCpfCgc IS NULL THEN
                bIsError := 'S';
                nSeqRpsCampoErro := NULL;
                SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
                INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
                VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'CNPJ/CPF','Este campo é obrigatório.', 'S');
             END IF;
             IF Length(vNrCpfCgc) < 11 OR Length(vNrCpfCgc) > 14  THEN
                bIsError := 'S';
                nSeqRpsCampoErro := NULL;
                SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
                INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
                VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'CNPJ/CPF: ' || vNrCpfCgc,'Valor informado inválido. 11 (onze) caracteres para CPF e 14 (quatorze) caracteres para CNPJ.', 'S');
             END IF;

             -- VALIDACAO CNES
             IF vCdCnes IS NOT NULL THEN
               IF Length(vCdCnes) <> 7 THEN
                 bIsError := 'S';
                 nSeqRpsCampoErro := NULL;
                 SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
                 INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
                 VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'CNES: ' || vCdCnes,'O campo CNES só pode conter 7 (sete) dígitos.', 'S');
               END IF;
            END IF;

            -- VALIDACAO CODIGO MUNICIPIO IBGE
            IF nCdMunicipio IS NULL THEN
              bIsError := 'S';
              nSeqRpsCampoErro := NULL;
              SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
              INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
              VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'CODIGO MUNICIPIO IBGE','Este campo é obrigatório', 'S');
            END IF;
            IF nCdMunicipio IS NOT NULL THEN
                IF Length(nCdMunicipio) <> 6 THEN
                  bIsError := 'S';
                  nSeqRpsCampoErro := NULL;
                  SELECT DBAPS.SEQ_RPS_CAMPO_ERRO.NEXTVAL INTO nSeqRpsCampoErro FROM DUAL;
                  INSERT INTO DBAPS.RPS_CAMPO_ERRO(CD_RPS_CAMPO_ERRO,CD_RPS_PRESTADOR_ERRO,NM_CAMPO,DS_ERRO, SN_INCONSISTENCIA)
                  VALUES(nSeqRpsCampoErro,nSeqRpsPrestadorErro,'CODIGO MUNICIPIO IBGE: ' || nCdMunicipio,'Fornecer apenas os 6 (seis) primeiros dígitos do código (sem dígito verificador).', 'S');
                END IF;
            END IF;

          END IF;
        -- FIM IF MOVIMENTO CADASTRAL EXCLUSAO

        -- FIM DAS VALIDACOES DOS CAMPOS OBRIGATORIOS. SE HOUVER ERROS, INSERIR NAS TABELAS DE REGISTROS DE ERROS DO RPS.
        nCdPrestador := NULL;
        vSnIsencaoOnusRps := NULL;
        nCdClassificacao := NULL;
        vNrCpfCgc := NULL;
        vCdCnes := NULL;
        vCdUf := NULL;
        nCdMunicipio := NULL;
        vNmPrestador := NULL;
        vTpCredenciamento := NULL;
        vTpContratualizacao := NULL;
        dDtContratualizacao := NULL;
        dDtCadastro := NULL;
        vTpDisponibilidade := NULL;
        vSnUrgenciaEmergencia := NULL;
        vTpMvtoCadastral := NULL;
        nCdLog := NULL;
        nCdRegistroAnsIntermendiario := NULL;
        nCdLogVinculacaoRpsAns := NULL;
        nCdVinculacaoRpsAns := NULL;


      END LOOP;
      -- FIM LOOP RPS INCL/ALT
    END IF;

  END IF;
  -- FIM IF INCLUSAO OU ALTERACAO

  /*IF bIsError = 'S' THEN
    COMMIT;
  ELSE
   ROLLBACK;
  END IF;*/
  COMMIT;


  RETURN bIsError;


  EXCEPTION WHEN OTHERS THEN -- SE QUALQUER ERRO OCORRER...
    Raise_Application_Error(-20999,'erro ao executar a procedure PRC_VALIDA_RPS, por favor, entrar em contato com o suporte. Erro: ' || SQLERRM);

END;
/

GRANT EXECUTE ON dbaps.fnc_valida_rps TO dbamv
/
GRANT EXECUTE ON dbaps.fnc_valida_rps TO dbasgu
/
GRANT EXECUTE ON dbaps.fnc_valida_rps TO mv2000
/
GRANT EXECUTE ON dbaps.fnc_valida_rps TO mvintegra
/
