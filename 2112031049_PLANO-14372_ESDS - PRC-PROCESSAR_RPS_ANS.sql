--<DS_SCRIPT>
-- DESCRIÇÃO..: Adicionando dados do prestador Eventual
-- RESPONSAVEL: Elias Santana
-- DATA.......: 03/12/2021
-- APLICAÇÃO..: MVSAUDE   PLANO-14372
--</DS_SCRIPT>

CREATE OR REPLACE PROCEDURE DBAPS.PRC_MVS_PROCESSAR_RPS (P_CD_VINCULACAO_RPS IN NUMBER,
                                                         P_DT_INICIAL        IN DATE,
                                                         P_DT_FINAL          IN DATE ) IS

  /**************************************************************
    <objeto>
     <nome>PRC_MVS_PROCESSAR_RPS</nome>
     <usuario>Dellanio Alencar</usuario>
     <alteracao>18/11/2021 09:47</alteracao>
     <descricao>Responsável por gerar os registros de vinculação</descricao>
     <ultimaAlteracao>
      FDLA - 18/11/21   - REVISAO RPS (REGRAS)
      ESDS - 03/12/2021 - ADIÇÃO DO PRESATADOR EVENTUAL
     </ultimaAlteracao>
     <parametro> P_CD_VINCULACAO_RPS - código do lote
                 P_DT_INICIAL        - data inicial da movimentação
                 P_DT_FINAL          - data final da movimentação</parametro>
	   <tags>ANS, RPS, Prestador, Eventual</tags>
     <versao>1.3</versao>
    </objeto>
  ***************************************************************/

  -- Cursores
  CURSOR cPrestadoresInclusao IS
   SELECT LVRA.CD_PRESTADOR,
          LVRA.DT_MVTO_CADASTRAL,
          LVRA.CD_LOG_VINCULACAO_RPS_ANS,
          LVRA.TP_MVTO_CADASTRAL
      FROM DBAPS.LOG_VINCULACAO_RPS_ANS LVRA,
           DBAPS.PRESTADOR P
     WHERE LVRA.TP_MVTO_CADASTRAL NOT IN ('V')
       AND Nvl(LVRA.CD_VINCULACAO_RPS_ANS, P_CD_VINCULACAO_RPS) = P_CD_VINCULACAO_RPS
       AND Trunc(LVRA.DT_MVTO_CADASTRAL) BETWEEN Trunc(P_DT_INICIAL) AND Trunc(P_DT_FINAL)
       AND LVRA.CD_PRESTADOR NOT IN ( SELECT CD_PRESTADOR
                                        FROM DBAPS.PRESTADOR PR, DBAPS.RPS_PRESTADOR_EXCECAO PE
                                       WHERE PR.CD_TIP_PRESTADOR = PE.CD_TIP_PRESTADOR
                                         AND PR.CD_MULTI_EMPRESA = PE.CD_MULTI_EMPRESA )
       AND LVRA.CD_LOG_VINCULACAO_RPS_ANS = (SELECT Max(CD_LOG_VINCULACAO_RPS_ANS)
                                               FROM DBAPS.LOG_VINCULACAO_RPS_ANS LVRA2
                                              WHERE LVRA2.CD_PRESTADOR = LVRA.CD_PRESTADOR
                                                AND Trunc(LVRA2.DT_MVTO_CADASTRAL) BETWEEN Trunc(P_DT_INICIAL) AND Trunc(P_DT_FINAL)
                                                AND LVRA2.TP_MVTO_CADASTRAL = LVRA.TP_MVTO_CADASTRAL)
      --VALIDAR SE PRESTADOR AINDA EXISTE
      AND LVRA.CD_PRESTADOR = P.CD_PRESTADOR
      UNION ALL
      --INCLUSÃO DO PRESTADOR EVENTUAL
      SELECT LVRA.CD_PRESTADOR,
              LVRA.DT_MVTO_CADASTRAL,
              LVRA.CD_LOG_VINCULACAO_RPS_ANS,
              LVRA.TP_MVTO_CADASTRAL
          FROM DBAPS.LOG_VINCULACAO_RPS_ANS LVRA,
              DBAPS.PRESTADOR_EVENTUAL PE
        WHERE LVRA.TP_MVTO_CADASTRAL NOT IN ('V')
          AND Nvl(LVRA.CD_VINCULACAO_RPS_ANS, P_CD_VINCULACAO_RPS) = P_CD_VINCULACAO_RPS
          AND Trunc(LVRA.DT_MVTO_CADASTRAL) BETWEEN Trunc(P_DT_INICIAL) AND Trunc(P_DT_FINAL)
          AND LVRA.CD_PRESTADOR_EVENTUAL = PE.CD_PRESTADOR_eventual
          AND (SELECT SN_ENV_PRESTEVT_RPS FROM  DBAPS.PLANO_DE_SAUDE ) = 'S';


  CURSOR cNegativaPlanoPadrao IS
    SELECT SN_PLANO_PADRAO_NEGA_PROCED
      FROM DBAMV.MULTI_EMPRESAS_MV_SAUDE
     WHERE CD_MULTI_EMPRESA = DBAMV.PKG_MV2000.LE_EMPRESA;

  CURSOR cPlanosVinculados(pCdPrestador IN NUMBER, pDtFinalLote IN DATE, pSnPlanoPadraoNegaProced IN VARCHAR2) IS
    SELECT p.cd_plano
      FROM dbaps.plano p
     WHERE Nvl(p.sn_ativo, 'N') = 'S'
       AND 'N' = pSnPlanoPadraoNegaProced
       AND p.cd_plano NOT IN (SELECT DISTINCT(cd_plano)
                                FROM (SELECT rpp.cd_plano, rpp.cd_prestador
                                        FROM dbaps.rest_plano_prestador rpp

                                      UNION ALL

                                      SELECT rpp.cd_plano, rpp.cd_prestador
                                        FROM dbaps.rest_pres_plano rpp
                                       WHERE rpp.tp_restricao = 'N'
                                         AND rpp.dt_vigencia = (SELECT MAX(rpp.dt_vigencia)
                                                                  FROM dbaps.rest_pres_plano rpp2
                                                                 WHERE rpp2.cd_plano = rpp.cd_plano
                                                                   AND rpp2.tp_restricao = 'N'
                                                                   AND rpp2.dt_vigencia <= pDtFinalLote)
                                     )
                               WHERE cd_prestador = pCdPrestador)
    UNION
    SELECT p.cd_plano
      FROM dbaps.plano p
     WHERE Nvl(p.sn_ativo, 'N') = 'S'
        AND 'S' = pSnPlanoPadraoNegaProced
        AND p.cd_plano IN (SELECT rpp.cd_plano
                             FROM dbaps.rest_pres_plano rpp
                            WHERE rpp.tp_restricao <> 'N'
                              AND rpp.dt_vigencia = (SELECT MAX(rpp.dt_vigencia)
                                                      FROM dbaps.rest_pres_plano rpp2
                                                      WHERE rpp2.cd_plano = rpp.cd_plano
                                                        AND rpp2.tp_restricao <> 'N'
                                                        AND rpp2.dt_vigencia <= pDtFinalLote)
                              AND rpp.cd_prestador = pCdPrestador);

  -- Variáveis
  vNegPlanoPadrao VARCHAR2(1);

