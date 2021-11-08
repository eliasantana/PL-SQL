--<DS_SCRIPT>
-- DESCRIÇÃO..: Adiciona um grupo de motivo de glosa
-- RESPONSAVEL: Elias Santana
-- DATA.......: 06/11/2021 17:08
-- APLICAÇÃO..: MVSAUDE   CIMP-27723
--</DS_SCRIPT>
--<USUARIO=DBAPS>


CREATE OR REPLACE PROCEDURE dbaps.prc_insere_grupo_mot_glosa(p_cd_grupo_motivo_glosa NUMBER, p_ds_grupo_motivo_glosa VARCHAR2) IS
   /**************************************************************
    <objeto>
     <nome>prc_insere_grupo_mot_glosaa</nome>
     <usuario>Elias Santana</usuario>
     <alteracao></alteracao>
     <descricao>
            Insere o grupo motivo de glosa
     </descricao>
     <funcionalidade>
        --Function chamada durante a carga dos grupos e seus itens de glosa tiss
        --Glosas Utilizada pela tela M_GRU_MOTIVO_GLOSA
     </funcionalidade>
     <parametro>
         p_cd_grupo_motivo_glosa - Código do Grupo de Glosa.
         p_ds_grupo_motivo_glosa - Descrição do Grupo de Glosa.
  	 </parametro>
     <tags>Contabilidade, Apropriação, Classificação, Fechamento contábil</tags>
     <versao>1.0</versao>
    </objeto>
   **************************************************************/

  CURSOR cGrupoglosa (P_CD_GRUPO_MOTIVO_GLOSA NUMBER) IS
       SELECT cd_grupo_motivo_glosa FROM dbaps.TEMP_GRUPO_MOTIVO_GLOSA
          WHERE CD_GRUPO_MOTIVO_GLOSA = P_CD_GRUPO_MOTIVO_GLOSA;
   rcGrupoglosa cGrupoglosa%ROWTYPE;
BEGIN

   OPEN cGrupoglosa (P_CD_GRUPO_MOTIVO_GLOSA);
   FETCH cGrupoglosa INTO rcGrupoglosa;
   CLOSE cGrupoglosa;

   IF rcGrupoglosa.cd_grupo_motivo_glosa IS NULL THEN
        INSERT INTO dbaps.TEMP_GRUPO_MOTIVO_GLOSA (
              cd_grupo_motivo_glosa,
              ds_grupo_motivo_glosa
              )
              VALUES (p_cd_grupo_motivo_glosa, p_ds_grupo_motivo_glosa );
        Dbms_Output.Put_Line('o grupo ' || p_cd_grupo_motivo_glosa || 'Adicionado');
        COMMIT;
   END IF;

END;
/

