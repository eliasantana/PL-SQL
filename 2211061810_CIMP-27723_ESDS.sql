--<DS_SCRIPT>
-- DESCRIÇÃO..: Adiciona um item de glosa
-- RESPONSAVEL: Elias Santana
-- DATA.......: 06/11/2021
-- APLICAÇÃO..: MVSAUDE   CIMP-27723
--</DS_SCRIPT>
--<USUARIO=DBAPS>

CREATE OR REPLACE PROCEDURE dbaps.prc_insere_itgrupo_glosa(
  p_cd_item_grupo_motivo_glosa NUMBER,
  p_cd_grupo_motivo_glosa NUMBER,
  p_ds_mensagem VARCHAR2) IS

  /**************************************************************
    <objeto>
     <nome>PRC_INSERE_ITGRUPO_GLOSA</nome>
     <usuario>Elias Santana</usuario>
     <alteracao>06/11/2021 09:32</alteracao>
     <descricao>
            Insere o itens de glosa no grupo informado coforme tabela 38 de 07/2021 - CIMP-CIMP-27723
     </descricao>
     <funcionalidade>
        --Function chamada durante a carga dos grupos e seus itens de glosa tiss
        --Glosas Utilizada pela tela M_GRU_MOTIVO_GLOSA
     </funcionalidade>
     <parametro>

  	 </parametro>
     <tags>Contabilidade, Apropriação, Classificação, Fechamento contábil</tags>
     <versao>1.0</versao>
    </objeto>
   **************************************************************/


CURSOR cItGrupoGlosa (p_cd_item_grupo_motivo_glosa number) IS
    SELECT 1 FROM DBAPS.tmp_ITEM_GRUPO_MOTIVO_GLOSA
        WHERE  cd_item_grupo_motivo_glosa = p_cd_item_grupo_motivo_glosa;

cd_item_grupo_motivo_glosa NUMBER;

BEGIN

    OPEN  cItGrupoGlosa(p_cd_item_grupo_motivo_glosa);
    FETCH cItGrupoGlosa INTO cd_item_grupo_motivo_glosa;


    IF cd_item_grupo_motivo_glosa IS NULL THEN
        INSERT INTO DBAPS.tmp_ITEM_GRUPO_MOTIVO_GLOSA (
            cd_item_grupo_motivo_glosa,
            cd_grupo_motivo_glosa,
            ds_mensagem)
        VALUES (p_cd_item_grupo_motivo_glosa,p_cd_grupo_motivo_glosa,p_ds_mensagem);
        COMMIT;
    ELSE
        Dbms_Output.Put_Line('O item COD.' || p_cd_item_grupo_motivo_glosa || ' já existe');
    END IF;
    CLOSE cItGrupoGlosa;
END;
/
GRANT EXECUTE ON DBAPS.PKG_MVS_LIVROS_AUXILIARES TO DBAMV
/
GRANT EXECUTE ON DBAPS.PKG_MVS_LIVROS_AUXILIARES TO DBASGU
/
GRANT EXECUTE ON DBAPS.PKG_MVS_LIVROS_AUXILIARES TO MV2000
/
GRANT EXECUTE ON DBAPS.PKG_MVS_LIVROS_AUXILIARES TO MVINTEGRA
/

