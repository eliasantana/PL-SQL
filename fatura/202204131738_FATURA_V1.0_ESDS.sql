
--<DS_SCRIPT>
-- DESCRIÇÃO..: Criando tabela de log para movimentação fimanceira
-- RESPONSAVEL: Elias Santana
-- DATA.......: 13/04/2022
-- APLICAÇÃO..: fatura
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
COMMENT ON COLUMN LOG_MOVIMENTACAO_FINANCEIRA.CD_LOG_MOVIMENTACAO IS 'Chave primária'
/
COMMENT ON COLUMN LOG_MOVIMENTACAO_FINANCEIRA.DESCRICAO           IS 'Descrição'
/
COMMENT ON COLUMN LOG_MOVIMENTACAO_FINANCEIRA.DT_MOVIMENTACAO     IS 'Data da movimentação'
/
COMMENT ON COLUMN LOG_MOVIMENTACAO_FINANCEIRA.NR_CONTA            IS 'Número da conta'
/
COMMENT ON COLUMN LOG_MOVIMENTACAO_FINANCEIRA.TP_MOVIMENTACAO     IS ' Tipo de movimentação C - Crédito D - Débito'
/
COMMENT ON COLUMN LOG_MOVIMENTACAO_FINANCEIRA.USUARIO             IS 'Usuário'
/
COMMENT ON COLUMN LOG_MOVIMENTACAO_FINANCEIRA.VL_MOVIMENTADO      IS ' Valor da movimentação'
/

