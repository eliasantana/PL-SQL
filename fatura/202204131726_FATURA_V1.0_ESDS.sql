--<DS_SCRIPT>
-- DESCRI��O..: Criando tabela de cadastro de forma de pagamento
-- RESPONSAVEL: Elias Santana
-- DATA.......: 13/04/2022
-- APLICA��O..: fatura
--</DS_SCRIPT>
--<USUARIO=DBAPS>

CREATE TABLE forma_pagto(

cd_forma_pgamento NUMBER,
descricao         VARCHAR2(200),
dt_inclusao       DATE

)
/
ALTER TABLE forma_pagto ADD CONSTRAINT cnt_formapgamento_pk PRIMARY KEY (cd_forma_pgamento)
/
ALTER TABLE forma_pagto ADD CONSTRAINT cnt_descricao_ck CHECK (
    descricao IN ('Dinheiro', 'Cr�dito', 'D�bito','Parcelado')
)
/
COMMENT ON COLUMN forma_pagto.cd_forma_pgamento IS 'Chave Prim�ria'
/
COMMENT ON COLUMN forma_pagto.descricao IS 'Descri��o da forma de pagamento'
/
COMMENT ON COLUMN forma_pagto.dt_inclusao IS 'Data de Inclus�o'
