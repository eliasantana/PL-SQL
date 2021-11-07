--<DS_SCRIPT>
-- DESCRI��O..: Adicionando condi��o l�gica para retorno os reembolsos cujo o valor SN_ENVIO_DMED='S'
-- RESPONSAVEL: Elias Santana
-- DATA.......: 24/09/2020
-- APLICA��O..: MVSAUDE
--</DS_SCRIPT>
--<USUARIO=DBAPS>

CREATE OR REPLACE PROCEDURE dbaps.prc_executa_dmed( P_DMED_ENVIO       IN NUMBER
                                                     , PCD_DMED_ENVIO_INI IN DATE
                                                     , PCD_DMED_ENVIO_FIM IN DATE
                                                     , PCD_MENS_CONTRATO  IN NUMBER   DEFAULT NULL
                                                     , PSN_CONTINUAR      IN VARCHAR2 DEFAULT 'N') IS
  /**************************************************************
    <objeto>
     <nome>prc_executa_dmed</nome>
     <usuario>Elias Santana</usuario>
     <alteracao>14/10/2020</alteracao>
     <ultimaAlteracao>
                Adicionado filtro para os reembolsos cujo o tipo configurado em DBAPS.TIPO_REEMBOLSO no campo SN_ENVIO_DMED='S'
     </ultimaAlteracao>
     <descricao>
            Respons�vel por processar os registros da DMED para futura exporta��o.O objetivo � gerar um arquivo TXT para ser processado pelo software da Receita Federal.
     </descricao>
     <parametro>
       P_DMED_ENVIO       - C�digo do DMED a ser processado
       PCD_DMED_ENVIO_INI - Data inicial
       PCD_DMED_ENVIO_FIM - Data final
       PCD_MENS_CONTRATO  - C�digo da mensalidade (quando existir, n�o vou limpar as tabelas da DMED, vamos incluir os valores na tabela dbaps.dmed_usuario_mens_usuario_mc para comparar os valores)
                            Assim vamos ter a cd_mens_contrato repetida na tabela, para compara��es (ap�s corre��es processar toda a dmed sem esse par�metro)
       PSN_CONTINUAR      - Indica se vai continuar de onde parou ou se vai come�ar do zero (S - Sim / N - N�o)
     </parametro>
     <tags>ANS| DMED</tags>
     <versao>1.2</versao>
     <versaoSistema>V1.149</versaoSistema>
    </objeto>
  ***************************************************************/
    --
    CURSOR cDmed IS
        SELECT CD_DMED_ENVIO, NR_ANO_CALENDARIO
          FROM DBAPS.DMED_ENVIO
         WHERE To_Char(NR_ANO_CALENDARIO, 'YYYY') = To_Char(PCD_DMED_ENVIO_INI, 'YYYY')
           AND CD_MULTI_EMPRESA  = DBAMV.PKG_MV2000.LE_EMPRESA;
    --
    CURSOR cDemdUsuario IS
        SELECT DBAPS.SEQ_DMED_USUARIO.NEXTVAL
          FROM SYS.DUAL;
    --
    CURSOR cLancamentos IS
      SELECT cd_mens_contrato
            ,CD_MATRICULA
            ,CD_CONTRATO
            ,Sum(VL_LANCAMENTO) VL_LANCAMENTO
            ,TP_USUARIO
            ,nr_cpf
            ,dt_nascimento
            ,nm_segurado
            ,cd_matricula_tem
            ,cd_sib
            ,tp_contrato
            ,sn_demitido_aposentado_obito
            ,nr_cpf_cgc
            ,sn_envia_dmed_ir
            ,CD_MATRICULA_CONTRATO
            --,dt_recebimento
            ,sn_qtd
            --Acrescentando o retorno da data de recebimento para usar no credito rateio
            --,dt_rec

            --Como a rotina pode retornar titulos apenas com receitas por contrato (sn_qtd = 'N'), n�o permitir que essas receitas entrem no calculo da mensalidade pq elas v�o estar no credito rateio
            --retornar o valor proporcional pago em cada m�s (Ex.: se o t�tulo tem 2 pagamentos em meses diferentes, retornar o proporcional de cada m�s)
            ,Sum(Case When dt_rec = 1 then Decode(Sign(VL_LANCAMENTO),-1,Decode(Nvl(CD_MATRICULA,-1),-1,0,Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)),
              Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)) else 0 End) mes1
            ,Sum(Case When dt_rec = 2 then Decode(Sign(VL_LANCAMENTO),-1,Decode(Nvl(CD_MATRICULA,-1),-1,0,Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)),
              Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)) else 0 End) mes2
            ,Sum(Case When dt_rec = 3 then Decode(Sign(VL_LANCAMENTO),-1,Decode(Nvl(CD_MATRICULA,-1),-1,0,Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)),
              Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)) else 0 End) mes3
            ,Sum(Case When dt_rec = 4 then Decode(Sign(VL_LANCAMENTO),-1,Decode(Nvl(CD_MATRICULA,-1),-1,0,Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)),
              Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)) else 0 End) mes4
            ,Sum(Case When dt_rec = 5 then Decode(Sign(VL_LANCAMENTO),-1,Decode(Nvl(CD_MATRICULA,-1),-1,0,Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)),
              Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)) else 0 End) mes5
            ,Sum(Case When dt_rec = 6 then Decode(Sign(VL_LANCAMENTO),-1,Decode(Nvl(CD_MATRICULA,-1),-1,0,Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)),
              Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)) else 0 End) mes6
            ,Sum(Case When dt_rec = 7 then Decode(Sign(VL_LANCAMENTO),-1,Decode(Nvl(CD_MATRICULA,-1),-1,0,Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)),
              Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)) else 0 End) mes7
            ,Sum(Case When dt_rec = 8 then Decode(Sign(VL_LANCAMENTO),-1,Decode(Nvl(CD_MATRICULA,-1),-1,0,Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)),
              Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)) else 0 End) mes8
            ,Sum(Case When dt_rec = 9 then Decode(Sign(VL_LANCAMENTO),-1,Decode(Nvl(CD_MATRICULA,-1),-1,0,Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)),
              Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)) else 0 End) mes9
            ,Sum(Case When dt_rec = 10 then Decode(Sign(VL_LANCAMENTO),-1,Decode(Nvl(CD_MATRICULA,-1),-1,0,Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)),
              Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)) else 0 End) mes10
            ,Sum(Case When dt_rec = 11 then Decode(Sign(VL_LANCAMENTO),-1,Decode(Nvl(CD_MATRICULA,-1),-1,0,Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)),
              Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)) else 0 End) mes11
            ,Sum(Case When dt_rec = 12 then Decode(Sign(VL_LANCAMENTO),-1,Decode(Nvl(CD_MATRICULA,-1),-1,0,Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)),
              Round((VL_LANCAMENTO * vl_perc_pago_mes) / 100, 2)) else 0 End) mes12

            --Somat�rio das co-participa��es cobradas na mensalidade de cada benefici�rio
            ,Round(Sum((co_participacao * vl_perc_pago_mes) / 100), 2) co_participacao
            ,Sum(vl_recebimento) vl_recebimento

            --valor total por benefici�rio na mensalidade
            --,Sum(vl_total_benef) vl_total_benef

            --valor total dos itens de receita por benefici�rio na itmens_usuario
            ,vl_total_itmens_usuario
            --,tp_quitacao
            ,vl_total_cobranca
            --,vl_total_pago
            ,sn_existe_receita_por_contrato
          FROM (

            SELECT vfu.cd_mens_contrato

                  ,Nvl( U.CD_MATRICULA, VFU.CD_MATRICULA_CONTRATO ) CD_MATRICULA
                  ,U.CD_CONTRATO
                  --,SUM( Decode(Sign(VFU.VL_MENSALIDADE),-1,Decode(Nvl(VFU.CD_MATRICULA,-1),-1,0,VFU.VL_MENSALIDADE),VFU.VL_MENSALIDADE) ) VL_LANCAMENTO
                  --,SUM( VFU.VL_MENSALIDADE) VL_LANCAMENTO
                  --N�o considerar receitas que sejam apenas POR CONTRATO, pois no final vamos somar essas receitas ao vl_lancamento
                  ,SUM( Decode(lcto.sn_qtd, 'N', 0, VFU.VL_MENSALIDADE)) VL_LANCAMENTO

                  /*,SUM( Decode(lcto.sn_qtd, 'N', 0, VFU.VL_MENSALIDADE / (SELECT Sum(Greatest(Count(dt_receb), 1)) FROM (
                                        SELECT To_Char(mcr.dt_recebimento, 'MM') dt_receb
                                            FROM dbaps.mens_contrato_rec mcr, dbaps.mens_contrato mcc
                                          WHERE mcr.cd_mens_contrato = vfu.cd_mens_contrato
                                            AND mcr.dt_estorno is NULL AND Nvl(mcr.sn_contabiliza, 'S') = 'S'
                                            AND mcr.cd_mens_contrato = mcc.cd_mens_contrato
                                            AND ( EXISTS (SELECT 1
                                                              FROM dbamv.reccon_rec rec
                                                              WHERE rec.cd_reccon_rec = mcr.cd_reccon_rec
                                                                AND rec.TP_RECEBIMENTO <> 'B')
                                                          --ou pegar as de baixa cont�bil se a flag estiver marcada (1� mensalidade ela � marcada)
                                                          OR mcc.sn_forca_dmed = 'S')
                                            GROUP BY To_Char(mcr.dt_recebimento, 'MM'))
                                      GROUP BY dt_receb)

                    )) VL_LANCAMENTO */

                  ,Nvl( U.TP_USUARIO,  'T' )  TP_USUARIO
                  ,Nvl(LPad(u.nr_cpf,11,'0'),0) nr_cpf
                  ,u.dt_nascimento
                  ,u.nm_segurado
                  ,u.cd_matricula_tem
                  ,g.cd_sib
                  ,c.tp_contrato
                  ,c.sn_demitido_aposentado_obito
                  ,c.nr_cpf_cgc
                  ,p.sn_envia_dmed_ir
                  ,c.cd_matricula CD_MATRICULA_CONTRATO
                  --,mcr.dt_recebimento
                  ,lcto.sn_qtd sn_qtd
                  --Acrescentando o retorno da data de recebimento para usar no credito rateio
                  ,To_Number(To_Char(mcr.dt_recebimento,'MM')) dt_rec

                  --Somat�rio das co-participa��es cobradas na mensalidade de cada benefici�rio
                  ,(SELECT Sum(it.vl_lancamento)
                        FROM dbaps.itmens_usuario it
                            ,dbaps.mens_usuario mu
                      WHERE it.cd_mens_usuario = mu.cd_mens_usuario
                        AND mu.cd_mens_contrato = vfu.cd_mens_contrato
                        AND mu.cd_matricula = Nvl( U.CD_MATRICULA, VFU.CD_MATRICULA_CONTRATO )
                        AND it.CD_LCTO_MENSALIDADE = (SELECT CD_GRUPO_FRANQUIA FROM DBAPS.PLANO_DE_SAUDE WHERE ID = 1)) co_participacao --VALOR TOTAL DE COPART POR BENEF

                  ,mcr.vl_recebimento vl_recebimento --VALOR RECEBIDO POR COMPETENCIA

                  --valor total por benefici�rio na mensalidade
                  /*,(SELECT Sum(it.vl_lancamento) FROM dbaps.mens_usuario mu, dbaps.itmens_usuario it
                      WHERE mu.cd_mens_contrato = vfu.cd_mens_contrato
                        AND mu.cd_mens_usuario = it.cd_mens_usuario
                        AND mu.cd_matricula = Nvl( U.CD_MATRICULA, VFU.CD_MATRICULA_CONTRATO )) vl_total_benef*/

                  --valor total dos itens por benefici�rio na mensalidade
                  ,(SELECT Sum(it.vl_lancamento) FROM dbaps.mens_usuario mu, dbaps.itmens_usuario it
                      WHERE mu.cd_mens_contrato = vfu.cd_mens_contrato
                        AND mu.cd_mens_usuario = it.cd_mens_usuario) vl_total_itmens_usuario

                  --,VFU.tp_quitacao
                  --pegar o percentual proporcional do valor pago no m�s da mensalidade
                  ,( mcr.vl_recebimento * 100) /
                      (SELECT Sum(it.vl_lancamento) FROM dbaps.itmens_contrato it
                        WHERE it.cd_mens_contrato = vfu.cd_mens_contrato) vl_perc_pago_mes

                  ,(VFU.vl_total_cobrado + VFU.vl_acrescimo + VFU.vl_desconto) vl_total_cobranca --valor total cobrado
                  --,VFU.vl_total_pago --valor total pago

                  --Verificar se na mensalidade existe receita por contrato (que n�o est� na dbaps.itmens_usuario)
                  ,(SELECT 'S' FROM dbaps.itmens_contrato it
                      WHERE it.cd_mens_contrato = vfu.cd_mens_contrato
                        AND it.vl_lancamento <> 0
                        AND NOT EXISTS (SELECT 1 FROM dbaps.mens_usuario mu, dbaps.itmens_usuario itu
                                          WHERE mu.cd_mens_contrato = it.cd_mens_contrato
                                            AND mu.cd_mens_usuario = itu.cd_mens_usuario
                                            AND itu.cd_lcto_mensalidade = it.cd_lcto_mensalidade)
                        AND ROWNUM = 1
                   ) sn_existe_receita_por_contrato

                FROM DBAPS.V_FATURAMENTO_USUARIO VFU
                    ,DBAPS.USUARIO U
                    ,dbaps.contrato c
                    ,dbaps.grau_parentesco g
                    ,(SELECT mcr.cd_mens_contrato, mcr.dt_recebimento, Sum(mcr.vl_recebimento) vl_recebimento
                          FROM dbaps.mens_contrato_rec mcr
                        where mcr.dt_estorno is NULL
                          AND Nvl(mcr.sn_contabiliza, 'S') = 'S'
                          AND mcr.vl_recebimento > 0
                          --AND To_Char(MCR.DT_RECEBIMENTO, 'YYYY') = '2019' -- To_Char(PCD_DMED_ENVIO_INI, 'YYYY')
                          AND MCR.DT_RECEBIMENTO BETWEEN PCD_DMED_ENVIO_INI AND PCD_DMED_ENVIO_FIM
                          --pegar as mensalidades que exista algum recebimento sem ser baixa contabil
                          AND (EXISTS (SELECT 1
                                            FROM dbamv.reccon_rec rec
                                            WHERE rec.cd_reccon_rec = mcr.cd_reccon_rec
                                              AND rec.TP_RECEBIMENTO <> 'B')
                                --ou pegar as de baixa cont�bil se a flag estiver marcada (1� mensalidade ela � marcada)
                                OR mcr.sn_forca_dmed = 'S')
                        GROUP BY mcr.cd_mens_contrato, mcr.dt_recebimento
                        ) mcr

                    ,dbaps.lcto_mensalidade lcto  --RBCS
                    ,dbaps.plano p
              WHERE vfu.cd_contrato = c.cd_contrato
                AND vfu.cd_plano = p.cd_plano
                AND (C.TP_CONTRATO NOT IN ('E', 'U') OR C.SN_FORCA_ENVIO_DMED = 'S')
                --AND VFU.CD_LCTO_MENSALIDADE <> (SELECT CD_CREDITO_A_MAIOR FROM DBAPS.PLANO_DE_SAUDE WHERE ID = 1)
                --AND VFU.CD_LCTO_MENSALIDADE <> (SELECT CD_ITEM_JUROS FROM DBAMV.MULTI_EMPRESAS_MV_SAUDE WHERE CD_MULTI_EMPRESA = U.CD_MULTI_EMPRESA)
                --AND VFU.CD_LCTO_MENSALIDADE <> (SELECT CD_ITEM_MULTA FROM DBAMV.MULTI_EMPRESAS_MV_SAUDE WHERE CD_MULTI_EMPRESA = U.CD_MULTI_EMPRESA)
                --AND VFU.CD_LCTO_MENSALIDADE NOT IN (SELECT NVL(CD_ITEM_DESC_JUROS_MULTA, -1) FROM DBAMV.MULTI_EMPRESAS_MV_SAUDE WHERE CD_MULTI_EMPRESA = U.CD_MULTI_EMPRESA)
                AND VFU.CD_LCTO_MENSALIDADE <> VFU.CD_CREDITO_A_MAIOR
                AND VFU.CD_LCTO_MENSALIDADE <> VFU.CD_ITEM_JUROS
                AND VFU.CD_LCTO_MENSALIDADE <> VFU.CD_ITEM_MULTA
                AND VFU.CD_LCTO_MENSALIDADE <> VFU.CD_ITEM_DESC_JUROS_MULTA
                --AND InStr(PCD_ITENS_RECEITAS_JUROS, ',' || VFU.CD_LCTO_MENSALIDADE || ',') = 0
                --AND DECODE(NVL(VFU.CD_MATRICULA,-1), -1, DBAPS.FNC_RETORNA_BENEFICIARIO_ATIVO(VFU.CD_MATRICULA_CONTRATO),VFU.CD_MATRICULA) = U.CD_MATRICULA
                AND DECODE(NVL(VFU.CD_MATRICULA,-1), -1, DBAPS.FNC_RETORNA_BENEFICIARIO_ATIVO(VFU.CD_MATRICULA_CONTRATO, VFU.CD_CONTRATO),VFU.CD_MATRICULA) = U.CD_MATRICULA
                AND G.CD_PARENTESCO(+) = U.CD_PARENTESCO
                --AND VFU.CD_MATRICULA <> - 1
                AND VFU.CD_MENS_CONTRATO = MCR.CD_MENS_CONTRATO
                AND VFU.CD_MULTI_EMPRESA = DBAMV.PKG_MV2000.LE_EMPRESA
                AND NVL( U.CD_MATRICULA, VFU.CD_MATRICULA_CONTRATO ) IS NOT NULL
                --AND MCR.DT_RECEBIMENTO BETWEEN PCD_DMED_ENVIO_INI AND PCD_DMED_ENVIO_FIM
                AND vfu.cd_lcto_mensalidade = lcto.cd_lcto_mensalidade    --RBCS
                --AND vfu.cd_mens_contrato = Nvl(PCD_MENS_CONTRATO, vfu.cd_mens_contrato)
                AND vfu.cd_mens_contrato IN (SELECT DISTINCT mens.cd_mens_contrato FROM dbaps.mens_contrato mens WHERE mens.dt_cancelamento IS NULL AND cd_multi_empresa = DBAMV.PKG_MV2000.LE_EMPRESA)
                --AND vfu.cd_mens_contrato = Nvl(7171831, vfu.cd_mens_contrato)
                --retirado o vfu.sn_lcto_recebimento = 'N' pq o desconto e credito rateio v�o pegar esses valores tbm (independente se ta 'S' ou 'N')
                --AND (lcto.sn_qtd = 'S' OR vfu.sn_lcto_recebimento = 'N')   --RBCS
                --Pegar todas as mensalidades que tenha receitas por benefici�rio sim e todas que n�o tenham nenhuma receita por benefici�rio (ex: titulo de repactua��o)
                --Os titulos que tem apenas receitas por contrato, os valores v�o entrar apenas em credito rateio
                --AND vfu.cd_mens_contrato = 1065279
                AND (lcto.sn_qtd = 'S'
                    OR NOT EXISTS (SELECT 1 FROM dbaps.itmens_contrato it, dbaps.lcto_mensalidade lcto2
                                  WHERE lcto2.cd_lcto_mensalidade = it.cd_lcto_mensalidade
                                    AND lcto2.sn_qtd = 'S'
                                    AND it.cd_mens_contrato = VFU.cd_mens_contrato))
                --Excluir as receitas que est�o configuradas na tabela de exclus�o da DMED
                AND NOT EXISTS (SELECT 1 FROM DBAPS.LCTO_MENSALIDADE_EXCLUSAO_DMED lmed
                                  WHERE lmed.cd_lcto_mensalidade = vfu.cd_lcto_mensalidade
                                    AND lmed.cd_multi_empresa = VFU.CD_MULTI_EMPRESA)
                --AND mcr.vl_recebimento > 0 --RBCS
                --Receitas que n�o s�o contabilizadas n�o v�o para DMED e IR
                AND NOT EXISTS (SELECT 1 from dbaps.plano_lcto_mensalidade
                                WHERE cd_plano = VFU.cd_plano AND cd_lcto_mensalidade = vfu.cd_lcto_mensalidade)


              GROUP BY Nvl( U.CD_MATRICULA, VFU.CD_MATRICULA_CONTRATO )
                      ,U.CD_CONTRATO
                      ,Nvl( U.TP_USUARIO,  'T')
                      ,vfu.cd_mens_contrato
                      ,u.nr_cpf
                      ,u.dt_nascimento
                      ,u.nm_segurado
                      ,u.cd_matricula_tem
                      ,g.cd_sib
                      ,lcto.sn_qtd
                      ,To_Number(To_Char(mcr.dt_recebimento,'MM'))
                      ,c.tp_contrato
                      ,c.sn_demitido_aposentado_obito
                      ,c.nr_cpf_cgc
                      ,p.sn_envia_dmed_ir
                      ,c.cd_matricula
                      ,mcr.dt_recebimento
                      --,VFU.tp_quitacao
                      ,mcr.vl_recebimento
                      ,(VFU.vl_total_cobrado + VFU.vl_acrescimo + VFU.vl_desconto)
                      --,VFU.vl_total_pago
          )
        GROUP BY cd_mens_contrato
                ,CD_MATRICULA
                ,CD_CONTRATO
                ,VL_LANCAMENTO
                ,TP_USUARIO
                ,nr_cpf
                ,dt_nascimento
                ,nm_segurado
                ,cd_matricula_tem
                ,cd_sib
                ,tp_contrato
                ,sn_demitido_aposentado_obito
                ,nr_cpf_cgc
                ,sn_envia_dmed_ir
                ,CD_MATRICULA_CONTRATO
                ,sn_qtd
                --,dt_rec
                --,co_participacao
                --,vl_total_benef
                ,vl_total_itmens_usuario
                --,tp_quitacao
                ,vl_total_cobranca
                --,vl_total_pago
                ,sn_existe_receita_por_contrato
        ORDER BY CD_CONTRATO ASC, CD_MENS_CONTRATO ASC, TP_USUARIO DESC, CD_MATRICULA ASC;

