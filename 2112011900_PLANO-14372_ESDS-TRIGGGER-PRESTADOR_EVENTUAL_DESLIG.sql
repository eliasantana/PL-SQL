CREATE OR REPLACE TRIGGER dbaps.trg_prest_event_deslig_rps
AFTER INSERT OR UPDATE OR DELETE
ON dbaps.prestador_eventual_deslig
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
    --Buscando da dos do prestador eventual
    CURSOR cPrestadorEventual(P_CD_PRESTADOR_EVENTUAL NUMBER ) IS
      SELECT
        cd_prestador_eventual,
        cd_unimed                    ,
        ds_nome                      ,
        nr_cnpj_cei                  ,
        nr_codigo                    ,
        tp_prestador                 ,
        cd_usuario_inclusao          ,
        dt_inclusao                  ,
        cd_usuario_alteracao         ,
        dt_alteracao                 ,
        ds_cod_conselho              ,
        ds_conselho                  ,
        ds_codigo_conselho           ,
        sn_recurso_proprio           ,
        ds_uf_conselho               ,
        dt_ini_contrato              ,
        dt_ini_servico               ,
        cd_cnes                      ,
        cd_municipio                 ,
        cd_classificacao             ,
        cd_registro_ans_intermed     ,
        tp_disponibilidade           ,
        tp_contratualizacao          ,
        tp_credenciamento            ,
        urgencia_emergencia
      FROM dbaps.prestador_eventual WHERE cd_prestador_eventual = P_CD_PRESTADOR_EVENTUAL;

      CURSOR cConfiguracao IS
        SELECT sn_env_prestevt_rps FROM dbaps.plano_de_saude;

      rcPrestadorEventual cPrestadorEventual%ROWTYPE;
      rcConfiguracao cConfiguracao%ROWTYPE;

      vMovimentacaoCadastral VARCHAR2(1):=null;
      vSnConfirma_envio VARCHAR2(1):='N';

      vEnvia VARCHAR2(1):=NULL;

BEGIN
      OPEN cPrestadorEventual(Nvl(:OLD.cd_prestador_eventual,:NEW.cd_prestador_eventual));
      FETCH cPrestadorEventual INTO rcPrestadorEventual;
      CLOSE cPrestadorEventual;

      OPEN  cConfiguracao;
      FETCH cConfiguracao INTO rcConfiguracao;
      vEnvia:= Nvl(rcConfiguracao.sn_env_prestevt_rps,'N');
      CLOSE cConfiguracao;
      --Exclusão
      IF INSERTING THEN
        IF (  Nvl(:old.dt_desligamento,to_date('01/01/1500','dd/mm/yyyy')) <> Nvl(:new.dt_desligamento,to_date('01/01/1500','dd/mm/yyyy')) AND :old.dt_reativacao IS NULL ) THEN
          vMovimentacaoCadastral:='D';
        END IF;
      END IF;
      --ALTERAÇÃO
      IF UPDATING THEN
        IF (Nvl(:old.dt_reativacao,to_date('01/01/1500','dd/mm/yyyy'))<> Nvl(:new.dt_reativacao,to_date('01/01/1500','dd/mm/yyyy')) AND :old.dt_desligamento IS NOT NULL ) THEN
           vMovimentacaoCadastral:='I';
        END IF;
        --Envia caso a chave SN_ENVIA_PRESTADOR_RPS da M_CNOFIGURA_SGPS esteja ativa
        IF  vEnvia = 'S' THEN
        --INCLUSÃO / REATIVAÇÃO
          INSERT INTO dbaps.log_vinculacao_rps_ans
          (cd_log_vinculacao_rps_ans                    ,
          cd_prestador_eventual                         ,
          tp_mvto_cadastral                             ,
          sn_confirma_envio                             ,
          dt_mvto_cadastral                             ,
          NR_CPF_CGC                                    ,
          NM_PRESTADOR                                  ,
          NM_FANTASIA                                   ,
          CD_CLASSIFICACAO                              ,
          TP_CREDENCIAMENTO                             ,
          TP_CONTRATUALIZACAO                           ,
          DT_CADASTRO                                   ,
          TP_DISPONIBILIDADE                            ,
          SN_URGENCIA_EMERGENCIA                        ,
          CD_REGISTRO_ANS_INTERMED                      ,
          DT_INATIVACAO                                 ,
          CD_MULTI_EMPRESA )
          Values
          (seq_log_vincl_rps_ans.nextval                ,
          rcPrestadorEventual.CD_PRESTADOR_EVENTUAL     ,
          vMovimentacaoCadastraL                        ,
          vSnConfirma_envio                             ,
          sysdate                                       ,
          rcPrestadorEventual.NR_CNPJ_CEI               ,
          rcPrestadorEventual.DS_NOME                   ,
          rcPrestadorEventual.DS_NOME                   ,
          rcPrestadorEventual.CD_CLASSIFICACAO          ,
          rcPrestadorEventual.TP_CREDENCIAMENTO         ,
          rcPrestadorEventual.TP_CONTRATUALIZACAO       ,
          rcPrestadorEventual.DT_INI_CONTRATO           ,
          rcPrestadorEventual.TP_DISPONIBILIDADE        ,
          rcPrestadorEventual.URGENCIA_EMERGENCIA       ,
          rcPrestadorEventual.CD_REGISTRO_ANS_INTERMED  ,
          :new.DT_DESLIGAMENTO                          ,
          DBAMV.PKG_MV2000.LE_EMPRESA
          );

        END IF;
      END IF;
END;


