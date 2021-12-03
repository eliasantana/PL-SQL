--<DS_SCRIPT>
-- DESCRIÇÃO..: Registrando alterações do prestador eventual
-- RESPONSAVEL: Elias Santana
-- DATA.......: 26/10/2021
-- APLICAÇÃO..: MVSAUDE   PLANO-14372
--</DS_SCRIPT>
--<USUARIO=DBAPS>
CREATE OR REPLACE TRIGGER dbaps.trg_altera_prest_event_log_rps
BEFORE UPDATE
ON dbaps.prestador_eventual
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
  /***************************************************************************
    <objeto>
      <nome>trg_prest_ev_insere_rps_log</nome>
      <usuario>Elias Santana</usuario>
      <alteracao>26/11/2021 10:59</alteracao>
      <ultimaAlteracao>
      </ultimaAlteracao>
      <descricao>
        Trigger responsavel pelo registro de alterações do prestador eventual )
        no RPS se a chave SN_ENVIA_PREST_EVENT_RPS estiver ligada 'S' (PLANO-14372)
      </descricao>
      <tags>RPS, eventual, prestador</tags>
      <versao>1.0</versao>
      <soul>155</soul>
    </objeto>
    ***************************************************************************/

  CURSOR cPrestExist(P_CD_PRESTADOR_EVENTUAL IN NUMBER) IS
	   SELECT 1
      FROM  DBAPS.LOG_VINCULACAO_RPS_ANS LV,
            DBAPS.VINCULACAO_RPS_ANS V
     WHERE  LV.TP_MVTO_CADASTRAL = 'I'
     AND LV.CD_VINCULACAO_RPS_ANS = V.CD_VINCULACAO_RPS_ANS(+)
     AND Trunc(SYSDATE) BETWEEN Trunc(V.DT_INICIO_MVTO_CADASTRAL) AND Trunc(V.DT_FINAL_MVTO_CADASTRAL)
     AND LV.CD_PRESTADOR_EVENTUAL = P_CD_PRESTADOR_EVENTUAL;

  CURSOR cConfiguracao IS
        SELECT sn_env_prestevt_rps FROM dbaps.plano_de_saude;

  rcConfiguracao cConfiguracao%ROWTYPE;

 vAltera                        boolean  := FALSE;
 vAtivacao                      boolean  := FALSE;
 vAlteraNR_CNPJ_CEI             varchar2(14);
 vAlteraDS_NOME                 varchar2(4000);
 vAlteraCD_CLASSIFICACAO        number(1);
 vAlteraTP_CREDENCIAMENTO       varchar2(1);
 vAlteraTP_CONTRATUALIZACAO     varchar2(1);
 vAlteraDT_CADASTRO             date;
 vAlteraTP_DISPONIBILIDADE      varchar2(1);
 vAlteraURGENCIA_EMERGENCIA     varchar2(1);
 vAlteraREGISTROANS_OP_INTERMED varchar2(6);
 vAlteraCNES VARCHAR2(20);
 vPrestExist                    NUMBER;