--10:22 - 10:36
--16:18 - 18:21
/**
  --FORMA NOVA (ATUAL)

  - CO_PARTICIPACAO: ter� o valor total de copart do benefici�rio proporcional ao recebimento
  - VL_TOTAL_ITMENS_USUARIO: Valor total dos itens por benefici�rio na mensalidade (Utilizado para calcular o proporcional do acres/desc por m�s)
  - VL_LANCAMENTO: Valor do somat�rio dos itens de receita por benefici�rio de cada benefici�rio
  - VL_PERC_PAGO_MES: Valor percentual proporcional ao recebimento pelo valor total cobrado (com acres/desc)
  - MES1, MES2...: Valor proporcional (do cobrado pelo pago) em cada m�s para cada benefici�rio da mensalidade
  - Acr�scimo e Descontos proporcionais ser�o calculados fora do cursor

  Exemplo de mens com mais de um recebimento em meses diferentes 5804964 (marquei o for�ar DMED para ir)
  - o cursor vai retornar uma linha para cada benefici�rio da mensalidade
  - j� � feito o calculo do valor proporcional de cada m�s de acordo com o valor recebido em cada m�s,
    ent�o MES1, MES2... j� est�o com o valor correto para os itens de receita por benefici�rio (que est�o na dbaps.itmens_usuario)

  E SE O PAGAMENTO FOR PARCIAL?  exemplo: 7282514
  no VL_LANCAMENTO vem o valor cobrado por benefici�rio, � feito o proporcional com o recebimento daquele m�s e adicionado a MES1, MES2, MES3...

  --BAIXA CONTABIL ESTAVA SENDO TRATADA COMO DESCONTO NA ROTINA ANTERIOR
  --NESSA ROTINA, OS VALORES EST�O SENDO CALCULADOS COM BASE NO VALOR RECEBIDO (SEM A BAIXA CONTABIL), ENT�O N�O PRECISAMOS LANCAR ELA COMO DESCONTO


  --FORMA PENSADA ANTIGA
  Exemplo de mens com mais de um recebimento em meses diferentes 5804964 (contrato Empresarial, comentar a linha p testar)

  TRAZENDO A DATA DE RECEBIMENTO
  1 mensalidade com 3 benefici�rios e 2 recebimentos v�lidos
  Nessas condi��es o cursor vai retornar para essa mensalidade 6 linhas (2 x para cada benefici�rio devido ao ter 2 recebimentos)
  cada linha vai ter valor em um m�s (ou no mesmo m�s dependendo da data de recebimento)
  - o VL_LANCAMENTO, CO_PARTICIPACAO, VL_TOTAL_BENEF e VL_TOTAL_ITMENS_USUARIO n�o podemos somar mais de uma vez para cada mensalidade
  - o VL_RECEBIMENTO vai ser 1 para cada recebimento

  SEM A DATA DE RECEBIMENTO - OPCAO UTILIZADA
  1 mensalidade com 3 benefici�rios e 2 recebimentos v�lidos
  Nessas condi��es o cursor vai retornar para essa mensalidade 3 linhas
  Caso tenha recebimentos em meses diferentes, a rotina est� trazendo o valor real para cada m�s, ex: Mensalidade de 100,00 paga m�s 03 20,00 / m�s 04 30,00 / m�s 05 50,00,
  para os 3 meses vai trazer 100,00 no VL_LANCAMENTO
  - vamos precisar pegar o valor proporcinal pago por cada benefici�rio em cada m�s
    - valor total pago por valor pago por m�s: W = (valor por m�s x 100 ) / valor total pago => isso vai dar o percentual por m�s
    --                                         w = (valor total pago X 100) / valor por m�s
    - pegar o valor proporcional de cada m�s: (valor total do benef x W (percentual do vl_pago por m�s)) / 100... m�s 3 (100,00 x 20) / 100 => valor do m�s 3
                                                                                                                  m�s 4 (100,00 x 30) / 100 => valor do m�s 4
                                                                                                                  m�s 5 (100,00 x 50) / 100 => valor do m�s 5

  E SE O PAGAMENTO FOR PARCIAL?  exemplo: 7282514
  no VL_LANCAMENTO vem o valor cheio (cobrado por benef)
  depois temos que diminuir nos meses e no valor total o desconto do n�o pagamento de uma parte

  DESCONTOS A RATEAR (aplicar no valor total e nos valores dos meses)
  - Pagamento parcial
  - desconto de item de receita por contrato (caso tenha mais de um recebimento em meses diferentes fazer a propor��o)
  - baixa contabil (quando existir baixa normal na mensalidade) -> a baixa cont�bil ser� tratada como desconto

  CREDITOS A RATEAR (aplicar no valor total e nos valores dos meses)
  - Acr�scimo por item de receita Por Contrato (caso tenha mais de um recebimento em meses diferentes fazer a propor��o)
  - Mensalidade de repactua��o (s� tem a receita Por Contrato) -> dar uma forma de ratear esse valor entre os benefici�rios da mensalidade que foi repactuada
    ou mudar a repactua��o e colocar a receita Por benefici�rio e colocar os benefici�rios na mensalidade


  L�GICA
  - Pegar o proporcional dos recebimentos de cada m�s (valor pago no m�s X valor pago total)
  - pegar proporcional de cr�dito e d�bito
  - colocar em cada m�s o valor pago, o cr�dito e o d�bito proporcional em cada m�s
*/

/*SELECT * FROM dbaps.mens_contrato mc WHERE tp_quitacao = 'P' AND cd_multi_empresa = 4
AND NOT EXISTS (SELECT 1 FROM dbaps.itmens_contrato it
                    WHERE it.cd_mens_contrato = mc.cd_mens_contrato
                      AND vl_lancamento < 0)
ORDER BY 1 DESC

SELECT * FROM dbaps.itmens_contrato WHERE cd_mens_contrato = 7289411

SELECT * FROM dbaps.mens_contrato WHERE cd_mens_contrato = 7289411

SELECT * FROM dbaps.mens_usuario WHERE cd_mens_contrato = 7289411

select * from dbaps.itmens_usuario where cd_mens_usuario = 14616613

select * from dbaps.lcto_mensalidade where cd_lcto_mensalidade in (1, 35)

SELECT * FROM dbaps.mens_contrato_rec WHERE cd_mens_contrato = 7289411  */


