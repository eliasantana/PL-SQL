--<DS_SCRIPT>
-- DESCRIÇÃO..: Trigger Responsável por vincular o prestador Eventual ao RPS
-- RESPONSAVEL: Elias Santana
-- DATA.......: 24/11/2021
-- APLICAÇÃO..: MVSAUDE   PLANO-14372
--</DS_SCRIPT>
--<USUARIO=DBAPS>

CREATE OR REPLACE TRIGGER dbaps.trg_prest_ev_insere_rps_log
AFTER INSERT
ON dbaps.prestador_eventual
REFERENCES NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
    /***************************************************************************
    <objeto>
      <nome>trg_prest_ev_insere_rps_log</nome>
      <usuario>Elias Santana</usuario>
      <alteracao>24/11/2021 15:52</alteracao>
      <ultimaAlteracao>
      </ultimaAlteracao>
      <descricao>
        Trigger de geração de vinculo do prestador eventual com o RPS (PLANO-14372)
      </descricao>
      <tags>RPS, eventual, prestador</tags>
      <versao>1.0</versao>
      <soul>155</soul>
    </objeto>
    ***************************************************************************/
     CURSOR cConfiguracao IS
        SELECT sn_env_prestevt_rps FROM dbaps.plano_de_saude;


    rcConfiguracao cConfiguracao%ROWTYPE;

BEGIN
     OPEN  cConfiguracao;
     FETCH cConfiguracao INTO  rcConfiguracao;
     CLOSE cConfiguracao;

    IF rcConfiguracao.sn_env_prestevt_rps ='S' THEN
      Insert into dbaps.log_vinculacao_rps_ans
      (
          cd_log_vinculacao_rps_ans,
          cd_prestador_eventual                   ,
          tp_mvto_cadastral                       ,
          sn_confirma_envio                       ,
          dt_mvto_cadastral                       ,
          cd_multi_empresa
      )
      VALUES
      (
          seq_log_vincl_rps_ans.nextval            ,
          nvl(:new.cd_prestador_eventual,:old.cd_prestador_eventual) ,
          'I'                                      ,
          'N'                                      ,
          sysdate                                  ,
          DBAMV.PKG_MV2000.LE_EMPRESA
      );
     END IF;

END;
/




