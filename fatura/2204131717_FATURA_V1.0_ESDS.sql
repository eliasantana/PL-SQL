--<DS_SCRIPT>
-- DESCRI��O..: Criando a tabela de Cadastro de Contas
-- RESPONSAVEL: Elias Santana
-- DATA.......: 13/04/2022
-- APLICA��O..: fatura
--</DS_SCRIPT>
--<USUARIO=DBAPS>

CREATE TABLE conta (

 cd_conta   NUMBER,
 nr_agencia VARCHAR2(10),
 nr_conta   VARCHAR2(10),
 saldo      DECIMAL(12,2),
 qrcod      BLOB
)
/
ALTER TABLE conta ADD CONSTRAINT cnt_cd_conta_pk PRIMARY KEY (cd_conta)
/
COMMENT ON COLUMN conta.cd_conta IS 'Chave Prim�ria'
/
COMMENT ON COLUMN conta.nr_agencia IS 'N�mero da Ag�ncia'
/
COMMENT ON COLUMN conta.saldo IS 'Saldo da conta'
/
COMMENT ON COLUMN conta.qrcod IS 'Imagem QRCODE da conta'
/

