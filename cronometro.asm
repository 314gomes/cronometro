jmp main

minutos: var #1
segundos: var #1
tdeltaseg: var #1
tdeltams: var #1
tiniseg: var #1
tinims: var #1

main:
  loadn r1, #0

  ;tdeltaseg = 0
  store tdeltams, r1

  ;tdeltams = 0
  store tdeltaseg, r1

  ;tiniseg = 0
  store tinims, r1

  ;tinims = 0
  store tiniseg, r1

  ; r7 indica se esta pausado. inicialmente esta.
  loadn r7, #1

  loadn r0, #21
  loadn r2, #3
  call Imprime_Numero

  loadn r0, #15
  loadn r2, #5
  call Imprime_Numero

  main_loop:
    ; r0 recebe teclado
    inchar r0

    ; se teclado == espaco
    loadn r1, #32
    cmp r0, r1
    jne fim_se_teclado_e_espaco
      ; se esta pausado
      loadn r1, #1
      cmp r7, r1
      jne fim_se_esta_pausado
        ; desmarcar pausado
        loadn r7, #0

        ; ---- atualiza delta MS -----

        ; r0 recebe tempo ms que comecou pausa
        load r0, tinims

        ; r1 recebe tempo ms atual
        mov r1, RCLKMS

        ; r0 o delta tempo ms
        sub r0, r1, r0

        ; r1 recebe delta ms total
        load r1, tdeltams

        ; somar delta atual e delta total
        add r0, r1, r0

        ; se delta ms >= 1000
        loadn r2, #1000
        cmp r0, r2
        jle fim_delta_ms_grande
          sub r0, r0, r2 ; subtrair 1000
          loadn r2, #1 ; tera que add 1 aos segundos (carry para segundos)
        jmp fim_senao_delta_ms_grande
        fim_delta_ms_grande:
          loadn r2, #0 ; nao tera que add nada
        fim_senao_delta_ms_grande:
        ; guardar novo delta ms total
        store tdeltams, r0

        ; ---- atualiza delta S -----

        ; r0 recebe tempo s que comecou pausa
        load r0, tiniseg

        ; r1 recebe tempo s atual
        mov r1, RCLKS

        ; r0 o delta tempo s
        sub r0, r1, r0

        ; r1 recebe delta s total
        load r1, tdeltaseg

        ; somar delta atual e delta total
        add r0, r1, r0
        ; adicionar carry
        add r0, r2, r0

        ; guardar novo delta s total
        store tdeltaseg, r0


      jmp fim_senao_esta_pausado
      fim_se_esta_pausado:
        ; marcar pausado
        loadn r7, #1
        ; ---- atualiza t inicial s ----
        mov r0, RCLKS
        store tiniseg, r0
        ; ---- atualiza t inicial ms ----
        mov r0, RCLKMS
        store tinims, r0

      fim_senao_esta_pausado:
    fim_se_teclado_e_espaco:
    ; se nao esta pausado
    loadn r1, #0
    cmp r7, r1
    jne fim_se_nao_esta_pausado2
      load r6, tdeltams
      load r5, tdeltaseg
      loadn r2, #1000
      
      mov r4, RCLKMS
      mov r3, RCLKS

      sub r1, r4, r6
      jn ms_deu_negativo
      jmp fim_ms_deu_negativo
      
      ms_deu_negativo:
        add r1, r2, r1
        dec r3
      fim_ms_deu_negativo:

      loadn r0, #21
      loadn r2, #3
      call Imprime_Numero

      sub r1, r3, r5
      jn s_deu_negativo
      jmp fim_s_deu_negativo
      
      s_deu_negativo:
        halt
      fim_s_deu_negativo:

      loadn r0, #15
      loadn r2, #5
      call Imprime_Numero

    fim_se_nao_esta_pausado2:
  jmp main_loop
breakp
halt

Imprime_Numero:
  ; recebe a posicao do primeiro digito no r0
  ; recebe o numero a ser impresso no r1
  ; recebe qtd de digitos do numero no r2
  push fr
  push r0
  push r1
  push r2
  push r3
  push r4
  push r5
  push r6

  add r0, r0, r2 ; soma qtd de digitos pois serao impressos qtd digitos + 1 de tras pra frente
  dec r0
  Loop_Imprime_Numero:
    loadn r3, #10 ; div e mod por 10   
    mod r4, r1, r3 ; r4 = score % 10
    div r1, r1, r3 ; divide score por 10
    loadn r5, #48 ; ascii 0
    add r5, r5, r4 ; soma resto no ascii zero
    outchar r5, r0
    dec r0 ; decrementa posicao
    dec r2 ; decrementa qtd digitos
    
    jz Sair_Imprime_Numero
    jmp Loop_Imprime_Numero

  Sair_Imprime_Numero:
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    pop fr
    rts