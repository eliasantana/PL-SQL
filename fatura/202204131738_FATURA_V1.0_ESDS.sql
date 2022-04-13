
--<DS_SCRIPT>
-- DESCRI��O..: Criando tabela de log para movimenta��o fimanceira
-- RESPONSAVEL: Elias Santana
-- DATA.......: 13/04/2022
-- APLICA��O..: fatura
--</DS_SCRIPT>
--<USUARIO=DBAPS>

CREATE TABLE log_movimentacao_financeira (

    cd_log_movimentacao NUMBER,
    descricao           VARCHAR2(2000),
    dt_movimentacao     DATE,
    nr_conta            NUMBER,
    tp_movimentacao     VARCHAR2(1),
    usuario             VARCHAR(255),
    vl_movimentado      DECIMAL (9,3)
)
/
ALTER TABLE log_movimentacao_financeira ADD CONSTRAINT cnt_cd_log_movimentacao_pk PRIMARY KEY (cd_log_movimentacao)
/
ALTER TABLE log_movimentacao_financeira ADD CONSTRAINT cnt_tp_movimentacao_ck CHECK (

    tp_movimentacao IN ('C','D')
)
/
COMMENT ON COLUMN LOG_MOVIMENTACAO_FINANCEIRA.CD_LOG_MOVIMENTACAO IS 'Chave prim�ria'
/
COMMENT ON COLUMN LOG_MOVIMENTACAO_FINANCEIRA.DESCRICAO           IS 'Descri��o'
/
COMMENT ON COLUMN LOG_MOVIMENTACAO_FINANCEIRA.DT_MOVIMENTACAO     IS 'Data da movimenta��o'
/
COMMENT ON COLUMN LOG_MOVIMENTACAO_FINANCEIRA.NR_CONTA            IS 'N�mero da conta'
/
COMMENT ON COLUMN LOG_MOVIMENTACAO_FINANCEIRA.TP_MOVIMENTACAO     IS ' Tipo de movimenta��o C - Cr�dito D - D�bito'
/
COMMENT ON COLUMN LOG_MOVIMENTACAO_FINANCEIRA.USUARIO             IS 'Usu�rio'
/
COMMENT ON COLUMN LOG_MOVIMENTACAO_FINANCEIRA.VL_MOVIMENTADO      IS ' Valor da movimenta��o'
/

