--<DS_SCRIPT>
-- DESCRIÇÃO..: Criando a tabela de configuração gerais do sistema
-- RESPONSAVEL: Elias Santana
-- DATA.......: 13/04/2022
-- APLICAÇÃO..: fatura
--</DS_SCRIPT>
--<USUARIO=DBAPS>

CREATE TABLE configuracao(
  cd_configuracao NUMBER
  ,sn_parcelado   VARCHAR2(1)
  ,sn_notificar   VARCHAR2(1)
  ,nr_dias        NUMBER
  ,dir_importacao VARCHAR2(200)
  ,logo           BLOB
  ,nr_msg_diaria  NUMBER
)
/
ALTER TABLE configuracao ADD  CONSTRAINT cnt_cd_configuracao_pk PRIMARY KEY (cd_configuracao)
/
ALTER TABLE configuracao
  ADD CONSTRAINT cnt_sn_parceladao_ck CHECK (
       sn_parcelado IN ('S','N')
)
/
ALTER TABLE configuracao
    ADD CONSTRAINT cnt_sn_notificar_ck CHECK (
        sn_notificar IN ('S','N')
)
/
COMMENT ON COLUMN configuracao.cd_configuracao IS 'Chave Primária'
/
COMMENT ON COLUMN configuracao.sn_parcelado IS  'S - Para parcelar N - Não parcelar'
/
COMMENT ON COLUMN configuracao.sn_notificar IS 'Ativa a notificação por email ao usuário'
/
COMMENT ON COLUMN configuracao.nr_dias IS 'Quatidade de dias a partir de quando o sistema deverá notificar o usuário'
/
COMMENT ON COLUMN configuracao.dir_importacao IS 'Caminho do diretório para onde o sistema deverá importar (gerar) arquivos'
/
COMMENT ON COLUMN configuracao.logo IS 'Logomarca do sistema'
/
COMMENT ON COLUMN configuracao.nr_msg_diaria IS ' Quantidade de mensagens dirárias sobre lancamentos a vencer'
/