BEGIN

  UPDATE DBAPS.LOG_VINCULACAO_RPS_ANS
	   SET CD_VINCULACAO_RPS_ANS = NULL
   WHERE CD_VINCULACAO_RPS_ANS = P_CD_VINCULACAO_RPS;

  --Buscar configuraçÃµes
  OPEN cNegativaPlanoPadrao;
  FETCH cNegativaPlanoPadrao INTO vNegPlanoPadrao;
  CLOSE cNegativaPlanoPadrao;

  -- Cria os registros de vinculação caso exista uma inclusão ou alteração
  FOR I IN cPrestadoresInclusao LOOP

    IF I.TP_MVTO_CADASTRAL IN ('I', 'U') THEN -- Cria vinculação para o tipo Inclusão ou Alteração

      DELETE
        FROM DBAPS.LOG_VINCULACAO_RPS_ANS
       WHERE CD_LOG_VINCULACAO_RPS_ANS_TEM = CD_LOG_VINCULACAO_RPS_ANS
         AND TP_MVTO_CADASTRAL = 'V';

      FOR J IN cPlanosVinculados(I.CD_PRESTADOR, P_DT_FINAL, vNegPlanoPadrao) LOOP

        INSERT INTO DBAPS.LOG_VINCULACAO_RPS_ANS (
          CD_LOG_VINCULACAO_RPS_ANS,
          CD_LOG_VINCULACAO_RPS_ANS_TEM,
          CD_PRESTADOR,
          TP_MVTO_CADASTRAL,
          SN_CONFIRMA_ENVIO,
          DT_MVTO_CADASTRAL,
          CD_MULTI_EMPRESA,
          CD_PLANO
        ) VALUES (
          SEQ_LOG_VINCL_RPS_ANS.NEXTVAL,
          I.CD_LOG_VINCULACAO_RPS_ANS,  -- CÓDIGO DA MOVIMENTAÇÃO PAI DO TIPO ALTERAÇÃO
          I.CD_PRESTADOR,               -- PRESTADOR DA INCLUSÃO
          'V',                          -- V = VINCULAÇÃO
          'S',                          -- S = ENVIO SERÁ DEFAULT SIM
          I.DT_MVTO_CADASTRAL,          -- VINCULAÇÃO RECEBE A MESMA DATA DA INCLUSÃO
          PKG_MV2000.LE_EMPRESA,
          J.CD_PLANO
        );

      END LOOP;

    END IF;

    UPDATE DBAPS.LOG_VINCULACAO_RPS_ANS
	   SET CD_VINCULACAO_RPS_ANS = P_CD_VINCULACAO_RPS,
	       SN_CONFIRMA_ENVIO = 'S'
    WHERE CD_LOG_VINCULACAO_RPS_ANS = I.CD_LOG_VINCULACAO_RPS_ANS;

  END LOOP;

  COMMIT;

END prc_mvs_processar_rps;
/

GRANT EXECUTE ON dbaps.prc_mvs_processar_rps TO dbamv
/
GRANT EXECUTE ON dbaps.prc_mvs_processar_rps TO dbasgu
/
GRANT EXECUTE ON dbaps.prc_mvs_processar_rps TO mv2000
/
GRANT EXECUTE ON dbaps.prc_mvs_processar_rps TO mvintegra
/
