#Include "Protheus.ch"
#Include "TopConn.ch"

// Function - Funcao padrão da TOTVS
// User function - Funcoes de usuario
// Static function depende de uma function ou de uma user function para poder existir

User Function ModelSa1()

	AxCadastro("SA1")

Return
	//================================================================================

//Recomendação: Usar o mBrowse ao invés do axCadastro, apesar de ser mais simples, o axcadastro limita 
//o desenvolvimento e pode não funcionar em seu ambiente
//A migração de algumas tecnologias para banco de dados fazem com que alguns programas deixem de 
//funcionar.
//Tela de modelo 1, ou tela de cadastro

User Function ModelS2()

	Local cAlias := "SA1"
	Local aCores := {}
	Local cFiltra := "A1_FILIAL == '" + xFilial('SA1') + "' .And. A1_EST == 'SP' "
    Local aArea := GetArea()
    Local aAreaSB1 := SB1 -> (GetArea())

	Private cCadastro := "Cadastro de Clientes"
	Private aRotina := {}

// opções de filtro utilizando a FilBrowse -- estes filtros sempre serão executados independente do que o usuário decidir
// bloco de código: "pequeno programa" - https://tdn.totvs.com/pages/viewpage.action?pageId=6063094
// bloco de código não é debugável
	Private aIndexSA1 := {}
	Private bFiltraBrw:= { || FilBrowse(cAlias,@aIndexSA1,@cFiltra) }

// quando a função FilBrowse for utilizada a função de pesquisa deverá ser a PesqBrw ao invés da AxPesqui

	AADD(aRotina,{"Pesquisar"   ,"PesqBrw"      ,0,1})
	AADD(aRotina,{"Visualizar"  ,"AxVisual"     ,0,2})
	AADD(aRotina,{"Incluir"     ,"AxInclui"     ,0,3})
	AADD(aRotina,{"Alterar"     ,"AxAltera"     ,0,4})
	AADD(aRotina,{"Excluir"     ,"U_Exclui"     ,0,5})
	AADD(aRotina,{"Legenda"     ,"U_BLegenda"   ,0,3})

// inclui as configurações da legenda - a regra e a cor que será utilizada

	AADD(aCores,{"A1_TIPO == 'F'" ,"BR_VERDE" })
	AADD(aCores,{"A1_TIPO == 'L'" ,"BR_AMARELO" })
	AADD(aCores,{"A1_TIPO == 'R'" ,"BR_LARANJA" })
	AADD(aCores,{"A1_TIPO == 'S'" ,"BR_MARRON" })
	AADD(aCores,{"A1_TIPO == 'X'" ,"BR_AZUL" })

	dbSelectArea(cAlias)
	dbSetOrder(1)

// Cria o filtro na MBrowse utilizando a função FilBrowse

	Eval(bFiltraBrw)
	dbSelectArea(cAlias)
	dbGoTop()

// documento de referencia mbrowse: https://tdn.totvs.com/pages/viewpage.action?pageId=24346981
	mBrowse(,,,,cAlias, , , , , , aCores)
// Deleta o filtro utilizado na função FilBrowse
// Não precisa do restarea - essa função é usada quando interferimos no sistema - ex. criando ponto de entrada,
// criando coisa nova dentro do que já existe, que poderia atrapalhar o uso do sistema
EndFilBrw(cAlias,aIndexSA1)

RestArea(aArea)
RestArea(aAreaSB1)

Return Nil

//========================================================================================

// Exemplo: Determinando a opção do aRotina pela informação recebida em nOpc
User Function Exclui(cAlias, nReg, nOpc)

	Local nOpcao := 0

	nOpcao := AxDeleta(cAlias,nReg,nOpc)

	If nOpcao == 2
//Se confirmou a exclusão	
		MsgInfo("Exclusão realizada com sucesso!")
	ElseIf nOpcao == 1
		MsgInfo("Exclusão cancelada!")
	Endif

Return Nil


//========================================================================================
//+-------------------------------------------
//|Função: BLegenda - Rotina de Legenda
//+-------------------------------------------
User Function BLegenda()

	Local aLegenda := {}

	AADD(aLegenda,{"BR_VERDE" ,"Cons.Final" })
	AADD(aLegenda,{"BR_AMARELO" ,"Produtor Rural" })
	AADD(aLegenda,{"BR_LARANJA" ,"Revendedor" })
	AADD(aLegenda,{"BR_MARRON" ,"Solidario" })
	AADD(aLegenda,{"BR_AZUL" ,"Exporta磯" })

	BrwLegenda(cCadastro, "Legenda", aLegenda)

Return Nil