BEGIN

 vAlteraNR_CNPJ_CEI            := null;
 vAlteraDS_NOME                := null;
 vAlteraCD_CLASSIFICACAO       := null;
 vAlteraTP_CREDENCIAMENTO      := null;
 vAlteraTP_CONTRATUALIZACAO    := null;
 vAlteraDT_CADASTRO            := null;
 vAlteraTP_DISPONIBILIDADE     := null;
 vAlteraURGENCIA_EMERGENCIA    := null;
 vAlteraREGISTROANS_OP_INTERMED:= null;
 vAlteraCNES                   := NULL;
 vPrestExist                   := 0;

 OPEN cConfiguracao;
 FETCH cConfiguracao INTO rcConfiguracao;
 CLOSE cConfiguracao;

  --Verifica se a chave está ligada
  IF (Nvl(rcConfiguracao.sn_env_prestevt_rps,'N')='S') THEN

      If nvl(:new.nr_cnpj_cei,'0') <> nvl(:old.nr_cnpj_cei,'0') then
            vAltera           := TRUE;
            vAlteraNR_CNPJ_CEI := :new.nr_cnpj_cei;
      End if;
      -- Nome prestador
      If nvl(:new.ds_nome,'0')<> nvl(:old.ds_nome,'0') then
            vAltera           := TRUE;
            vAlteraDS_NOME:= :new.ds_nome;
      End if;
      -- Classificação do Estabelecimento
      If   nvl(:new.cd_classificacao,-1)   <> nvl(:old.cd_classificacao,-1)   then
            vAltera            := TRUE;
            vAlteraCD_CLASSIFICACAO := :new.cd_classificacao;
      End if;
      -- Relacão com entidade Hospitalar
      If  nvl(:new.tp_credenciamento,'0') <> nvl(:old.tp_credenciamento,'0') then
            vAltera            := TRUE;
            vAlteraTP_CREDENCIAMENTO := :new.tp_credenciamento;
      End if;
      --  Tipo de contratualizacão
      If nvl(:new.tp_contratualizacao,'0') <> nvl(:old.tp_contratualizacao,'0') then
            vAltera            := TRUE;
            vAlteraTP_CONTRATUALIZACAO := :new.tp_contratualizacao;
      End if;
      -- Data Contratualizacao / prestação de servico - inicio
      If nvl(:new.dt_ini_contrato,to_date('01/01/1500','dd/mm/yyyy')) <> nvl(:old.dt_ini_contrato,to_date('01/01/1500','dd/mm/yyyy')) then
            vAltera            := TRUE;
            vAlteraDT_CADASTRO := :new.dt_ini_contrato;
      End if;
      -- Disponibilidade de servicos
      If nvl(:new.tp_disponibilidade,'0') <> nvl(:old.tp_disponibilidade,'0') then
            vAltera            := TRUE;
            vAlteraTP_DISPONIBILIDADE := :new.tp_disponibilidade;
      End if;
      --URGENCIA_EMERGENCIA
      If nvl(:new.urgencia_emergencia,'0') <> nvl(:old.urgencia_emergencia,'0') then
            vAltera            := TRUE;
            vAlteraURGENCIA_EMERGENCIA := :new.urgencia_emergencia;
      End if;
      --REGISTRO ANS_OP_INTERMED
      -- So sera considerada a alteração do registro ANS da operadora intermediaria quando
      -- a contratualização for de maneira indireta - Debora Acacio
      If nvl(:new.tp_contratualizacao,:old.tp_contratualizacao) = 'I' then
          If nvl(:new.cd_registro_ans_intermed,'0') <> nvl(:old.cd_registro_ans_intermed,'0') then
              vAltera            := TRUE;
              vAlteraREGISTROANS_OP_INTERMED := :new.cd_registro_ans_intermed;
          End if;
      End if;

      If vAltera THEN
        OPEN cPrestExist(nvl(:new.cd_prestador_eventual,:old.cd_prestador_eventual));
        FETCH cPrestExist INTO vPrestExist;
        CLOSE cPrestExist;

          if (vPrestExist <> 1) THEN

            Insert into dbaps.log_vinculacao_rps_ans
                    (cd_log_vinculacao_rps_ans ,
                    cd_prestador_eventual      ,
                    tp_mvto_cadastral         ,
                    sn_confirma_envio         ,
                    dt_mvto_cadastral         ,
                    NR_CPF_CGC                ,
                    NM_PRESTADOR              ,
                    CD_CLASSIFICACAO          ,
                    TP_CREDENCIAMENTO         ,
                    TP_CONTRATUALIZACAO       ,
                    DT_CADASTRO               ,
                    TP_DISPONIBILIDADE        ,
                    SN_URGENCIA_EMERGENCIA    ,
                    CD_REGISTRO_ANS_INTERMED  ,
                    CD_MULTI_EMPRESA )
                    Values
                    (seq_log_vincl_rps_ans.nextval                             ,
                    nvl(:new.cd_prestador_eventual,:old.cd_prestador_eventual) ,
                    'U'                                      ,
                    'N'                                      ,
                    sysdate                                  ,
                    vAlteraNR_CNPJ_CEI                       ,
                    vAlteraDS_NOME                           ,
                    vAlteraCD_CLASSIFICACAO                  ,
                    vAlteraTP_CREDENCIAMENTO                 ,
                    vAlteraTP_CONTRATUALIZACAO               ,
                    vAlteraDT_CADASTRO                       ,
                    vAlteraTP_DISPONIBILIDADE                ,
                    vAlteraURGENCIA_EMERGENCIA               ,
                    vAlteraREGISTROANS_OP_INTERMED           ,
                    DBAMV.PKG_MV2000.LE_EMPRESA             );
          End If;
      End if;
  END IF;
END;


