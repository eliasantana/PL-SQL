--<DS_SCRIPT>
-- DESCRIÇÃO..: Validação de CPF
-- RESPONSAVEL: Elias Santana
-- DATA.......:19/03/2022
-- APLICAÇÃO..: FATURA V.1.0
--</DS_SCRIPT>

CREATE OR REPLACE FUNCTION FNC_VALIDA_CPF(P_CPF VARCHAR2)
RETURN BOOLEAN
IS
  /**************************************************************
    <objeto>
     <nome>FNC_VALIDA_CPF</nome>
     <usuario>ELIAS SANTANA</usuario>
     <alteracao>19/03/2022 20:38</alteracao>
     <descricao> PROCEDURE RESPONSÁVEL PELA VALIDAÇÃO DO CPF INFORMADO</descricao>
     <alteracao>
          - Calculo dos digitos verificadores
     </alteracao>
     <parametro> P_CPF - CPF SEM OS OS PONTOS

	   <tags>Validação</tags>
     <versao>1.1</versao>
    </objeto>
  ***************************************************************/


   BASE  VARCHAR2(10);
   PESO NUMBER:=10;
   TOTAL NUMBER:=0;
   SOMA NUMBER :=0;
   SOMA2 NUMBER :=0;

   DIV1 NUMBER :=0;
   DIV2 NUMBER :=0;
   RET BOOLEAN:=FALSE;
BEGIN
    --P_CPF:='81776144449';
    --P_CPF:='02506970410';
    --P_CPF:='00000000000';

    IF P_CPF = '00000000000' OR
       P_CPF = '11111111111' OR
       P_CPF = '22222222222' OR
       P_CPF = '33333333333' OR
       P_CPF = '44444444444' OR
       P_CPF = '55555555555' OR
       P_CPF = '66666666666' OR
       P_CPF = '77777777777' OR
       P_CPF = '88888888888' OR
       P_CPF = '66666666666'
    THEN
      Raise_Application_Error(-20999,'O CPF INFORMADO NÃO ESTÁ CORRETO');
    END IF;

    IF Length(P_CPF) < 11 THEN
        Raise_Application_Error(-20999,'O CPF INFORMADO POSSUI O COMPRIMENTO INFERIOR A 11 DÍGITOS');
    END IF;

    IF Length(P_CPF) > 11 THEN
        Raise_Application_Error(-20999,'O CPF INFORMADO POSSUI O COMPRIMENTO MAIOR A 11 DÍGITOS');
    END IF;


      --BASE - PRIMEIROS 9 DÍGITOS DO CPF
      BASE := SubStr(P_CPF,0,9);
      FOR I IN 1..9 LOOP
          TOTAL := TOTAL + (To_Number (SubStr(BASE,I,1))*PESO);

          PESO:=PESO-1;
          SOMA:=SOMA+TOTAL;
          TOTAL:=0;

      END LOOP;
      SOMA := Mod(SOMA,11);

      IF SOMA < 2 THEN
        SOMA:=0;
      END IF ;

      IF SOMA >= 2 THEN
          SOMA :=11-SOMA;
      END IF;


      --CÁLCULO DO DÍGITO VERIFICADOR 1
      DIV1:=SOMA;

      --INICIANDO CÁLCULO DO DIGITO VERIFICADOR 2
      BASE :=BASE||DIV1;
      TOTAL:=0;
      SOMA:=0;
      PESO:=11;

        FOR II IN 1..10 LOOP
          TOTAL := TOTAL + (To_Number (SubStr(BASE,II,1))*PESO);

          PESO:=PESO-1;
          SOMA:=SOMA+TOTAL;
          TOTAL:=0;

      END LOOP;
      SOMA := Mod(SOMA,11);

      IF SOMA < 2 THEN
        SOMA:=0;
      END IF ;

      IF SOMA >= 2 THEN
          SOMA :=11-SOMA;
      END IF;

      DIv2:=SOMA;

      IF DIV1||DIV2 = SUBSTR(P_CPF,10,2) THEN
          RET:=TRUE;
          Dbms_Output.Put_Line(' O cpf ' || P_CPF || ' É UM CPF VÁLIDO!' );
      ELSE
        Dbms_Output.Put_Line(' O cpf ' || P_CPF || ' NÃO É UM CPF VÁLIDO!' );
      END IF;
      RETURN RET;
END;


