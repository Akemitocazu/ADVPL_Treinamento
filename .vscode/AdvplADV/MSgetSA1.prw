#include "protheus.ch"
#include "msmgadd.ch"
// ref https://tdn.totvs.com/display/public/PROT/MsmGet

User Function MyMrbwEnch()

	Private cCadastro := "Cadastro de Clientes"
	Private aRotina := {{"Pesquisar" , "axPesqui" , 0, 1},;
		{"Visualizar" , "U_MyMsmGet" , 0, 2}}


	DbSelectArea("SA1")
	DbSetOrder(1)
	MBrowse(6,1,22,75,"SA1")

Return

//-------------------------------------------------------------

User Function MyMsmGet(cAlias,nReg,nOpc)
//lembrete: a abertura de uma variável é uma alocação de memória, isto afeta performance quando abrimos diversas variaveis desnecessariamente
	Local oDlg
	Local oEnch
	Local lMemoria 	:= .T.
	Local lCreate	:= .T.
	Local lSX3	:= .T.	//verifica se irá criar a enchoice a partir do SX3 ou a partir de um vetor. Neste caso está criando a partir da x3
	Local aPos 	:= {000,000,400,600}        //posição da enchoice na tela
	Local aCpoEnch	:= {}	//campos que serão mostrados na enchoice
	Local aAlterEnch := {"A1_COD", "A1_NOME"} 	//habilita estes campos para edição
	Local aField	:= {} //estrutura do campo
	Local aFolder	:= {"Cadastrais","Adm/Fin.", "Contabilidade", "Outros"} //"pastas"
	Local cSvAlias 	:= Alias() 

    /*Estrutura do vetor aField	
    [1] - Titulo	
    [2] - campo	
    [3] - Tipo	
    [4] - Tamanho	
    [5] - Decimal	
    [6] - Picture	
    [7] - Valid	
    [8] - Obrigat	
    [9] - Nivel	
    [10]- Inicializador Padrão	
    [11]- F3         	
    [12]- when	
    [13]- visual	
    [14]- chave	
    [15]- box	
    [16]- folder	
    [17]- nao alteravel	
    [18]- pictvar	            	
    [19]- gatilho*/       
    
    DbSelectArea("SX3") //Funciona, mas não é mais recomendado. Apos a migraçao, o primeiro erro que dará é o acesso direto ao dicionário de dados
    //Usar função openSX3 que faz o acesso por meio da aplicação ao invés de diretamente pelo banco de dados
    //Não pode mais dar alteração direta nos SX. 
    DbSetOrder(1)
    DbSeek(cAlias)
    
	While !Eof() .And. SX3->X3_ARQUIVO == cAlias

		If !(SX3->X3_CAMPO $ "A1_FILIAL") .And. X3Uso(SX3->X3_USADO) .and. SX3->X3_CAMPO $ "A1_COD|A1_NOME|A1_CGC|A1_MUN"
    AADD(aCpoEnch,SX3->X3_CAMPO)	
		EndIf
    
    // Exemplo da estrutura do array aField	//
    //adiciona a1 codigo com as configurações passadas que não são da sx3
    Aadd(aField, {"Codigo", "A1_COD", "C", 6, 0, "@!", 'IIF(Empty(M->A1_LOJA),.T.,ExistChav("SA1",M->A1_COD+M->A1_LOJA,,"EXISTCLI"))', .F., 1, "", "", "", .F., .F., "", 1, .F., "", "S"})		
    IF Alltrim(SX3->X3_CAMPO) $ "A1_COD|A1_NOME|A1_DESC|A1_COND|A1_ENDCOB|A1_ENDENT"
        Aadd(aField, {X3TITULO(),;			
        SX3->X3_CAMPO,;			
        SX3->X3_TIPO,;			
        SX3->X3_TAMANHO,;			
        SX3->X3_DECIMAL,;			
        SX3->X3_PICTURE,;			
        SX3->X3_VALID,; 			
        .F.,;			
        SX3->X3_NIVEL,;			
        SX3->X3_RELACAO,;			
        SX3->X3_F3,;			
        SX3->X3_WHEN,;			
        .F.,;			
        .F.,;			
        SX3->X3_CBOX,;			
        Val(SX3->X3_FOLDER),;			
        .F.,;			
        SX3->X3_PICTVAR,;			
        SX3->X3_TRIGGER})	
            EndIf

    DbSkip() //pula o cursor para a próxima linha
	EndDo

    DEFINE MSDIALOG oDlg TITLE "Teste MsmGet" FROM 0,0 TO 355,600 PIXEL 
    oDlg:lMaximized := .T.
    RegToMemory(cAlias, If(nOpc==3,.T.,.F.))
    
	If lSX3     //exemplo de utilização da enchoice lendo as informações do SX3 - quando a variável lSX3 for .T.
    oEnch := MsmGet():New(cAlias,nReg,nOpc,/*aCRA*/,/*cLetras*/,/*cTexto*/,aCpoEnch,aPos,aAlterEnch,;          
    /*nModelo*/,/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlg,/*lF3*/,lMemoria,/*lColumn*/,;          
    /*caTela*/,/*lNoFolder*/,/*lProperty*/,/*aField*/,/*aFolder*/,/*lCreate*/,;          
    /*lNoMDIStretch*/,/*cTela*/)    
	Else
    //exemplo de utilização da enchoice por array     
    oEnch := MsmGet():New(,,nOpc,/*aCRA*/,/*cLetras*/,/*cTexto*/,aCpoEnch,aPos,aAlterEnch,/*nModelo*/,;          
    /*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlg,/*lF3*/,lMemoria,/*lColumn*/,/*caTela*/,;          
    /*lNoFolder*/,/*lProperty*/,aField,aFolder,lCreate,/*lNoMDIStretch*/,/*cTela*/)    
	EndIf
    
    oEnch:oBox:align := CONTROL_ALIGN_ALLCLIENT
    
    ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,,,.F.,.F.) //ativar a msdialog com botoes (enchoice bar) na tela
    
	If !Empty(cSvAlias)
        DbSelectArea(cSvAlias)
	EndIf

return