/*****************************
coisas a considerar na DMED
******************************/
/*
- mensalidades de repactua��o, ao ratear o valor entre os benefici�rios, esse valor deve ir sem o juros (q � incluido na mensalidade original ao fazer a repactuacao)
  o rateio deve ser feito proporcional ao valor original da mensalidade que foi repactuada
- mensalidade com baixa contabil parcial (tendo outro tipo de baixa), essa baixa contabil deve ser considerada como desconto
  (mudei o desconto real e desconto rateio para receber tbm a baixa contabil, deixou a rotina do DMED muito lenta)
  ESSA BAIXA N�O VAI SER CONSIDERADA NA DMED E OS VALORES UTILIZADOS SER�O COM BASE APENAS NO RECEBIMENTO SEM BAIXAS CONTABEIS
  SE NECESS�RIO, SETAR A FLAG DE FORCAR A BAIXA CONTABIU IR NA DMED (DBAPS.MENS_CONTRATO_REC.SN_FORCA_DMED = 'S')
- Quando a mensalidade tem muitos recebimentos, os valores s�o multiplicados (tive q colocar a verifica��o da baixa contabil dentro do subselect)
  ESSE PROBLEMA J� N�O EXISTE MAIS

--Teste
- Matriculas de benefici�rios q ficaram com o valor total ano negativo 681130211,583400256, 685650201, 239210131 (SOROCABA)
- Mensalidade com valor com baixa contabil parcial 1065279 (SOROCABA)
-



  - ratear os cr�ditos e d�bitos/baixas contabeis parciais
  (para isso, a query abaixo precisa trazer o valor pago total 'sem baixa contabil' de cada mensalidade)
   - pegar todas as mensalidades (com todas as condi��es)
*/






    /**
     *  Busca os reembolsos do Beneficiario
     * 23/01/2019
     */
    CURSOR cReembolso (PCDMATRICULA IN NUMBER, PNR_ANO IN DATE) IS
      SELECT TABELA.CD_MATRICULA,
             TABELA.NR_CPF_CNPJ,
             SUM(TABELA.VL_PAGO) VL_PAGO
       FROM (
           SELECT R.CD_REEMBOLSO
                ,R.CD_MATRICULA
                ,Nvl(NVL(R.NR_CPF_CNPJ,PRE.NR_CPF_CGC), ME.NR_CGC_ANS) NR_CPF_CNPJ
                ,Decode(Sign((SELECT NVL(SUM(PAGCON_PAG.VL_PAGO),0)
                  FROM DBAMV.PAGCON_PAG,
                      DBAMV.ITCON_PAG
                  WHERE ITCON_PAG.CD_ITCON_PAG = PAGCON_PAG.CD_ITCON_PAG
                    AND Trunc(R.DT_ATENDIMENTO, 'YYYY') = Trunc(PNR_ANO,'YYYY')
                    AND ITCON_PAG.CD_CON_PAG = R.CD_CON_PAG)), 1, Sum(IR.vl_procedimento-IR.vl_coparticipacao), 0)  VL_PAGO,
                (SELECT MAX(PAGCON_PAG.DT_PAGAMENTO)
                  FROM DBAMV.PAGCON_PAG,
                    DBAMV.ITCON_PAG
                  WHERE ITCON_PAG.CD_ITCON_PAG = PAGCON_PAG.CD_ITCON_PAG
                    AND ITCON_PAG.CD_CON_PAG = R.CD_CON_PAG) DT_PAGAMENTO ,
                R.CD_CON_PAG
          FROM DBAPS.REEMBOLSO R,
               DBAPS.ITREEMBOLSO IR,
               DBAPS.PROCEDIMENTO P,
               DBAPS.USUARIO U,
               DBAPS.PRESTADOR PRE,
               DBAPS.TIPO_REEMBOLSO TR,
               DBAMV.MULTI_EMPRESAS_MV_SAUDE ME
          WHERE R.CD_MATRICULA = U.CD_MATRICULA (+)
              AND R.CD_REEMBOLSO = IR.CD_REEMBOLSO
              AND R.CD_TIPO_REEMBOLSO = TR.CD_TIPO_REEMBOLSO
              AND IR.CD_PROCEDIMENTO = P.CD_PROCEDIMENTO
              AND Nvl(P.SN_ISENTO_TRIB_REEMBOLSO,'N') = 'N'
              AND R.CD_MULTI_EMPRESA = ME.CD_MULTI_EMPRESA
              AND TR.SN_ENVIO_DMED = 'S'
              AND R.CD_PRESTADOR = PRE.CD_PRESTADOR (+)
              AND ME.CD_MULTI_EMPRESA = DBAMV.PKG_MV2000.LE_EMPRESA
              AND (Trunc(R.DT_ATENDIMENTO, 'YYYY') = Trunc(PNR_ANO,'YYYY')
                  OR Trunc(R.DT_ATENDIMENTO, 'YYYY') = Trunc(PNR_ANO-1,'YYYY'))
              AND R.cd_matricula = PCDMATRICULA
              --GARANTIR QUE O MESMO BENEFICI�RIO N�O VAI INCLUIR O REEMBOLSO MAIS DE UMA VEZ
              AND NOT EXISTS (SELECT 1 FROM DBAPS.DMED_USUARIO_REEMBOLSO DUR
                                WHERE DUR.CD_MATRICULA = R.CD_MATRICULA
                                  AND DUR.CD_DMED_ENVIO = P_DMED_ENVIO)
          GROUP BY R.CD_REEMBOLSO,
                PRE.NM_PRESTADOR,
                R.CD_MATRICULA,
                R.DT_ATENDIMENTO,
                R.NR_CPF_CNPJ,
                PRE.NR_CPF_CGC,
                R.DS_PRESTADOR,
                R.CD_CON_PAG,
                ME.NR_CGC_ANS
        ) TABELA
      WHERE DT_PAGAMENTO IS NOT NULL
            AND TRUNC(DT_PAGAMENTO) BETWEEN PCD_DMED_ENVIO_INI AND PCD_DMED_ENVIO_FIM
            --AND Trunc(DT_PAGAMENTO, 'YYYY') = Trunc(PNR_ANO,'YYYY')
            --AND VL_PAGO > 0
      GROUP BY cd_matricula
               ,nr_cpf_cnpj
      ORDER BY nr_cpf_cnpj;

    /**
     *  Busca os reembolsos do Beneficiario
     * 23/01/2019
     */
    CURSOR cReembolsoAnosAnteriores (PCDMATRICULA IN NUMBER, PNR_ANO IN DATE, PNR_CPF_CNPJ IN VARCHAR2) IS
      SELECT SUM(TABELA.VL_PAGO) VL_PAGO
       FROM (
           SELECT R.CD_REEMBOLSO
                ,R.CD_MATRICULA
                ,NVL(R.NR_CPF_CNPJ,P.NR_CPF_CGC) NR_CPF_CNPJ
                ,Decode(Sign((SELECT NVL(SUM(PAGCON_PAG.VL_PAGO),0)
                  FROM DBAMV.PAGCON_PAG,
                      DBAMV.ITCON_PAG
                  WHERE ITCON_PAG.CD_ITCON_PAG = PAGCON_PAG.CD_ITCON_PAG
                    AND ITCON_PAG.CD_CON_PAG = R.CD_CON_PAG)), 1, Sum(IR.vl_procedimento-IR.vl_coparticipacao), 0)  VL_PAGO,
                (SELECT MAX(PAGCON_PAG.DT_PAGAMENTO)
                  FROM DBAMV.PAGCON_PAG,
                    DBAMV.ITCON_PAG
                  WHERE ITCON_PAG.CD_ITCON_PAG = PAGCON_PAG.CD_ITCON_PAG
                AND ITCON_PAG.CD_CON_PAG = R.CD_CON_PAG) DT_PAGAMENTO ,
                R.CD_CON_PAG
          FROM DBAPS.REEMBOLSO R,
               DBAPS.ITREEMBOLSO IR,
               DBAPS.PROCEDIMENTO P,
               DBAPS.USUARIO U,
               DBAPS.PRESTADOR P,
               DBAPS.TIPO_REEMBOLSO TR,   -- ALTERADO - ADICIONADO
               DBAMV.MULTI_EMPRESAS_MV_SAUDE ME
          WHERE R.CD_MATRICULA = U.CD_MATRICULA (+)
              AND R.CD_REEMBOLSO = IR.CD_REEMBOLSO
              AND R.CD_TIPO_REEMBOLSO = TR.CD_TIPO_REEMBOLSO --ALTERADO - ADICIONADO
              AND IR.CD_PROCEDIMENTO = P.CD_PROCEDIMENTO
              AND Nvl(P.SN_ISENTO_TRIB_REEMBOLSO,'N') = 'N'
              AND R.CD_MULTI_EMPRESA = ME.CD_MULTI_EMPRESA
              AND TR.SN_ENVIO_DMED = 'S'  --ALTERADO - ADICIONADO
              AND R.CD_PRESTADOR = P.CD_PRESTADOR (+)
              AND ME.CD_MULTI_EMPRESA = DBAMV.PKG_MV2000.LE_EMPRESA
              AND Trunc(R.DT_ATENDIMENTO, 'YYYY') < Trunc(PNR_ANO,'YYYY')
              AND R.cd_matricula = PCDMATRICULA
              AND NVL(R.NR_CPF_CNPJ,P.NR_CPF_CGC) = PNR_CPF_CNPJ
          GROUP BY R.CD_REEMBOLSO,
                P.NM_PRESTADOR,
                R.CD_MATRICULA,
                R.DT_ATENDIMENTO,
                R.NR_CPF_CNPJ,
                P.NR_CPF_CGC,
                R.DS_PRESTADOR,
                R.CD_CON_PAG
        ) TABELA
      WHERE DT_PAGAMENTO IS NOT NULL
            AND TRUNC(DT_PAGAMENTO) BETWEEN PCD_DMED_ENVIO_INI AND PCD_DMED_ENVIO_FIM
            --AND Trunc(DT_PAGAMENTO, 'YYYY') < Trunc(PNR_ANO,'YYYY')
            AND VL_PAGO > 0
      GROUP BY cd_matricula
               ,nr_cpf_cnpj
      ORDER BY nr_cpf_cnpj;


    --Cursor para verificar se o valor de reembolso do ano anterior vai zerado (S) ou igual ao desse ano (N)
    CURSOR cConfiguracao IS
      SELECT SN_REEMBOLSO_DMED_ANTERIOR_ZER, SN_DMED_TITULARES_POR_CNTR
          FROM DBAMV.MULTI_EMPRESAS_MV_SAUDE ME
        WHERE cd_multi_empresa = DBAMV.PKG_MV2000.LE_EMPRESA;

    --
    /**
     * Encontra a descricao de um prestador a partir do seu CPF/CNPJ
     * - 1 op��o: reembolsos com cd_prestador not null
     * - 2 op��o: reembolso com ds_prestador not null
     * Como varios reembolsos podem possuir o CPF... retorne a primeira op��o encontrada
     */
    CURSOR cDescricaoPrestador(P_NR_CPF_CNPJ IN VARCHAR2) IS
      SELECT SubStr(regexp_replace(NM_PRESTADOR, '[^[:alpha:] ]+'),1,150) NM_PRESTADOR
          FROM (
              -- buscando primeira descricao do prestador que possua cd_prestador not null
              (SELECT Nvl(P.NM_PRESTADOR, R.DS_PRESTADOR) NM_PRESTADOR
                    FROM DBAPS.REEMBOLSO R, DBAPS.PRESTADOR P
                  WHERE R.CD_PRESTADOR = P.CD_PRESTADOR (+)
                    AND R.NR_CPF_CNPJ = P_NR_CPF_CNPJ
                    AND R.CD_PRESTADOR IS NOT NULL
                    AND ROWNUM = 1)
              UNION ALL
              -- buscando primeira descricao do prestador que possua nr_cpf_cnpj not null
              (SELECT R.DS_PRESTADOR NM_PRESTADOR
                    FROM DBAPS.REEMBOLSO R
                WHERE R.NR_CPF_CNPJ =  P_NR_CPF_CNPJ
                  AND R.DS_PRESTADOR IS NOT NULL
                  AND ROWNUM = 1)
          ) WHERE ROWNUM = 1;

    --BENEFICIARIOS PARA VALIDA��O
    CURSOR cBeneficiarios (PCD_DMED_ENVIO NUMBER) IS
        SELECT D.CD_MATRICULA
              ,LPad(U.NR_CPF,11,'0') NR_CPF
          FROM DBAPS.USUARIO U
              ,DBAPS.DMED_USUARIO D
              ,DBAPS.DMED_ENVIO E
          WHERE U.CD_MATRICULA = D.CD_MATRICULA
            AND D.CD_DMED_ENVIO = E.CD_DMED_ENVIO
            AND U.CD_MULTI_EMPRESA = DBAMV.PKG_MV2000.LE_EMPRESA
            AND E.CD_DMED_ENVIO = PCD_DMED_ENVIO
      ORDER BY D.CD_MATRICULA;

    --DEPENDENTES POR CPF DIGITOS ERRADOS
    CURSOR cDependentesDigitosInvalido (PCD_MATRICULA NUMBER, PCD_DMED_ENVIO NUMBER) IS
        SELECT D.CD_MATRICULA
              ,LPad(U.NR_CPF,11,'0') NR_CPF
          FROM DBAPS.USUARIO U
              ,DBAPS.DMED_USUARIO D
              ,DBAPS.DMED_ENVIO E
         WHERE U.CD_MATRICULA = D.CD_MATRICULA
           AND D.CD_DMED_ENVIO = E.CD_DMED_ENVIO
           AND D.SN_ENVIO = 'S'
           AND U.CD_MULTI_EMPRESA = DBAMV.PKG_MV2000.LE_EMPRESA
           AND E.CD_DMED_ENVIO = PCD_DMED_ENVIO
           AND U.CD_MATRICULA = PCD_MATRICULA
           AND Decode(U.SN_TITULAR, 'S', 18, dbaps.FNC_MVS_IDADE(U.DT_NASCIMENTO,sysdate)) > 17
           AND Decode(U.NR_CPF, NULL, 0, dbaps.valida_cpf_cnpj(LPad(U.NR_CPF,11,'0'))) = 0;
           /*AND U.NR_CPF IN ( '00000000000'
                            ,'11111111111'
                            ,'22222222222'
                            ,'33333333333'
                            ,'44444444444'
                            ,'55555555555'
                            ,'66666666666'
                            ,'77777777777'
                            ,'88888888888'
                            ,'99999999999');*/
    --DEPENDENTES
    CURSOR cDependentesNaoGerados (PCD_MATRICULA NUMBER, PCD_DMED_ENVIO NUMBER) IS
        SELECT D.CD_MATRICULA
              ,LPad(U.NR_CPF,11,'0') NR_CPF
          FROM DBAPS.USUARIO U
              ,DBAPS.DMED_USUARIO D
              ,DBAPS.DMED_ENVIO E
         WHERE U.CD_MATRICULA = D.CD_MATRICULA
           AND D.CD_DMED_ENVIO = E.CD_DMED_ENVIO
           AND D.SN_ENVIO = 'S'
           AND U.CD_MULTI_EMPRESA = DBAMV.PKG_MV2000.LE_EMPRESA
           AND E.CD_DMED_ENVIO = PCD_DMED_ENVIO
           AND U.CD_MATRICULA_TEM = PCD_MATRICULA;

    --verificar configura��o dos itens de juros e multa
    CURSOR cConfig IS
        SELECT 1
          FROM dbamv.multi_empresas_mv_saude
        WHERE cd_multi_empresa = DBAMV.PKG_MV2000.LE_EMPRESA
          AND CD_ITEM_JUROS IS NOT NULL
          AND CD_ITEM_MULTA IS NOT NULL
          AND EXISTS (SELECT 1 FROM dbaps.plano_de_saude WHERE id = 1 AND CD_CREDITO_A_MAIOR IS NOT NULL);

    --verificar dependentes sem parentesco para criticar
    CURSOR cDependParent IS
      SELECT D.cd_matricula
        FROM dbaps.usuario u
          , dbaps.dmed_usuario d
      WHERE u.tp_usuario NOT IN ('T')
        AND D.CD_MATRICULA     = U.CD_MATRICULA
        AND u.CD_PARENTESCO IS null
        AND U.CD_MULTI_EMPRESA = DBAMV.PKG_MV2000.LE_EMPRESA
        AND D.CD_DMED_ENVIO     = P_DMED_ENVIO;

    --Verificar cpf's duplicados que n�o tem o mesmo nome ou data de nascimento
    CURSOR cCpfDuplicado IS
      SELECT DISTINCT cd_matricula, nr_cpf FROM (
        SELECT d.cd_matricula, d.nr_cpf
          FROM dbaps.dmed_usuario d
        WHERE d.cd_dmed_envio = P_DMED_ENVIO
          AND Nvl(d.nr_cpf,0) <> 0
          AND D.CD_MULTI_EMPRESA = DBAMV.PKG_MV2000.LE_EMPRESA
          AND EXISTS (SELECT 1 FROM dbaps.dmed_usuario d2
                        WHERE d2.nr_cpf = d.nr_cpf
                          AND Nvl(d2.nr_cpf,0) <> 0
                          AND d2.cd_dmed_envio = P_DMED_ENVIO
                          AND d2.cd_matricula <> d.cd_matricula
                          AND d2.NM_SEGURADO <> d.NM_SEGURADO
                          /*  OR Trunc(d2.dt_nascimento) <> trunc(d.dt_nascimento))*/
                            )
        UNION
        SELECT d.cd_matricula, d.nr_cpf
          FROM dbaps.dmed_usuario d
        WHERE d.cd_dmed_envio = P_DMED_ENVIO
          AND Nvl(d.nr_cpf,0) <> 0
          AND D.CD_MULTI_EMPRESA = DBAMV.PKG_MV2000.LE_EMPRESA
          AND EXISTS (SELECT 1 FROM dbaps.dmed_usuario d2
                        WHERE d2.nr_cpf = d.nr_cpf
                          AND Nvl(d2.nr_cpf,0) <> 0
                          AND d2.cd_dmed_envio = P_DMED_ENVIO
                          AND d2.cd_matricula <> d.cd_matricula
                          AND Trunc(d2.dt_nascimento) <> trunc(d.dt_nascimento)
                            )
      );

    --Criticar dependentes maiores de 16 anos sem CPF
    --Criticar dependentes maiores de 18 anos sem CPF (Alterado Rafael Lucas 26/02/2020 Conforme Layout DMED)
    CURSOR cDepSemCpf is
      SELECT DISTINCT cd_matricula
          FROM dbaps.dmed_usuario d
        WHERE cd_dmed_envio = P_DMED_ENVIO
          AND tp_usuario <> 'T'
          AND Nvl(nr_cpf,0) = 0
          AND sn_envio = 'S'
          AND D.CD_MULTI_EMPRESA = DBAMV.PKG_MV2000.LE_EMPRESA
          AND TO_NUMBER(SUBSTR(DBAPS.PACK_SGPS_2.RETORNA_IDADE(TRUNC(d.DT_NASCIMENTO),
                                                                TRUNC(sysdate)),
                                1,
                                INSTR(UPPER(DBAPS.PACK_SGPS_2.RETORNA_IDADE(TRUNC(d.DT_NASCIMENTO),
                                                                            TRUNC(sysdate))),
                                      'A') - 1)) > 18;

    --Buscar sequence
    CURSOR cDmedMensUsuMC IS
      SELECT DBAPS.SEQ_DMED_USUARIO_MENS_USU_MC.NEXTVAL
        FROM dual;

    --Verificar se j� existe essa matricula na DMED
    CURSOR cExisteMatriculaDmed(PCD_MATRICULA IN NUMBER) IS
      SELECT 'S', du.cd_dmed_usuario, dumu.cd_dmed_usuario_mens_usuario
          FROM dbaps.dmed_usuario du, dbaps.dmed_usuario_mens_usuario dumu
        WHERE du.cd_dmed_usuario = dumu.cd_dmed_usuario
          AND du.cd_matricula = PCD_MATRICULA
          AND du.cd_dmed_envio = P_DMED_ENVIO
          AND ROWNUM = 1;

    --Verificar se j� existe dados para esse benefici�rio na tabela DBAPS.DMED_USUARIO_MENS_USUARIO_MC
    CURSOR cDmedusuarioMensUsuMC(PCD_DMED_USUARIO_MENS_USUARIO IN NUMBER, PCD_MENS_CONTRATO IN NUMBER) IS
      SELECT cd_dmed_usuario_mens_usu_mc
          FROM dbaps.dmed_usuario_mens_usuario_mc
        WHERE cd_dmed_usuario_mens_usuario = PCD_DMED_USUARIO_MENS_USUARIO
          AND cd_mens_contrato = PCD_MENS_CONTRATO
          AND ROWNUM = 1;

    --pegar sequence da tabela DBAPS.DMED_USUARIO_MENS_USUARIO
    CURSOR cDemdUsuarioMensUsu IS
      SELECT DBAPS.SEQ_DMED_USUARIO_MENS_USUARIO.NEXTVAL
        FROM dual;

    --Buscar somat�rio dos itens de receita de Cr�dito da itmens_contrato que n�o existem na itmens_usuario (na teoria seriam os itens POR CONTRATO, por�m, podem mudar a configura��o da receita)
    CURSOR cCreditoMens(P_CD_MENS_CONTRATO IN NUMBER) IS
      SELECT Sum(vl_lancamento) vl_lancamento
          FROM dbaps.itmens_contrato it
        WHERE NOT EXISTS (SELECT 1 FROM dbaps.mens_usuario mu, dbaps.itmens_usuario itu
                              WHERE mu.cd_mens_contrato = it.cd_mens_contrato
                                AND mu.cd_mens_usuario = itu.cd_mens_usuario
                                AND itu.cd_lcto_mensalidade = it.cd_lcto_mensalidade)
          AND vl_lancamento > 0
          AND cd_mens_contrato = P_CD_MENS_CONTRATO;
          --AND InStr(PCD_ITENS_RECEITAS_JUROS, ',' || it.CD_LCTO_MENSALIDADE || ',') = 0;

    --Buscar somat�rio dos itens de receita de Desconto da itmens_contrato que n�o existem na itmens_usuario (na teoria seriam os itens POR CONTRATO, por�m, podem mudar a configura��o da receita)
    CURSOR cDescontoMens(P_CD_MENS_CONTRATO IN NUMBER) IS
      SELECT Sum(vl_lancamento) vl_lancamento
          FROM dbaps.itmens_contrato it
        WHERE NOT EXISTS (SELECT 1 FROM dbaps.mens_usuario mu, dbaps.itmens_usuario itu
                              WHERE mu.cd_mens_contrato = it.cd_mens_contrato
                                AND mu.cd_mens_usuario = itu.cd_mens_usuario
                                AND itu.cd_lcto_mensalidade = it.cd_lcto_mensalidade)
          AND vl_lancamento < 0
          AND cd_mens_contrato = P_CD_MENS_CONTRATO;
          --AND InStr(PCD_ITENS_RECEITAS_JUROS, ',' || it.CD_LCTO_MENSALIDADE || ',') = 0;

    --Verificar se existe na mensalidade receita por contrato na dbaps.itmens_usuario
    CURSOR cPorContrato(PCD_MENS_CONTRATO IN NUMBER) IS
      SELECT (lcto.cd_lcto_mensalidade||' - '||lcto.ds_lcto_mensalidade) receita
          FROM dbaps.mens_usuario mu, dbaps.itmens_usuario it, dbaps.lcto_mensalidade lcto
        WHERE mu.cd_mens_usuario = it.cd_mens_usuario
          AND it.cd_lcto_mensalidade = lcto.cd_lcto_mensalidade
          AND lcto.sn_qtd = 'N'
          AND mu.cd_mens_contrato = PCD_MENS_CONTRATO;

    --Verificar se existe na mensalidade receita por benefici�rio que n�o est� na dbaps.itmens_usuario
    CURSOR cPorBenef(PCD_MENS_CONTRATO IN NUMBER) IS
      SELECT (lcto.cd_lcto_mensalidade||' - '||lcto.ds_lcto_mensalidade) receita
          FROM dbaps.itmens_contrato it, dbaps.lcto_mensalidade lcto
        WHERE it.cd_lcto_mensalidade = lcto.cd_lcto_mensalidade
          AND it.cd_mens_contrato = PCD_MENS_CONTRATO
          AND lcto.sn_qtd = 'S'
          AND NOT EXISTS (SELECT 1 FROM dbaps.mens_usuario mu, dbaps.itmens_usuario itu
                            WHERE mu.cd_mens_contrato = it.cd_mens_contrato
                              AND mu.cd_mens_usuario = itu.cd_mens_usuario
                              AND itu.cd_lcto_mensalidade = it.cd_lcto_mensalidade);

    --Verificar se o somat�rio dos itens de receita por benefici�rio bate com o somat�rio na itmens_contrato
    CURSOR cSomarItensPorBenef(PCD_MENS_CONTRATO IN NUMBER) IS
      SELECT (vl_lancamento - vl_lancamento_it) vl_diferenca FROM (
        SELECT cd_mens_contrato, Sum(vl_lancamento) vl_lancamento, Sum(vl_lancamento_it) vl_lancamento_it FROM (
          SELECT mu.cd_mens_contrato, Sum(itu.vl_lancamento) vl_lancamento, 0 vl_lancamento_it
              FROM dbaps.mens_usuario mu, dbaps.itmens_usuario itu
            WHERE mu.cd_mens_usuario = itu.cd_mens_usuario
              AND mu.cd_mens_contrato = PCD_MENS_CONTRATO
          UNION ALL
          SELECT it.cd_mens_contrato, 0 vl_lancamento, Sum(it.vl_lancamento) vl_lancamento_it
              FROM dbaps.itmens_contrato it
            WHERE it.cd_mens_contrato = PCD_MENS_CONTRATO
              AND Nvl(it.sn_lcto_recebimento, 'N') = 'N'
              AND EXISTS (SELECT 1 FROM dbaps.mens_usuario mu, dbaps.itmens_usuario itu
                            WHERE mu.cd_mens_usuario = itu.cd_mens_usuario
                              AND mu.cd_mens_contrato = it.cd_mens_contrato
                              AND itu.cd_lcto_mensalidade = it.cd_lcto_mensalidade)
        ) GROUP BY cd_mens_contrato
      ) WHERE vl_lancamento <> vl_lancamento_it;

    --Buscar o somat�rio dos itens por benefici�rio
    /*CURSOR cSumItensBenef(PCD_MENS_CONTRATO IN NUMBER) IS
      SELECT (vl_lancamento - vl_mes) vl_diferenca FROM (
        SELECT cd_mens_contrato, Sum(vl_lancamento) vl_lancamento, Sum(vl_mes) vl_mes FROM (
          SELECT mu.cd_mens_contrato, Sum(it.vl_lancamento) vl_lancamento, 0 vl_mes
              FROM dbaps.mens_usuario mu, dbaps.itmens_usuario it
            WHERE mu.cd_mens_usuario = it.cd_mens_usuario
              AND mu.cd_mens_contrato = PCD_MENS_CONTRATO
            GROUP BY mu.cd_mens_contrato

          UNION ALL

          SELECT mc.cd_mens_contrato, 0 vl_lancamento, Sum(mc.vl_mes1 +
                                                          mc.vl_mes2 +
                                                          mc.vl_mes3 +
                                                          mc.vl_mes4 +
                                                          mc.vl_mes5 +
                                                          mc.vl_mes6 +
                                                          mc.vl_mes7 +
                                                          mc.vl_mes8 +
                                                          mc.vl_mes9 +
                                                          mc.vl_mes10 +
                                                          mc.vl_mes11 +
                                                          mc.vl_mes12) vl_mes
              FROM DBAPS.DMED_USUARIO_MENS_USUARIO_MC mc, dbaps.dmed_usuario_mens_usuario dusu, dbaps.dmed_usuario du
            WHERE mc.cd_mens_contrato = PCD_MENS_CONTRATO
              AND mc.cd_dmed_usuario_mens_usuario = dusu.cd_dmed_usuario_mens_usuario
              AND dusu.cd_dmed_usuario = du.cd_dmed_usuario
              AND du.cd_dmed_envio = P_DMED_ENVIO
            GROUP BY mc.cd_mens_contrato
        )
      ) WHERE Nvl(vl_lancamento, 0) <> Nvl(vl_mes, 0);    */

    --Buscar um benefici�rio da mensalidade para colocar a diferen�a
    /*CURSOR cDmedUsuMensUsu(PCD_MENS_CONTRATO IN NUMBER, PVL_DIFERENCA IN NUMBER) IS
      SELECT dusu.*
          FROM dbaps.dmed_usuario_mens_usuario dusu, dbaps.dmed_usuario_mens_usuario_mc dmc, dbaps.dmed_usuario du
        WHERE dusu.cd_dmed_usuario_mens_usuario = dmc.cd_dmed_usuario_mens_usuario
          AND dmc.cd_mens_contrato = PCD_MENS_CONTRATO
          AND dusu.cd_dmed_usuario = du.cd_dmed_usuario
          AND du.cd_dmed_envio = P_DMED_ENVIO
          AND (dusu.vl_mes1 > GREATEST(PVL_DIFERENCA * -1, 0)
            OR dusu.vl_mes2 > GREATEST(PVL_DIFERENCA * -1, 0)
            OR dusu.vl_mes3 > GREATEST(PVL_DIFERENCA * -1, 0)
            OR dusu.vl_mes4 > GREATEST(PVL_DIFERENCA * -1, 0)
            OR dusu.vl_mes5 > GREATEST(PVL_DIFERENCA * -1, 0)
            OR dusu.vl_mes6 > GREATEST(PVL_DIFERENCA * -1, 0)
            OR dusu.vl_mes7 > GREATEST(PVL_DIFERENCA * -1, 0)
            OR dusu.vl_mes8 > GREATEST(PVL_DIFERENCA * -1, 0)
            OR dusu.vl_mes9 > GREATEST(PVL_DIFERENCA * -1, 0)
            OR dusu.vl_mes10 > GREATEST(PVL_DIFERENCA * -1, 0)
            OR dusu.vl_mes11 > GREATEST(PVL_DIFERENCA * -1, 0)
            OR dusu.vl_mes12 > GREATEST(PVL_DIFERENCA * -1, 0))
          AND ROWNUM = 1;      */

    --- variaveis
    vCdDmedEnvio    DBAPS.DMED_ENVIO.CD_DMED_ENVIO%TYPE;
    vCdDmedUsuario  DBAPS.DMED_USUARIO.CD_DMED_USUARIO%TYPE;

    vExcDmed        EXCEPTION;
    vExcReembolso   EXCEPTION;
    vExcUsuario     EXCEPTION;
    vDsPrestador    VARCHAR2(1000);
    vConfig         NUMBER;
    rDmed           cDmed%ROWTYPE;
    nValorAnoAnterior NUMBER;
    nVlPagoAno      NUMBER;
    --*RBCS

    nCdMatricula    NUMBER;
    vSnEnviarZerado  VARCHAR2(1);
    vSnDmedTitularesPorContrato VARCHAR2(1);
    vTpUsuario VARCHAR2(1);
    nCdMatriculaTem  NUMBER;

    nCdDmedUsuarioMensUsuMc NUMBER;
    vExisteMatricula        VARCHAR2(1);
    nCdDmedUsuMensUsu       NUMBER;
    nPercentualMes          NUMBER;
    nVlMes1                 NUMBER;
    nVlMes2                 NUMBER;
    nVlMes3                 NUMBER;
    nVlMes4                 NUMBER;
    nVlMes5                 NUMBER;
    nVlMes6                 NUMBER;
    nVlMes7                 NUMBER;
    nVlMes8                 NUMBER;
    nVlMes9                 NUMBER;
    nVlMes10                NUMBER;
    nVlMes11                NUMBER;
    nVlMes12                NUMBER;
    nVlCreditoMens          NUMBER;
    nPercentualBenef        NUMBER;
    nVlCreditoMes1          NUMBER;
    nVlCreditoMes2          NUMBER;
    nVlCreditoMes3          NUMBER;
    nVlCreditoMes4          NUMBER;
    nVlCreditoMes5          NUMBER;
    nVlCreditoMes6          NUMBER;
    nVlCreditoMes7          NUMBER;
    nVlCreditoMes8          NUMBER;
    nVlCreditoMes9          NUMBER;
    nVlCreditoMes10         NUMBER;
    nVlCreditoMes11         NUMBER;
    nVlCreditoMes12         NUMBER;
    nVlDescontoMens         NUMBER;
    nVlDescontoMes1         NUMBER;
    nVlDescontoMes2         NUMBER;
    nVlDescontoMes3         NUMBER;
    nVlDescontoMes4         NUMBER;
    nVlDescontoMes5         NUMBER;
    nVlDescontoMes6         NUMBER;
    nVlDescontoMes7         NUMBER;
    nVlDescontoMes8         NUMBER;
    nVlDescontoMes9         NUMBER;
    nVlDescontoMes10        NUMBER;
    nVlDescontoMes11        NUMBER;
    nVlDescontoMes12        NUMBER;
    nCdMensContratoAnterior NUMBER;
    vMesCorrecaoDiferenca   VARCHAR2(2);
    nSumMes                 NUMBER;
    nSumCredito             NUMBER;
    nSumDesconto            NUMBER;
    --rDmedUsuMensUsu         cDmedUsuMensUsu%ROWTYPE;
    nCdMatriculaAnterior    NUMBER;
    nPercentualPagoAno      NUMBER;
    nAcrescimoTotalAno      NUMBER;
    nDescontoTotalAno       NUMBER;
    nAcrescimoTotalAnoAnt   NUMBER;
    nDescontoTotalAnoAnt    NUMBER;
    vDsReceitaErro          VARCHAR2(4000);
    nVlDiferencaSomat�rio   NUMBER;
    --*RBCS

