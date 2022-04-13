
--<DS_SCRIPT>
-- DESCRIÇÃO..: Criando tabela de Cadastro de Receita
-- RESPONSAVEL: Elias Santana
-- DATA.......: 13/04/2022
-- APLICAÇÃO..: fatura
--</DS_SCRIPT>
--<USUARIO=DBAPS>

CREATE TABLE receita (
  cd_receita       NUMBER,
  desconto         NUMBER,
  ds_receita       VARCHAR2(2000),
  dt_recebimento   DATE,
  sal_bruto        DECIMAL(9,2),
  sal_liquido      DECIMAL(9,2)

)
/
ALTER TABLE receita ADD CONSTRAINT cnt_cd_receita PRIMARY  KEY (cd_receita)
/
ALTER TABLE receita ADD CONSTRAINT cnt_sal_bruto_ck CHECK (
  sal_bruto  > 0
)
/
ALTER TABLE receita ADD CONSTRAINT cnt_sal_liquido_ck CHECK (
  sal_liquido  > 0
)
/
COMMENT ON COLUMN RECEITA.CD_RECEITA     IS 'Chave Primária'
/
COMMENT ON COLUMN RECEITA.DESCONTO       IS 'Valor do Desconto'
/
COMMENT ON COLUMN RECEITA.DS_RECEITA     IS 'Descrição da Receita'
/
COMMENT ON COLUMN RECEITA.DT_RECEBIMENTO IS 'Data do recebimento'
/
COMMENT ON COLUMN RECEITA.SAL_BRUTO      IS 'Valor Bruto da Receita'
/
COMMENT ON COLUMN RECEITA.SAL_LIQUIDO    IS 'Valor líquido da Receita'