BEGIN
    OPEN  cDmed;
    FETCH cDmed INTO rDmed;
    IF cDmed%NOTFOUND THEN
        RAISE vExcDmed;
    END IF;
    ---
    CLOSE cDmed;
    OPEN cConfig;
    FETCH cConfig INTO vConfig;
    IF cConfig%NOTFOUND THEN
        CLOSE cConfig;
        Raise_Application_Error(-20999,'� necess�rio configurar os itens de jutos, multa e cr�dito a maior (Configura��es -> Configura��es -> Aba: Mensalidade -> Campos: Item de Juros, Item de Multa e Cr�dito a Maior)');
    END IF;
    CLOSE cConfig;

    --N�o limpar as tabelas se for para continuar de onde parou e se o c�digo da mensalidade por par�metro for NULL
    IF Nvl(PSN_CONTINUAR, 'N') = 'N' AND PCD_MENS_CONTRATO IS NULL THEN
      -- deltando registros de pagamento
      DELETE FROM dbaps.dmed_usuario_mens_usuario_mc
        WHERE cd_dmed_usuario_mens_usuario IN
          (SELECT DU.cd_dmed_usuario_mens_usuario FROM DBAPS.DMED_USUARIO D, DBAPS.DMED_USUARIO_MENS_USUARIO DU
              WHERE D.CD_DMED_USUARIO = DU.CD_DMED_USUARIO
                AND D.CD_DMED_ENVIO = P_DMED_ENVIO);

      -- deltando registros de pagamento
      DELETE FROM DBAPS.DMED_USUARIO_MENS_USUARIO
      WHERE CD_DMED_USUARIO IN (SELECT CD_DMED_USUARIO FROM DBAPS.DMED_USUARIO WHERE CD_DMED_ENVIO = P_DMED_ENVIO);

      -- deltando registros de pagamento
      DELETE FROM DBAPS.DMED_USUARIO
      WHERE CD_DMED_ENVIO = P_DMED_ENVIO;

      -- deltando registros de reembolso
      DELETE FROM DBAPS.DMED_USUARIO_REEMBOLSO
      WHERE CD_DMED_ENVIO = P_DMED_ENVIO;
    END IF;

    nCdMatricula := NULL;
    nCdMatriculaTem := NULL;
    vCdDmedUsuario := NULL;
    nCdDmedUsuMensUsu := NULL;
    nCdMensContratoAnterior := NULL;
    nSumMes := 0;
    nSumCredito := 0;
    nSumDesconto := 0;

    --Gera os reembolsos dos benefici�rios.
    vSnEnviarZerado := 'N';
    OPEN cConfiguracao;
    FETCH cConfiguracao INTO vSnEnviarZerado, vSnDmedTitularesPorContrato;
    CLOSE cConfiguracao;

    nVlCreditoMens := 0;
    nVlDescontoMens := 0;

    FOR nLancamentos IN cLancamentos LOOP
      --GRAVAR NO LOG A MENSALIDADE A SER UTILIZADA E O BENEFICI�RIO
      DBAPS.PRC_GRAVA_LOG_EXECUTA_DMED(P_DMED_ENVIO,
                                       nLancamentos.cd_mens_contrato,
                                       nLancamentos.cd_matricula,
                                       'A',
                                       'Mensalidade encontrada no cursor principal: '||nLancamentos.cd_mens_contrato);

      IF nLancamentos.tp_contrato <> 'A'
            OR (Nvl(nLancamentos.sn_demitido_aposentado_obito, 'N') = 'S'
                OR (Length(nLancamentos.nr_cpf_cgc) < 12
                AND dbaps.valida_cpf_cnpj(LPad(nLancamentos.nr_cpf_cgc, 11, '0')) = 1)) THEN

        BEGIN
          nCdMatricula := nLancamentos.cd_matricula;

          /*********************************
            Pegar o valor real de cada m�s
           *********************************/
          --Se o plano do benefici�rio for na DMED, pegar os valores, caso contr�rio os valores v�o zerados
          IF Nvl(nLancamentos.SN_ENVIA_DMED_IR, 'S') = 'S' THEN
            nVlMes1 := Nvl(nLancamentos.mes1, 0);
            nVlMes2 := Nvl(nLancamentos.mes2, 0);
            nVlMes3 := Nvl(nLancamentos.mes3, 0);
            nVlMes4 := Nvl(nLancamentos.mes4, 0);
            nVlMes5 := Nvl(nLancamentos.mes5, 0);
            nVlMes6 := Nvl(nLancamentos.mes6, 0);
            nVlMes7 := Nvl(nLancamentos.mes7, 0);
            nVlMes8 := Nvl(nLancamentos.mes8, 0);
            nVlMes9 := Nvl(nLancamentos.mes9, 0);
            nVlMes10 := Nvl(nLancamentos.mes10, 0);
            nVlMes11 := Nvl(nLancamentos.mes11, 0);
            nVlMes12 := Nvl(nLancamentos.mes12, 0);
          ELSE
            nVlMes1 := 0;
            nVlMes2 := 0;
            nVlMes3 := 0;
            nVlMes4 := 0;
            nVlMes5 := 0;
            nVlMes6 := 0;
            nVlMes7 := 0;
            nVlMes8 := 0;
            nVlMes9 := 0;
            nVlMes10 := 0;
            nVlMes11 := 0;
            nVlMes12 := 0;
          END IF;

          /*************************************
           FIM - Pegar o valor real de cada m�s
           *************************************/

          nAcrescimoTotalAnoAnt := 0;
          nDescontoTotalAnoAnt := 0;
          --Se for a primeira rodada ou na mudan�a de mensalidade, buscar os acr�scimos e descontos por contrato
          IF nCdMensContratoAnterior IS NULL OR nCdMensContratoAnterior <> nLancamentos.cd_mens_contrato THEN
            nVlCreditoMens := 0;
            nVlDescontoMens := 0;
            --S� pegar o somat�rio dos acres/desc por contrato se existir receitas Por Contrato na mensalidade e a flag SN_ENVIA_DMED_IR estiver marcada
            IF Nvl(nLancamentos.sn_existe_receita_por_contrato, 'N') = 'S' AND Nvl(nLancamentos.SN_ENVIA_DMED_IR, 'S') = 'S' THEN
              --Buscar por cr�dito que sejam apenas POR CONTRATO (que n�o existam na itmens_usuario, pois podem ter alterado o SN_QTD da receita)
              OPEN cCreditoMens(nLancamentos.cd_mens_contrato);
              FETCH cCreditoMens INTO nVlCreditoMens;
              CLOSE cCreditoMens;
              nVlCreditoMens := Nvl(nVlCreditoMens, 0);

              --GRAVAR NO LOG O VALOR DE CREDITO
              DBAPS.PRC_GRAVA_LOG_EXECUTA_DMED(P_DMED_ENVIO,
                                        nLancamentos.cd_mens_contrato,
                                        nLancamentos.cd_matricula,
                                        'A',
                                        'Valor total do cr�dito: '||nVlCreditoMens);

              --Buscar por Descontos que sejam apenas POR CONTRATO (que n�o existam na itmens_usuario, pois podem ter alterado o SN_QTD da receita)
              OPEN cDescontoMens(nLancamentos.cd_mens_contrato);
              FETCH cDescontoMens INTO nVlDescontoMens;
              CLOSE cDescontoMens;
              nVlDescontoMens := Nvl(nVlDescontoMens, 0);

              --GRAVAR NO LOG O VALOR DE DESCONTO
              DBAPS.PRC_GRAVA_LOG_EXECUTA_DMED(P_DMED_ENVIO,
                                        nLancamentos.cd_mens_contrato,
                                        nLancamentos.cd_matricula,
                                        'A',
                                        'Valor total do desconto: '||nVlDescontoMens);
            END IF;

            nAcrescimoTotalAnoAnt := nAcrescimoTotalAno;
            nDescontoTotalAnoAnt := nDescontoTotalAno;

            nPercentualPagoAno := 0;
            nAcrescimoTotalAno := 0;
            nDescontoTotalAno := 0;
            --Pegar o valor total do acr�scimo Por Contrato utilizado no ano
            IF nVlCreditoMens > 0 THEN
              nPercentualPagoAno := (nLancamentos.vl_recebimento * 100) / nLancamentos.vl_total_cobranca;
              nAcrescimoTotalAno := Round((nVlCreditoMens * nPercentualPagoAno) / 100, 2);
            END IF;

            --Pegar o valor total do Desconto Por Contrato utilizado no ano
            IF nVlDescontoMens < 0 THEN
              IF Nvl(nPercentualPagoAno, 0) = 0 THEN
                nPercentualPagoAno := (nLancamentos.vl_recebimento * 100) / nLancamentos.vl_total_cobranca;
              END IF;
              nDescontoTotalAno := Round((nVlDescontoMens * nPercentualPagoAno) / 100, 2);
            END IF;

            --Verificar se existe receita por contrato na dbaps.itmens_usuario para gravar no log como ERRO
            vDsReceitaErro := NULL;
            FOR rPorContrato IN cPorContrato(nLancamentos.cd_mens_contrato) LOOP
              IF vDsReceitaErro IS NULL THEN
                vDsReceitaErro := rPorContrato.receita;
              ELSE
                vDsReceitaErro := vDsReceitaErro||' / '||rPorContrato.receita;
              END IF;
            END LOOP;

            IF vDsReceitaErro IS NOT NULL THEN
              --GRAVAR NO LOG O ERRO
              DBAPS.PRC_GRAVA_LOG_EXECUTA_DMED(P_DMED_ENVIO,
                                        nLancamentos.cd_mens_contrato,
                                        NULL,
                                        'E',
                                        'Existe na mensalidade receita(s) Por Contrato nos itens dos benefici�rios(dbaps.itmens_usuario): '||vDsReceitaErro);
            END IF;

            --Verificar se existe receita por benef que n�o est� na dbaps.itmens_usuario para gravar no log como ERRO
            vDsReceitaErro := NULL;
            FOR rPorBenef IN cPorBenef(nLancamentos.cd_mens_contrato) LOOP
              IF vDsReceitaErro IS NULL THEN
                vDsReceitaErro := rPorBenef.receita;
              ELSE
                vDsReceitaErro := vDsReceitaErro||' / '||rPorBenef.receita;
              END IF;
            END LOOP;

            IF vDsReceitaErro IS NOT NULL THEN
              --GRAVAR NO LOG O ERRO
              DBAPS.PRC_GRAVA_LOG_EXECUTA_DMED(P_DMED_ENVIO,
                                        nLancamentos.cd_mens_contrato,
                                        NULL,
                                        'E',
                                        'Existe na mensalidade receita(s) Por Benefici�rio que n�o esta(�o) nos itens dos benefici�rios(dbaps.itmens_usuario): '||vDsReceitaErro);
            END IF;

            --VERIFICAR SE EXISTE ERRO DE COMPOSI��O DA MENSALIDADE (ESSE TIPO DE ERRO VAI IMPACTAR EM TODOS OS VALORES)--
            --Somat�rio dos itens de receita por benefici�rio bate com o somat�rio na itmens_contrato
            nVlDiferencaSomat�rio := 0;
            OPEN cSomarItensPorBenef(nLancamentos.cd_mens_contrato);
            FETCH cSomarItensPorBenef INTO nVlDiferencaSomat�rio;
            CLOSE cSomarItensPorBenef;

            IF Nvl(nVlDiferencaSomat�rio, 0) > 0 THEN
              --GRAVAR NO LOG O ERRO
              DBAPS.PRC_GRAVA_LOG_EXECUTA_DMED(P_DMED_ENVIO,
                                        nLancamentos.cd_mens_contrato,
                                        NULL,
                                        'E',
                                        'Somat�rio dos itens de receita por benefici�rio n�o batem com o somat�rio dos mesmos itens na itmens_contrato, diferen�a: '||nVlDiferencaSomat�rio);
            END IF;

            --Somat�rio dos itens da itmens_contrato bate com o valor pago (quando mensalidade quitada)
            nVlDiferencaSomat�rio := 0;

            --Somat�rio dos itens da itmens_contrato que n�o foram inclu�dos no recebimento tem que bater com o valor cobrado (vl_mensalidade)
            nVlDiferencaSomat�rio := 0;

          END IF; --IF nCdMensContratoAnterior IS NULL OR nCdMensContratoAnterior <> nLancamentos.cd_mens_contrato THEN



          --BAIXA CONTABIL ESTAVA SENDO TRATADA COMO DESCONTO NA ROTINA ANTERIOR
          --NESSA ROTINA, OS VALORES EST�O SENDO CALCULADOS COM BASE NO VALOR RECEBIDO (SEM A BAIXA CONTABIL), ENT�O N�O PRECISAMOS LANCAR ELA COMO DESCONTO

          /* EXEMPLO
          cd_lcto_mensalidade - valor
          1 - 200,00 / 150,00 e 50,00
          2 - 50,00  / 10,00  e 40,00
                       160,00 e 90,00 -> total por benef
                       250,00         -> total de todos os benefs do contrato
                       (160 * 100) / 250 -> 64% -> percentual benef 1
                       (90 * 100) / 250 -> 36%  -> percentual benef 2
                       Round((30 * 64) / 100, 2) = 19,2 -> credito do benef 1
                       Round((30 * 36) / 100, 2) = 10,8 -> credito do benef 2
          3 - 30,00  / 19,2 e 10,8
          */

          /**************************************************************
            Pegar o valor de cr�dito e desconto por contrato de cada m�s
           **************************************************************/

          nVlCreditoMes1 := 0;
          nVlDescontoMes1 := 0;
          nVlCreditoMes2 := 0;
          nVlDescontoMes2 := 0;
          nVlCreditoMes3 := 0;
          nVlDescontoMes3 := 0;
          nVlCreditoMes4 := 0;
          nVlDescontoMes4 := 0;
          nVlCreditoMes5 := 0;
          nVlDescontoMes5 := 0;
          nVlCreditoMes6 := 0;
          nVlDescontoMes6 := 0;
          nVlCreditoMes7 := 0;
          nVlDescontoMes7 := 0;
          nVlCreditoMes8 := 0;
          nVlDescontoMes8 := 0;
          nVlCreditoMes9 := 0;
          nVlDescontoMes9 := 0;
          nVlCreditoMes10 := 0;
          nVlDescontoMes10 := 0;
          nVlCreditoMes11 := 0;
          nVlDescontoMes11 := 0;
          nVlCreditoMes12 := 0;
          nVlDescontoMes12 := 0;

          IF Nvl(nLancamentos.sn_existe_receita_por_contrato, 'N') = 'S' THEN
            --mes 1
            nPercentualBenef := 0;
            IF Nvl(nVlMes1, 0) > 0 AND (nVlCreditoMens > 0 OR nVlDescontoMens < 0) THEN
              nPercentualBenef := (nVlMes1 * 100) / nLancamentos.vl_total_itmens_usuario;
              nVlCreditoMes1 := Round((nVlCreditoMens * nPercentualBenef) / 100, 2);
              nVlDescontoMes1 := Round((nVlDescontoMens * nPercentualBenef) / 100, 2);
            END IF;

            --mes 2
            nPercentualBenef := 0;
            IF Nvl(nVlMes2, 0) > 0 AND (nVlCreditoMens > 0 OR nVlDescontoMens < 0) THEN
              nPercentualBenef := (nVlMes2 * 100) / nLancamentos.vl_total_itmens_usuario;
              nVlCreditoMes2 := Round((nVlCreditoMens * nPercentualBenef) / 100, 2);
              nVlDescontoMes2 := Round((nVlDescontoMens * nPercentualBenef) / 100, 2);
            END IF;

            --mes 3
            nPercentualBenef := 0;
            IF Nvl(nVlMes3, 0) > 0 AND (nVlCreditoMens > 0 OR nVlDescontoMens < 0) THEN
              nPercentualBenef := (nVlMes3 * 100) / nLancamentos.vl_total_itmens_usuario;
              nVlCreditoMes3 := Round((nVlCreditoMens * nPercentualBenef) / 100, 2);
              nVlDescontoMes3 := Round((nVlDescontoMens * nPercentualBenef) / 100, 2);
            END IF;

            --mes 4
            nPercentualBenef := 0;
            IF Nvl(nVlMes4, 0) > 0 AND (nVlCreditoMens > 0 OR nVlDescontoMens < 0) THEN
              nPercentualBenef := (nVlMes4 * 100) / nLancamentos.vl_total_itmens_usuario;
              nVlCreditoMes4 := Round((nVlCreditoMens * nPercentualBenef) / 100, 2);
              nVlDescontoMes4 := Round((nVlDescontoMens * nPercentualBenef) / 100, 2);
            END IF;

            --mes 5
            nPercentualBenef := 0;
            IF Nvl(nVlMes5, 0) > 0 AND (nVlCreditoMens > 0 OR nVlDescontoMens < 0) THEN
              nPercentualBenef := (nVlMes5 * 100) / nLancamentos.vl_total_itmens_usuario;
              nVlCreditoMes5 := Round((nVlCreditoMens * nPercentualBenef) / 100, 2);
              nVlDescontoMes5 := Round((nVlDescontoMens * nPercentualBenef) / 100, 2);
            END IF;

            --mes 6
            nPercentualBenef := 0;
            IF Nvl(nVlMes6, 0) > 0 AND (nVlCreditoMens > 0 OR nVlDescontoMens < 0) THEN
              nPercentualBenef := (nVlMes6 * 100) / nLancamentos.vl_total_itmens_usuario;
              nVlCreditoMes6 := Round((nVlCreditoMens * nPercentualBenef) / 100, 2);
              nVlDescontoMes6 := Round((nVlDescontoMens * nPercentualBenef) / 100, 2);
            END IF;

            --mes 7
            nPercentualBenef := 0;
            IF Nvl(nVlMes7, 0) > 0 AND (nVlCreditoMens > 0 OR nVlDescontoMens < 0) THEN
              nPercentualBenef := (nVlMes7 * 100) / nLancamentos.vl_total_itmens_usuario;
              nVlCreditoMes7 := Round((nVlCreditoMens * nPercentualBenef) / 100, 2);
              nVlDescontoMes7 := Round((nVlDescontoMens * nPercentualBenef) / 100, 2);
            END IF;

            --mes 8
            nPercentualBenef := 0;
            IF Nvl(nVlMes8, 0) > 0 AND (nVlCreditoMens > 0 OR nVlDescontoMens < 0) THEN
              nPercentualBenef := (nVlMes8 * 100) / nLancamentos.vl_total_itmens_usuario;
              nVlCreditoMes8 := Round((nVlCreditoMens * nPercentualBenef) / 100, 2);
              nVlDescontoMes8 := Round((nVlDescontoMens * nPercentualBenef) / 100, 2);
            END IF;

            --mes 9
            nPercentualBenef := 0;
            IF Nvl(nVlMes9, 0) > 0 AND (nVlCreditoMens > 0 OR nVlDescontoMens < 0) THEN
              nPercentualBenef := (nVlMes9 * 100) / nLancamentos.vl_total_itmens_usuario;
              nVlCreditoMes9 := Round((nVlCreditoMens * nPercentualBenef) / 100, 2);
              nVlDescontoMes9 := Round((nVlDescontoMens * nPercentualBenef) / 100, 2);
            END IF;

            --mes 10
            nPercentualBenef := 0;
            IF Nvl(nVlMes10, 0) > 0 AND (nVlCreditoMens > 0 OR nVlDescontoMens < 0) THEN
              nPercentualBenef := (nVlMes10 * 100) / nLancamentos.vl_total_itmens_usuario;
              nVlCreditoMes10 := Round((nVlCreditoMens * nPercentualBenef) / 100, 2);
              nVlDescontoMes10 := Round((nVlDescontoMens * nPercentualBenef) / 100, 2);
            END IF;

            --mes 11
            nPercentualBenef := 0;
            IF Nvl(nVlMes11, 0) > 0 AND (nVlCreditoMens > 0 OR nVlDescontoMens < 0) THEN
              nPercentualBenef := (nVlMes11 * 100) / nLancamentos.vl_total_itmens_usuario;
              nVlCreditoMes11 := Round((nVlCreditoMens * nPercentualBenef) / 100, 2);
              nVlDescontoMes11 := Round((nVlDescontoMens * nPercentualBenef) / 100, 2);
            END IF;

            --mes 12
            nPercentualBenef := 0;
            IF Nvl(nVlMes12, 0) > 0 AND (nVlCreditoMens > 0 OR nVlDescontoMens < 0) THEN
              nPercentualBenef := (nVlMes12 * 100) / nLancamentos.vl_total_itmens_usuario;
              nVlCreditoMes12 := Round((nVlCreditoMens * nPercentualBenef) / 100, 2);
              nVlDescontoMes12 := Round((nVlDescontoMens * nPercentualBenef) / 100, 2);
            END IF;
          END IF; --Fim do if: Nvl(nLancamentos.sn_existe_receita_por_contrato, 'N') = 'S'

          /********************************************************************
            FIM - Pegar o valor de cr�dito e desconto por contrato de cada m�s
           ********************************************************************/

          --Somar os valores de cada m�s (itens por benef), mas o cr�dito de cada m�s (itens por contrato) - descontos de cada m�s (itens por contrato)
          --IF Nvl(nVlPagoAno, 0) > 0 THEN
          nVlPagoAno := 0;
          IF Nvl(nLancamentos.SN_ENVIA_DMED_IR, 'S') = 'S' THEN
            nVlPagoAno := nVlMes1 + nVlMes2 + nVlMes3 + nVlMes4 + nVlMes5 + nVlMes6 + nVlMes7 + nVlMes8 + nVlMes9 + nVlMes10 + nVlMes11 + nVlMes12
              + nVlCreditoMes1 + nVlCreditoMes2 + nVlCreditoMes3 + nVlCreditoMes4 + nVlCreditoMes5 + nVlCreditoMes6 + nVlCreditoMes7 + nVlCreditoMes8 + nVlCreditoMes9 + nVlCreditoMes10 + nVlCreditoMes11 + nVlCreditoMes12
              + nVlDescontoMes1 + nVlDescontoMes2 + nVlDescontoMes3 + nVlDescontoMes4 + nVlDescontoMes5 + nVlDescontoMes6 + nVlDescontoMes7 + nVlDescontoMes8 + nVlDescontoMes9 + nVlDescontoMes10 + nVlDescontoMes11 + nVlDescontoMes12;
          END IF;

          --GRAVAR NO LOG CADA VALOR DA MENSALIDADE E MATRICULA (VALOR PAGO ANO, VALOR MES 1, VALOR MES 2... VALOR CREDITO 1, VALOR CREDITO 2... VALOR DESCONTO 1...)
          DBAPS.PRC_GRAVA_LOG_EXECUTA_DMED(P_DMED_ENVIO,
                                       nLancamentos.cd_mens_contrato,
                                       nLancamentos.cd_matricula,
                                       'A',
                                       'Gravando valores do benefici�rio... '||
                                       'nVlPagoAno = '||nVlPagoAno||' - '||
                                       'nVlMes1 = '||nVlMes1||' - '||
                                       'nVlCreditoMes1 = '||nVlCreditoMes1||' - '||
                                       'nVlDescontoMes1 = '||nVlDescontoMes1||' - '||
                                       'nVlMes2 = '||nVlMes2||' - '||
                                       'nVlCreditoMes2 = '||nVlCreditoMes2||' - '||
                                       'nVlDescontoMes2 = '||nVlDescontoMes2||' - '||
                                       'nVlMes3 = '||nVlMes3||' - '||
                                       'nVlCreditoMes3 = '||nVlCreditoMes3||' - '||
                                       'nVlDescontoMes3 = '||nVlDescontoMes3||' - '||
                                       'nVlMes4 = '||nVlMes4||' - '||
                                       'nVlCreditoMes4 = '||nVlCreditoMes4||' - '||
                                       'nVlDescontoMes4 = '||nVlDescontoMes4||' - '||
                                       'nVlMes5 = '||nVlMes5||' - '||
                                       'nVlCreditoMes5 = '||nVlCreditoMes5||' - '||
                                       'nVlDescontoMes5 = '||nVlDescontoMes5||' - '||
                                       'nVlMes6 = '||nVlMes6||' - '||
                                       'nVlCreditoMes6 = '||nVlCreditoMes6||' - '||
                                       'nVlDescontoMes6 = '||nVlDescontoMes6||' - '||
                                       'nVlMes7 = '||nVlMes7||' - '||
                                       'nVlCreditoMes7 = '||nVlCreditoMes7||' - '||
                                       'nVlDescontoMes7 = '||nVlDescontoMes7||' - '||
                                       'nVlMes8 = '||nVlMes8||' - '||
                                       'nVlCreditoMes8 = '||nVlCreditoMes8||' - '||
                                       'nVlDescontoMes8 = '||nVlDescontoMes8||' - '||
                                       'nVlMes9 = '||nVlMes9||' - '||
                                       'nVlCreditoMes9 = '||nVlCreditoMes9||' - '||
                                       'nVlDescontoMes9 = '||nVlDescontoMes9||' - '||
                                       'nVlMes10 = '||nVlMes10||' - '||
                                       'nVlCreditoMes10 = '||nVlCreditoMes10||' - '||
                                       'nVlDescontoMes10 = '||nVlDescontoMes10||' - '||
                                       'nVlMes11 = '||nVlMes11||' - '||
                                       'nVlCreditoMes11 = '||nVlCreditoMes11||' - '||
                                       'nVlDescontoMes11 = '||nVlDescontoMes11||' - '||
                                       'nVlMes12 = '||nVlMes12||' - '||
                                       'nVlCreditoMes12 = '||nVlCreditoMes12||' - '||
                                       'nVlDescontoMes12 = '||nVlDescontoMes12||' - '||
                                       'co_participacao = '||nLancamentos.co_participacao);

          --Verificar se o benefici�rio j� existe na DMED, se existir trazer o cd_dmed_usuario
          vExisteMatricula := 'N';
          vCdDmedUsuario := NULL;
          nCdDmedUsuMensUsu := NULL;
          OPEN cExisteMatriculaDmed(nLancamentos.cd_matricula);
          FETCH cExisteMatriculaDmed INTO vExisteMatricula, vCdDmedUsuario, nCdDmedUsuMensUsu;
          CLOSE cExisteMatriculaDmed;

          IF Nvl(vExisteMatricula, 'N') = 'N' THEN
            OPEN  cDemdUsuario;
            FETCH cDemdUsuario INTO vCdDmedUsuario;
            CLOSE cDemdUsuario;

            OPEN  cDemdUsuarioMensUsu;
            FETCH cDemdUsuarioMensUsu INTO nCdDmedUsuMensUsu;
            CLOSE cDemdUsuarioMensUsu;
          END IF;

          --Atualizar os dados do benefici�rio que j� foi inclu�do
          IF vExisteMatricula = 'S' THEN
            IF PCD_MENS_CONTRATO IS NULL THEN
              UPDATE DBAPS.DMED_USUARIO SET VL_PAGO_ANO = VL_PAGO_ANO + nVlPagoAno
                WHERE cd_dmed_usuario = vCdDmedUsuario;

              UPDATE DBAPS.DMED_USUARIO_MENS_USUARIO
                  SET  vl_mes1 = vl_mes1 + nVlMes1
                      ,vl_credito_rateio1 = vl_credito_rateio1 + nVlCreditoMes1
                      ,vl_desconto_rateio1 = vl_desconto_rateio1 + nVlDescontoMes1
                      --mes 2
                      ,vl_mes2 = vl_mes2 + nVlMes2
                      ,vl_credito_rateio2 = vl_credito_rateio2 + nVlCreditoMes2
                      ,vl_desconto_rateio2 = vl_desconto_rateio2 + nVlDescontoMes2
                      --mes 3
                      ,vl_mes3 = vl_mes3 + nVlMes3
                      ,vl_credito_rateio3 = vl_credito_rateio3 + nVlCreditoMes3
                      ,vl_desconto_rateio3 = vl_desconto_rateio3 + nVlDescontoMes3
                      --mes 4
                      ,vl_mes4 = vl_mes4 + nVlMes4
                      ,vl_credito_rateio4 = vl_credito_rateio4 + nVlCreditoMes4
                      ,vl_desconto_rateio4 = vl_desconto_rateio4 + nVlDescontoMes4
                      --mes 5
                      ,vl_mes5 = vl_mes5 + nVlMes5
                      ,vl_credito_rateio5 = vl_credito_rateio5 + nVlCreditoMes5
                      ,vl_desconto_rateio5 = vl_desconto_rateio5 + nVlDescontoMes5
                      --mes 6
                      ,vl_mes6 = vl_mes6 + nVlMes6
                      ,vl_credito_rateio6 = vl_credito_rateio6 + nVlCreditoMes6
                      ,vl_desconto_rateio6 = vl_desconto_rateio6 + nVlDescontoMes6
                      --mes 7
                      ,vl_mes7 = vl_mes7 + nVlMes7
                      ,vl_credito_rateio7 = vl_credito_rateio7 + nVlCreditoMes7
                      ,vl_desconto_rateio7 = vl_desconto_rateio7 + nVlDescontoMes7
                      --mes 8
                      ,vl_mes8 = vl_mes8 + nVlMes8
                      ,vl_credito_rateio8 = vl_credito_rateio8 + nVlCreditoMes8
                      ,vl_desconto_rateio8 = vl_desconto_rateio8 + nVlDescontoMes8
                      --mes 9
                      ,vl_mes9 = vl_mes9 + nVlMes9
                      ,vl_credito_rateio9 = vl_credito_rateio9 + nVlCreditoMes9
                      ,vl_desconto_rateio9 = vl_desconto_rateio9 + nVlDescontoMes9
                      --mes 10
                      ,vl_mes10 = vl_mes10 + nVlMes10
                      ,vl_credito_rateio10 = vl_credito_rateio10 + nVlCreditoMes10
                      ,vl_desconto_rateio10 = vl_desconto_rateio10 + nVlDescontoMes10
                      --mes 11
                      ,vl_mes11 = vl_mes11 + nVlMes11
                      ,vl_credito_rateio11 = vl_credito_rateio11 + nVlCreditoMes11
                      ,vl_desconto_rateio11 = vl_desconto_rateio11 + nVlDescontoMes11
                      --mes 12
                      ,vl_mes12 = vl_mes12 + nVlMes12
                      ,vl_credito_rateio12 = vl_credito_rateio12 + nVlCreditoMes12
                      ,vl_desconto_rateio12 = vl_desconto_rateio12 + nVlDescontoMes12
                      --Copart
                      ,vl_co_participacao = vl_co_participacao + Nvl(nLancamentos.co_participacao, 0)
                WHERE cd_dmed_usuario_mens_usuario = nCdDmedUsuMensUsu;


                nCdDmedUsuarioMensUsuMc := NULL;
                OPEN cDmedusuarioMensUsuMC(nCdDmedUsuMensUsu, nLancamentos.cd_mens_contrato);
                FETCH cDmedusuarioMensUsuMC INTO nCdDmedUsuarioMensUsuMc;
                CLOSE cDmedusuarioMensUsuMC;

                IF nCdDmedUsuarioMensUsuMc IS NOT NULL THEN
                  UPDATE DBAPS.DMED_USUARIO_MENS_USUARIO_MC
                      SET  vl_mes1 = vl_mes1 +                           nVlMes1
                          ,vl_credito_rateio1 = vl_credito_rateio1 +     nVlCreditoMes1
                          ,vl_desconto_rateio1 = vl_desconto_rateio1 +   nVlDescontoMes1
                          ,vl_mes2 = vl_mes2 +                           nVlMes2
                          ,vl_credito_rateio2 = vl_credito_rateio2 +     nVlCreditoMes2
                          ,vl_desconto_rateio2 = vl_desconto_rateio2 +   nVlDescontoMes2
                          ,vl_mes3 = vl_mes3 +                           nVlMes3
                          ,vl_credito_rateio3 = vl_credito_rateio3 +     nVlCreditoMes3
                          ,vl_desconto_rateio3 = vl_desconto_rateio3 +   nVlDescontoMes3
                          ,vl_mes4 = vl_mes4 +                           nVlMes4
                          ,vl_credito_rateio4 = vl_credito_rateio4 +     nVlCreditoMes4
                          ,vl_desconto_rateio4 = vl_desconto_rateio4 +   nVlDescontoMes4
                          ,vl_mes5 = vl_mes5 +                           nVlMes5
                          ,vl_credito_rateio5 = vl_credito_rateio5 +     nVlCreditoMes5
                          ,vl_desconto_rateio5 = vl_desconto_rateio5 +   nVlDescontoMes5
                          ,vl_mes6 = vl_mes6 +                           nVlMes6
                          ,vl_credito_rateio6 = vl_credito_rateio6 +     nVlCreditoMes6
                          ,vl_desconto_rateio6 = vl_desconto_rateio6 +   nVlDescontoMes6
                          ,vl_mes7 = vl_mes7 +                           nVlMes7
                          ,vl_credito_rateio7 = vl_credito_rateio7 +     nVlCreditoMes7
                          ,vl_desconto_rateio7 = vl_desconto_rateio7 +   nVlDescontoMes7
                          ,vl_mes8 = vl_mes8 +                           nVlMes8
                          ,vl_credito_rateio8 = vl_credito_rateio8 +     nVlCreditoMes8
                          ,vl_desconto_rateio8 = vl_desconto_rateio8 +   nVlDescontoMes8
                          ,vl_mes9 = vl_mes9 +                           nVlMes9
                          ,vl_credito_rateio9 = vl_credito_rateio9 +     nVlCreditoMes9
                          ,vl_desconto_rateio9 = vl_desconto_rateio9 +   nVlDescontoMes9
                          ,vl_mes10 = vl_mes10 +                         nVlMes10
                          ,vl_credito_rateio10 = vl_credito_rateio10 +   nVlCreditoMes10
                          ,vl_desconto_rateio10 = vl_desconto_rateio10 + nVlDescontoMes10
                          ,vl_mes11 = vl_mes11 +                         nVlMes11
                          ,vl_credito_rateio11 = vl_credito_rateio11 +   nVlCreditoMes11
                          ,vl_desconto_rateio11 = vl_desconto_rateio11 + nVlDescontoMes11
                          ,vl_mes12 = vl_mes12 +                         nVlMes12
                          ,vl_credito_rateio12 = vl_credito_rateio12 +   nVlCreditoMes12
                          ,vl_desconto_rateio12 = vl_desconto_rateio12 + nVlDescontoMes12
                          ,vl_co_participacao = vl_co_participacao +     Nvl(nLancamentos.co_participacao, 0)
                          ,vl_total_pago = vl_total_pago +               Decode(PCD_MENS_CONTRATO, NULL, 0, nVlPagoAno)
                    WHERE cd_dmed_usuario_mens_usu_mc = nCdDmedUsuarioMensUsuMc;
                ELSE
                  --Incluir os dados da mensalidade para confer�ncia
                  nCdDmedUsuarioMensUsuMc := 0;
                  OPEN cDmedMensUsuMC;
                  FETCH cDmedMensUsuMC INTO nCdDmedUsuarioMensUsuMc;
                  CLOSE cDmedMensUsuMC;

                  INSERT INTO DBAPS.DMED_USUARIO_MENS_USUARIO_MC
                  (
                    cd_dmed_usuario_mens_usu_mc
                    ,cd_dmed_usuario_mens_usuario
                    ,cd_mens_contrato
                    ,vl_mes1
                    ,vl_credito_rateio1
                    ,vl_desconto_rateio1
                    ,vl_mes2
                    ,vl_credito_rateio2
                    ,vl_desconto_rateio2
                    ,vl_mes3
                    ,vl_credito_rateio3
                    ,vl_desconto_rateio3
                    ,vl_mes4
                    ,vl_credito_rateio4
                    ,vl_desconto_rateio4
                    ,vl_mes5
                    ,vl_credito_rateio5
                    ,vl_desconto_rateio5
                    ,vl_mes6
                    ,vl_credito_rateio6
                    ,vl_desconto_rateio6
                    ,vl_mes7
                    ,vl_credito_rateio7
                    ,vl_desconto_rateio7
                    ,vl_mes8
                    ,vl_credito_rateio8
                    ,vl_desconto_rateio8
                    ,vl_mes9
                    ,vl_credito_rateio9
                    ,vl_desconto_rateio9
                    ,vl_mes10
                    ,vl_credito_rateio10
                    ,vl_desconto_rateio10
                    ,vl_mes11
                    ,vl_credito_rateio11
                    ,vl_desconto_rateio11
                    ,vl_mes12
                    ,vl_credito_rateio12
                    ,vl_desconto_rateio12
                    ,vl_co_participacao
                    ,vl_total_pago
                  )
                  VALUES
                  (
                    nCdDmedUsuarioMensUsuMc
                    ,nCdDmedUsuMensUsu
                    ,nLancamentos.cd_mens_contrato
                    ,nVlMes1
                    ,nVlCreditoMes1
                    ,nVlDescontoMes1
                    ,nVlMes2
                    ,nVlCreditoMes2
                    ,nVlDescontoMes2
                    ,nVlMes3
                    ,nVlCreditoMes3
                    ,nVlDescontoMes3
                    ,nVlMes4
                    ,nVlCreditoMes4
                    ,nVlDescontoMes4
                    ,nVlMes5
                    ,nVlCreditoMes5
                    ,nVlDescontoMes5
                    ,nVlMes6
                    ,nVlCreditoMes6
                    ,nVlDescontoMes6
                    ,nVlMes7
                    ,nVlCreditoMes7
                    ,nVlDescontoMes7
                    ,nVlMes8
                    ,nVlCreditoMes8
                    ,nVlDescontoMes8
                    ,nVlMes9
                    ,nVlCreditoMes9
                    ,nVlDescontoMes9
                    ,nVlMes10
                    ,nVlCreditoMes10
                    ,nVlDescontoMes10
                    ,nVlMes11
                    ,nVlCreditoMes11
                    ,nVlDescontoMes11
                    ,nVlMes12
                    ,nVlCreditoMes12
                    ,nVlDescontoMes12
                    ,Nvl(nLancamentos.co_participacao, 0)
                    ,Decode(PCD_MENS_CONTRATO, NULL, 0, nVlPagoAno)   --Esse campo vai ser preenchido quando passar a mens_contrato por param�tro (para comparar com a antiga quando precisar de corre��o)
                  );
                END IF; --Fim da verifica��o se existe o benefici�rio nessa mensalidade na tabela DBAPS.DMED_USUARIO_MENS_USUARIO_MC  --IF nCdDmedUsuarioMensUsuMc IS NOT NULL THEN

            END IF; -- fim do if q verifica se n�o foi passada mens_contrato por parametro p rotina

          ELSE --Novo benefici�rio deve ser inclu�do

            vTpUsuario := nLancamentos.TP_USUARIO;
            nCdMatriculaTem := NULL;
            --Se a configura��o de titulares na dmed ser por contrato estiver ativa (ELO)
            IF vSnDmedTitularesPorContrato = 'S' THEN
              --Se n�o for titular, mas sua matricula estiver no contrato, vai virar titular do contrato
              IF vTpUsuario <> 'T' AND nLancamentos.CD_MATRICULA = nLancamentos.CD_MATRICULA_CONTRATO THEN
                vTpUsuario := 'T';
              END IF;
            END IF;

            --Se o benefici�rio continuar sem ser titular, colocar a MATRICULA TEM dele
            IF vTpUsuario <> 'T' THEN
              nCdMatriculaTem := nLancamentos.CD_MATRICULA_TEM;
            END IF;

            INSERT INTO DBAPS.DMED_USUARIO
            (
              CD_DMED_USUARIO
              ,CD_DMED_ENVIO
              ,CD_MATRICULA
              ,VL_PAGO_ANO
              ,SN_ENVIO
              ,DS_ERRO
              ,NR_CPF
              ,DT_NASCIMENTO
              ,NM_SEGURADO
              ,CD_MULTI_EMPRESA
              ,TP_USUARIO
              ,CD_SIB
              ,CD_MATRICULA_TEM
            )
            VALUES
            (
              vCdDmedUsuario
              ,P_DMED_ENVIO
              ,nLancamentos.CD_MATRICULA
              ,nVlPagoAno
              ,'S'
              ,NULL
              ,nLancamentos.NR_CPF
              ,nLancamentos.DT_NASCIMENTO
              ,nLancamentos.NM_SEGURADO
              ,DBAMV.PKG_MV2000.LE_EMPRESA
              ,vTpUsuario
              ,nLancamentos.CD_SIB
              ,nCdMatriculaTem
            );

            --Gravando na tabela o valor da mensalidade, do credito e desconto rateados e o valor total de co-participa��o para serem exibidos no relat�rio
            INSERT INTO DBAPS.DMED_USUARIO_MENS_USUARIO
            (
              CD_DMED_USUARIO_MENS_USUARIO
              ,cd_matricula
              ,cd_dmed_usuario
              ,vl_mes1
              ,vl_credito_rateio1
              ,vl_desconto_rateio1
              ,vl_mes2
              ,vl_credito_rateio2
              ,vl_desconto_rateio2
              ,vl_mes3
              ,vl_credito_rateio3
              ,vl_desconto_rateio3
              ,vl_mes4
              ,vl_credito_rateio4
              ,vl_desconto_rateio4
              ,vl_mes5
              ,vl_credito_rateio5
              ,vl_desconto_rateio5
              ,vl_mes6
              ,vl_credito_rateio6
              ,vl_desconto_rateio6
              ,vl_mes7
              ,vl_credito_rateio7
              ,vl_desconto_rateio7
              ,vl_mes8
              ,vl_credito_rateio8
              ,vl_desconto_rateio8
              ,vl_mes9
              ,vl_credito_rateio9
              ,vl_desconto_rateio9
              ,vl_mes10
              ,vl_credito_rateio10
              ,vl_desconto_rateio10
              ,vl_mes11
              ,vl_credito_rateio11
              ,vl_desconto_rateio11
              ,vl_mes12
              ,vl_credito_rateio12
              ,vl_desconto_rateio12
              ,vl_co_participacao
            )
            VALUES
            (
               nCdDmedUsuMensUsu
              ,nLancamentos.CD_MATRICULA
              ,vCdDmedUsuario
              ,nVlMes1
              ,nVlCreditoMes1
              ,nVlDescontoMes1
              ,nVlMes2
              ,nVlCreditoMes2
              ,nVlDescontoMes2
              ,nVlMes3
              ,nVlCreditoMes3
              ,nVlDescontoMes3
              ,nVlMes4
              ,nVlCreditoMes4
              ,nVlDescontoMes4
              ,nVlMes5
              ,nVlCreditoMes5
              ,nVlDescontoMes5
              ,nVlMes6
              ,nVlCreditoMes6
              ,nVlDescontoMes6
              ,nVlMes7
              ,nVlCreditoMes7
              ,nVlDescontoMes7
              ,nVlMes8
              ,nVlCreditoMes8
              ,nVlDescontoMes8
              ,nVlMes9
              ,nVlCreditoMes9
              ,nVlDescontoMes9
              ,nVlMes10
              ,nVlCreditoMes10
              ,nVlDescontoMes10
              ,nVlMes11
              ,nVlCreditoMes11
              ,nVlDescontoMes11
              ,nVlMes12
              ,nVlCreditoMes12
              ,nVlDescontoMes12
              ,Nvl(nLancamentos.co_participacao, 0)
            );

            FOR rReembolso IN cReembolso(nLancamentos.CD_MATRICULA, rDmed.nr_ano_calendario) LOOP
              --
              vDsPrestador := NULL;
              nValorAnoAnterior := NULL;
              OPEN cDescricaoPrestador(rReembolso.NR_CPF_CNPJ);
              FETCH cDescricaoPrestador INTO vDsPrestador;
              CLOSE cDescricaoPrestador;

              OPEN cReembolsoAnosAnteriores(nLancamentos.CD_MATRICULA, rDmed.nr_ano_calendario, rReembolso.NR_CPF_CNPJ);
              FETCH cReembolsoAnosAnteriores INTO nValorAnoAnterior;
              CLOSE cReembolsoAnosAnteriores;
              BEGIN
                IF Nvl(rReembolso.VL_PAGO, 0) > 0 OR Nvl(nValorAnoAnterior, 0) > 0 THEN
                  INSERT INTO DBAPS.DMED_USUARIO_REEMBOLSO
                  (
                      CD_DMED_USUARIO_REEMBOLSO
                      ,CD_DMED_ENVIO
                      ,CD_DMED_USUARIO
                      ,CD_MATRICULA
                      ,NR_CPF_CNPJ_PRESTADOR
                      ,NM_PRESTADOR
                      ,VL_REEMB_ANO_CALENDARIO
                      ,VL_REEMB_ANOS_ANTERIORES
                  )
                  VALUES
                  (
                      DBAPS.SEQ_DMED_USUARIO_REEMBOLSO.NEXTVAL
                      ,P_DMED_ENVIO
                      ,vCdDmedUsuario
                      ,rReembolso.CD_MATRICULA
                      ,rReembolso.NR_CPF_CNPJ
                      ,Nvl(vDsPrestador, 'N�O INFORMADO')
                      ,rReembolso.VL_PAGO
                      ,Nvl(nValorAnoAnterior, Decode(vSnEnviarZerado, 'S', 0, rReembolso.VL_PAGO))
                  );

                  DBAPS.PRC_GRAVA_LOG_EXECUTA_DMED(P_DMED_ENVIO,
                                                    nLancamentos.cd_mens_contrato,
                                                    rReembolso.CD_MATRICULA,
                                                    'A',
                                                    'Gravando valores do reembolso do benefici�rio... '||
                                                    'VL_REEMB_ANO_CALENDARIO = '||rReembolso.VL_PAGO||' - '||
                                                    'VL_REEMB_ANOS_ANTERIORES = '||Nvl(nValorAnoAnterior, rReembolso.VL_PAGO)||' - '||
                                                    'vSnEnviarZerado = '||vSnEnviarZerado||' - '||
                                                    'NM_PRESTADOR = '||Nvl(vDsPrestador, 'N�O INFORMADO')
                                                    );
                END IF;
              EXCEPTION
                WHEN vExcReembolso THEN
                    RAISE vExcReembolso;
              END;
            END LOOP;
          END IF;  --fim da inclus�o/atualiza��o


          --Incluir os dados da mensalidade para confer�ncia
          OPEN cDmedMensUsuMC;
          FETCH cDmedMensUsuMC INTO nCdDmedUsuarioMensUsuMc;
          CLOSE cDmedMensUsuMC;

          INSERT INTO DBAPS.DMED_USUARIO_MENS_USUARIO_MC
          (
             cd_dmed_usuario_mens_usu_mc
            ,cd_dmed_usuario_mens_usuario
            ,cd_mens_contrato
            ,vl_mes1
            ,vl_credito_rateio1
            ,vl_desconto_rateio1
            ,vl_mes2
            ,vl_credito_rateio2
            ,vl_desconto_rateio2
            ,vl_mes3
            ,vl_credito_rateio3
            ,vl_desconto_rateio3
            ,vl_mes4
            ,vl_credito_rateio4
            ,vl_desconto_rateio4
            ,vl_mes5
            ,vl_credito_rateio5
            ,vl_desconto_rateio5
            ,vl_mes6
            ,vl_credito_rateio6
            ,vl_desconto_rateio6
            ,vl_mes7
            ,vl_credito_rateio7
            ,vl_desconto_rateio7
            ,vl_mes8
            ,vl_credito_rateio8
            ,vl_desconto_rateio8
            ,vl_mes9
            ,vl_credito_rateio9
            ,vl_desconto_rateio9
            ,vl_mes10
            ,vl_credito_rateio10
            ,vl_desconto_rateio10
            ,vl_mes11
            ,vl_credito_rateio11
            ,vl_desconto_rateio11
            ,vl_mes12
            ,vl_credito_rateio12
            ,vl_desconto_rateio12
            ,vl_co_participacao
            ,vl_total_pago
          )
          VALUES
          (
             nCdDmedUsuarioMensUsuMc
            ,nCdDmedUsuMensUsu
            ,nLancamentos.cd_mens_contrato
            ,nVlMes1
            ,nVlCreditoMes1
            ,nVlDescontoMes1
            ,nVlMes2
            ,nVlCreditoMes2
            ,nVlDescontoMes2
            ,nVlMes3
            ,nVlCreditoMes3
            ,nVlDescontoMes3
            ,nVlMes4
            ,nVlCreditoMes4
            ,nVlDescontoMes4
            ,nVlMes5
            ,nVlCreditoMes5
            ,nVlDescontoMes5
            ,nVlMes6
            ,nVlCreditoMes6
            ,nVlDescontoMes6
            ,nVlMes7
            ,nVlCreditoMes7
            ,nVlDescontoMes7
            ,nVlMes8
            ,nVlCreditoMes8
            ,nVlDescontoMes8
            ,nVlMes9
            ,nVlCreditoMes9
            ,nVlDescontoMes9
            ,nVlMes10
            ,nVlCreditoMes10
            ,nVlDescontoMes10
            ,nVlMes11
            ,nVlCreditoMes11
            ,nVlDescontoMes11
            ,nVlMes12
            ,nVlCreditoMes12
            ,nVlDescontoMes12
            ,Nvl(nLancamentos.co_participacao, 0)
            ,Decode(PCD_MENS_CONTRATO, NULL, 0, nVlPagoAno)   --Esse campo vai ser preenchido quando passar a mens_contrato por param�tro (para comparar com a antiga quando precisar de corre��o)
          );
        EXCEPTION
            WHEN vExcUsuario THEN
                DBAPS.PRC_GRAVA_LOG_EXECUTA_DMED(P_DMED_ENVIO,
                                       nLancamentos.cd_mens_contrato,
                                       nLancamentos.cd_matricula,
                                       'F',
                                       'Erro ao processar DMED, Erro: '||SubStr(SQLERRM, 1, 2000)||
                                       ' Linha: '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
                RAISE vExcUsuario;
        END;
        --

      ELSE
        --GRAVAR NO LOG: MENSALIDADE XXX, DO CONTRATO YYY N�O FOI INCLU�DA NA DMED PQ O CONTRATO � COLETIVO POR ADES�O
        --  N�O � UM CONTRATO DE DEMITIDO/APOSENTADO/OBITO OU N�O POSSUI UM CPF
        DBAPS.PRC_GRAVA_LOG_EXECUTA_DMED(P_DMED_ENVIO,
                                       nLancamentos.cd_mens_contrato,
                                       nLancamentos.cd_matricula,
                                       'E',
                                       'A mensalidade '|| nLancamentos.cd_mens_contrato || ' possui o tipo do contrato '|| nLancamentos.tp_contrato ||
                                       ' e n�o � um contrato de demitido/aposentado/�bito ou n�o possui CPF');
        --NULL;
      END IF; --Fim do if que verifica se o contrato � do tipo 'A'

      --Enquanto permanecer na mesma mensalidade, somar os acr�scimos e descontos por contrato dela
      IF nCdMensContratoAnterior IS NULL OR nCdMensContratoAnterior = nLancamentos.cd_mens_contrato THEN
        --Somat�rios dos valores de todos os meses (valores por benefici�rios, acr�scimos e descontos) dos benefici�rios da mensalidade
        --nSumMes := nSumMes + nVlMes1 + nVlMes2 + nVlMes3 + nVlMes4 + nVlMes5 + nVlMes6 + nVlMes7 + nVlMes8 + nVlMes9 + nVlMes10 + nVlMes11 + nVlMes12;
        nSumCredito := nSumCredito + nVlCreditoMes1 + nVlCreditoMes2 + nVlCreditoMes3 + nVlCreditoMes4 + nVlCreditoMes5 + nVlCreditoMes6 + nVlCreditoMes7 + nVlCreditoMes8 + nVlCreditoMes9 + nVlCreditoMes10 + nVlCreditoMes11 + nVlCreditoMes12;
        nSumDesconto := nSumDesconto + nVlDescontoMes1 + nVlDescontoMes2 + nVlDescontoMes3 + nVlDescontoMes4 + nVlDescontoMes5 + nVlDescontoMes6 + nVlDescontoMes7 + nVlDescontoMes8 + nVlDescontoMes9 + nVlDescontoMes10 + nVlDescontoMes11 + nVlDescontoMes12;
      END IF;

      /*********************************************************************************************************************************************
            ATEN��O - QUANDO MUDAR DE MENSALIDADE, VERIICAR SE OS VALORES DA ANTIGA EST�O BATENDO OS CENTAVOS POR CAUSA DOS ARREDONDAMENTOS
      *********************************************************************************************************************************************/

      IF nCdMensContratoAnterior IS NOT NULL AND nCdMensContratoAnterior <> nLancamentos.cd_mens_contrato THEN
        --buscar o somat�rio dos itens por benefici�rios
        /*nDiferencaItensBenef := NULL;
        OPEN cSumItensBenef(nCdMensContratoAnterior);
        FETCH cSumItensBenef INTO nDiferencaItensBenef;
        CLOSE cSumItensBenef;

        IF Nvl(nDiferencaItensBenef, 0) <> 0 THEN
          OPEN cDmedUsuMensUsu(nCdMensContratoAnterior, nDiferencaItensBenef);
          FETCH cDmedUsuMensUsu INTO rDmedUsuMensUsu;
          CLOSE cDmedUsuMensUsu;
        END IF;

        bAtualizou := FALSE;
        IF Nvl(nDiferencaItensBenef, 0) > 0 AND rDmedUsuMensUsu.cd_dmed_usuario IS NOT NULL THEN
          --Acrescentar a diferen�a em algum benefici�rio
          IF rDmedUsuMensUsu.vl_mes1 > 0 THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes1 = vl_mes1 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes2 > 0 THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes2 = vl_mes2 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes3 > 0 THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes3 = vl_mes3 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes4 > 0 THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes4 = vl_mes4 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes5 > 0 THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes5 = vl_mes5 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes6 > 0 THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes6 = vl_mes6 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes7 > 0 THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes7 = vl_mes7 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes8 > 0 THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes8 = vl_mes8 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes9 > 0 THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes9 = vl_mes9 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes10 > 0 THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes10 = vl_mes10 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes11 > 0 THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes11 = vl_mes11 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes12 > 0 THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes12 = vl_mes12 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          END IF;

        ELSIF Nvl(nDiferencaItensBenef, 0) < 0 AND rDmedUsuMensUsu.cd_dmed_usuario IS NOT NULL THEN
          --diminuir a diferen�a de algum benefici�rio
          IF rDmedUsuMensUsu.vl_mes1 > (nDiferencaItensBenef * -1) THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes1 = vl_mes1 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes2 > (nDiferencaItensBenef * -1) THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes2 = vl_mes2 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes3 > (nDiferencaItensBenef * -1) THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes3 = vl_mes3 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes4 > (nDiferencaItensBenef * -1) THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes4 = vl_mes4 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes5 > (nDiferencaItensBenef * -1) THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes5 = vl_mes5 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes6 > (nDiferencaItensBenef * -1) THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes6 = vl_mes6 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes7 > (nDiferencaItensBenef * -1) THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes7 = vl_mes7 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes8 > (nDiferencaItensBenef * -1) THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes8 = vl_mes8 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes9 > (nDiferencaItensBenef * -1) THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes9 = vl_mes9 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes10 > (nDiferencaItensBenef * -1) THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes10 = vl_mes10 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes11 > (nDiferencaItensBenef * -1) THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes11 = vl_mes11 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          ELSIF rDmedUsuMensUsu.vl_mes12 > (nDiferencaItensBenef * -1) THEN
            UPDATE dbaps.dmed_usuario_mens_usuario SET vl_mes12 = vl_mes12 + nDiferencaItensBenef
              WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario_mens_usuario;
            bAtualizou := TRUE;
          END IF;
        END IF;

        IF bAtualizou THEN
          UPDATE dbaps.dmed_usuario SET vl_pago_ano = vl_pago_ano + nDiferencaItensBenef
            WHERE cd_dmed_usuario = rDmedUsuMensUsu.cd_dmed_usuario;
        END IF; */

        --nAcrescimoTotalAnoAnt e nDescontoTotalAnoAnt contem o valor total de acr�scimo e desconto proporcional ao pagamento realizado no ano calendario da mensalidade anterior

        --chamar procedure nova
        dbaps.prc_calcular_diferenca_dmed(P_DMED_ENVIO, nCdMensContratoAnterior, nAcrescimoTotalAnoAnt, nSumCredito, nDescontoTotalAnoAnt, nSumDesconto);

        nSumMes := 0;
        nSumCredito := nVlCreditoMes1 + nVlCreditoMes2 + nVlCreditoMes3 + nVlCreditoMes4 + nVlCreditoMes5 + nVlCreditoMes6 + nVlCreditoMes7 + nVlCreditoMes8 + nVlCreditoMes9 + nVlCreditoMes10 + nVlCreditoMes11 + nVlCreditoMes12;
        nSumDesconto := nVlDescontoMes1 + nVlDescontoMes2 + nVlDescontoMes3 + nVlDescontoMes4 + nVlDescontoMes5 + nVlDescontoMes6 + nVlDescontoMes7 + nVlDescontoMes8 + nVlDescontoMes9 + nVlDescontoMes10 + nVlDescontoMes11 + nVlDescontoMes12;
      END IF;

      /*********************************************************************************************************************************************
         FIM - ATEN��O - QUANDO MUDAR DE MENSALIDADE, VERIICAR SE OS VALORES DA ANTIGA EST�O BATENDO OS CENTAVOS POR CAUSA DOS ARREDONDAMENTOS
      *********************************************************************************************************************************************/

      nCdMensContratoAnterior := nLancamentos.cd_mens_contrato;
    END LOOP; --Fim do loop do cursor cLancamentos

    --Calcular o acres/desc para a �ltima mensalidade do loop
    IF Nvl(nAcrescimoTotalAno, 0) > 0 AND nAcrescimoTotalAno <> Nvl(nAcrescimoTotalAnoAnt, 0) THEN
      dbaps.prc_calcular_diferenca_dmed(P_DMED_ENVIO, nCdMensContratoAnterior, nAcrescimoTotalAno, nSumCredito, 0, 0);
    END IF;

    IF Nvl(nDescontoTotalAno, 0) < 0 AND nDescontoTotalAno <> Nvl(nDescontoTotalAnoAnt, 0) THEN
      dbaps.prc_calcular_diferenca_dmed(P_DMED_ENVIO, nCdMensContratoAnterior, 0, 0, nDescontoTotalAno, nSumDesconto);
    END IF;

    /*******************************************************************************
        PEGAR OS REEMBOLSOS DE BENEFICI�RIOS QUE N�O EST�O NA DMED PARA INCLUIR
    *******************************************************************************/
    dbaps.prc_inclui_titular_dmed(P_DMED_ENVIO, rDmed.nr_ano_calendario, vSnEnviarZerado, 'N');

    --Incluir os titulares com valor zerado para os dependentes com valor que est�o sem titular (j� com reembolso caso tenham)
    IF PSN_CONTINUAR = 'N' AND PCD_MENS_CONTRATO IS NULL THEN
      dbaps.prc_inclui_titular_dmed(P_DMED_ENVIO, rDmed.nr_ano_calendario, vSnEnviarZerado, 'S');
    END IF;

    --COMMIT;
    --

    --GERAR OS BENEFICIARIOS INV�LIDOS POR CPFs 11111111111, 22222222222, etc.
    FOR vBeneficiarios IN cBeneficiarios (P_DMED_ENVIO) LOOP
      FOR vDependentesDigitosInvalido IN cDependentesDigitosInvalido (vBeneficiarios.CD_MATRICULA, P_DMED_ENVIO) LOOP
        UPDATE DBAPS.DMED_USUARIO
            SET SN_ENVIO = 'N', DS_ERRO = 'CPF inv�lido. Da matricula - '||vDependentesDigitosInvalido.CD_MATRICULA||'. E o CPF - '||vDependentesDigitosInvalido.NR_CPF
          WHERE CD_MATRICULA = vDependentesDigitosInvalido.CD_MATRICULA;
        --COMMIT;
      END LOOP;
    END LOOP;
    --GERAR OS BENEFICIARIOS INV�LIDOS POR DUPLICIDADE DE CPF.
    FOR vBeneficiarios IN cBeneficiarios (P_DMED_ENVIO) LOOP
      FOR vDependentesNaoGerados IN cDependentesNaoGerados (vBeneficiarios.CD_MATRICULA, P_DMED_ENVIO) LOOP
        IF vBeneficiarios.NR_CPF = vDependentesNaoGerados.NR_CPF THEN
          UPDATE DBAPS.DMED_USUARIO
              SET SN_ENVIO = 'N', DS_ERRO = 'CPF Duplicado. Da matricula - '||vDependentesNaoGerados.CD_MATRICULA||'. E o CPF - '||vDependentesNaoGerados.NR_CPF
            WHERE CD_MATRICULA IN (vDependentesNaoGerados.CD_MATRICULA, vBeneficiarios.CD_MATRICULA);
          --COMMIT;
        END IF;
      END LOOP;
    END LOOP;
    --Criticar dependentes sem parentesco.
    FOR vDependParent IN cDependParent LOOP
      UPDATE DBAPS.DMED_USUARIO
          SET SN_ENVIO = 'N', DS_ERRO = 'N�o existe Parentesco para esse dependente (Informar o parentesco no cadastro do benefici�rios)'
        WHERE CD_MATRICULA = vDependParent.CD_MATRICULA;
      --COMMIT;
    END LOOP;
    --Criticar benefici�rios com mesmo cpf e nome ou data de nascimento diferentes.
    FOR vCpfDuplicado IN cCpfDuplicado LOOP
      UPDATE DBAPS.DMED_USUARIO
          SET SN_ENVIO = 'N', DS_ERRO = 'Existe outro benefici�rio com mesmo CPF ('||vCpfDuplicado.NR_CPF||')'
        WHERE CD_MATRICULA = vCpfDuplicado.CD_MATRICULA;
      --COMMIT;
    END LOOP;
    --Gravar criticas de dependentes maiores de 16 anos q n�o tenham CPF
    --Gravar criticas de dependentes maiores de 18 anos q n�o tenham CPF - Alterado Rafael Lucas 26/02/2020 - Regra de Idade para 18 anos Conforme Layout DMED
    FOR vDepSemCpf IN cDepSemCpf LOOP
      UPDATE DBAPS.DMED_USUARIO
       -- SET SN_ENVIO = 'N', DS_ERRO = 'O CPF � obrigat�rio para dependente maior de 16 anos (Matricula: '||vDepSemCpf.CD_MATRICULA||')' Comentado Rafael Lucas 26/02/2020 Idade Obrigatoria 18 anos
          SET SN_ENVIO = 'N', DS_ERRO = 'O CPF � obrigat�rio para dependente maior de 18 anos (Matricula: '||vDepSemCpf.CD_MATRICULA||')'
        WHERE CD_MATRICULA = vDepSemCpf.CD_MATRICULA;
      --COMMIT;
    END LOOP;
    -- atualiza data de processamento da DMED
    UPDATE DBAPS.DMED_ENVIO SET DT_PROCESSAMENTO = SYSDATE
    WHERE CD_DMED_ENVIO = P_DMED_ENVIO;

    --COMMIT;
EXCEPTION
    WHEN vExcDmed THEN
      RAISE_APPLICATION_ERROR( -20001, 'N�o existe Lan�amentos para este per�odo.' );
    WHEN vExcReembolso THEN
      RAISE_APPLICATION_ERROR( -20001, 'Erro: N�o � poss�vel inserir o reembolso com valores nulos.' || SQLERRM||' - Em: '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
    WHEN vExcUsuario THEN
      RAISE_APPLICATION_ERROR( -20001, 'Erro: N�o � poss�vel inserir o benefici�rios.' );
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR( -20001, 'Erro: N�o � poss�vel inserir a DMED. '||nCdMatricula|| ' - '|| SQLERRM||' - Em: '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE  );
END;
/

GRANT EXECUTE ON dbaps.prc_executa_dmed TO dbamv
/
GRANT EXECUTE ON dbaps.prc_executa_dmed TO dbasgu
/
GRANT EXECUTE ON dbaps.prc_executa_dmed TO mv2000
/
GRANT EXECUTE ON dbaps.prc_executa_dmed TO mvintegra
/
