#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOPCONN.CH"
#INCLUDE "MSOLE.CH"

//Estruturalmente isso que ir� acontecer para a maioria do markbrowse
//Markbrowse apenas pega informa��es que voc� j� tem e realiza o processamento

user function Markbrow()

	Local aArea		:= GetArea()
	Local aFields 	:= {}
	Local oTempTable
	Local cQuery

	Private CALIAS	:= "S66"
	//-------------------
	//Cria��o do objeto
	//Criar tabela tempor�ria e marca��o dos registros
	//-------------------
	If Select(cAlias) > 0
		dbSelectArea(cAlias)
		(cAlias)->(dbCloseArea())
	EndIf

	// Fun��o recebe o nome da tabela que vai ser criado e montagem da estrutura
	oTempTable := FWTemporaryTable():New( cAlias )

	//--------------------------
	//Monta os campos da tabela
	//TamSX3 retorna um array - 3 - tipo 1 - tamanho 2 - decimal https://www.universoadvpl.com.br/2015/07/tamsx3/
	//--------------------------
	aadd(aFields,{"OK","C",2,0})
	aadd(aFields,{"C6_PRODUTO",TAMSX3("C6_PRODUTO")[3],TAMSX3("C6_PRODUTO")[1],TAMSX3("C6_PRODUTO")[2]})
	aadd(aFields,{"C6_VALOR",TAMSX3("C6_VALOR")[3],TAMSX3("C6_VALOR")[1],TAMSX3("C6_VALOR")[2]})
	aadd(aFields,{"C6_QTDVEN",TAMSX3("C6_QTDVEN")[3],TAMSX3("C6_QTDVEN")[1],TAMSX3("C6_QTDVEN")[2]})


	oTemptable:SetFields( aFields )
	oTempTable:AddIndex("indice1", {"C6_PRODUTO"} )
	//------------------
	//Cria��o da tabela
	// A tabela simula outra
	//------------------
	oTempTable:Create()

	//------------------------------------
	//Executa query para leitura da tabela
	//--------------------'----------------
	cQuery := " SELECT C6_PRODUTO, C6_QTDVEN, C6_VALOR "
	cQuery += " FROM " + RetSqlTab("SC6")
	cQuery += " WHERE SC6.D_E_L_E_T_ = '' "

	//cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery( cQuery, 'TMP' )

	DbSelectArea('TMP')
	TMP->(dbGoTop())

	While TMP->(!EOF())

		//Grava Tabela temporaria

		//RecLock - Trava todos os registros da tabela. Quando .T. insere novo registro, quando .F. altera registro j� existente
		// A aplica��o fazs o controle dos inserts
		RecLock(cAlias, .T.)

		(cALias)->C6_PRODUTO := TMP->C6_PRODUTO
		(cALias)->C6_VALOR 	 := TMP->C6_VALOR
		(cALias)->C6_QTDVEN	 := TMP->C6_QTDVEN
 		(cALias)->(msUnLock())

		TMP->(dbSkip())
	EndDo

	(cALias)->(dbGotop())


	//---------------------------------
	//Tela de Markbrowe
	//Coleta de informa��es para criar a tela
	//Outros parametros apenas informam usu�rio
	//---------------------------------
	Processa( {|| MARK() }, "Aguarde...", "Carregando defini��es...",.F.)

	//---------------------------------
	//Fecha e Exclui a tabela
	//---------------------------------
	TMP->(dbCloseArea())
	oTempTable:Delete()
	RestArea(aArea)


Return()

//==========================================================================================

Static Function Mark()



	Local aArea			:= GetArea()

	Private cAliasMark  := cALias //Coleta do alias que ser� usado, para separar os itens
	Private oMarK
	Private lMarcar		:= .F.

	cAliasMark->(dbGoTop())

	oMark := FWMarkBrowse():New() //inicializa��o do mark
	oMark:SetMenuDef("") //define menu
	oMark:SetAlias(cAliasMark) //define alias sendo usado
	oMark:SetOnlyFields( { C6_PRODUTO, C6_VALOR, C6_QTDVEN } ) //campos a serem usados
	oMark:SetDescription("MarkBrowse Teste") //descri��o da tela
	oMark:SetFieldMark( 'OK') //campo de marca��o quando for ticar
	oMark:SetTemporary() //usando uma tabela temopor�ria , n�o tabela padr�o

//Estrutura da tela: campo, label, tamanho e picture
	oMark:SetColumns(MontaColunas("C6_PRODUTO"	,"Produto"    ,15,PesqPict("SC6","C6_PRODUTO")	,0,005,0))
	oMark:SetColumns(MontaColunas("C6_VALOR"	,"Valor R$"   ,18,PesqPict("SC6","C6_VALOR")	,0,003,0))
	oMark:SetColumns(MontaColunas("C6_QTDVEN"	,"Qauntidad"  ,18,PesqPict("SC6","C6_QTDVEN")	,0,005,0))

// Cria��o de bot�o - Ignora ARotina - Seleciona todos os registros
	oMark:AddButton("Boleto",{|| Grava() },,3,2)
	oMark:SetIgnoreArotina(.T.)
	oMark:bAllMark := { || SetMarkAll(oMark:Mark(),lMarcar := !lMarcar ), oMark:Refresh(.T.)  }

//Ativa a tela com o resultado da query
	oMark:Activate()

	RestArea(aArea)


return

//==========================================================================================================
//Fun��o de marca��o
Static Function SetMarkAll(cMarca,lMarcar )

	Local aAreaMark  := (cAliasMark)->( GetArea() )

	dbSelectArea(cAliasMark)
	(cAliasMark)->( dbGoTop() )

	While !(cAliasMark)->( Eof() )
		RecLock( (cAliasMark), .F. )
		(cAliasMark)->OK := IIf( lMarcar, cMarca, '  ' )
		MsUnLock()
		(cAliasMark)->( dbSkip() )
	EndDo

	RestArea( aAreaMark )

Return .T.

//===========================================================================================================


/*
*Fun��o para montagem das colunas da Markbrowse - N�o � obrigat�ria mas facilita
*/
Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	Local aColumn
	Local bData 	:= {||}
	Default nAlign 	:= 1
	Default nSize 	:= 20
	Default nDecimal:= 0
	Default nArrData:= 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
	EndIf

	/* Array da coluna
	[n][01] T�tulo da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] M�scara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edi��o
	[n][09] Code-Block de valida��o da coluna ap�s a edi��o
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execu��o do duplo clique
	[n][12] Vari�vel a ser utilizada na edi��o (ReadVar)
	[n][13] Code-Block de execu��o do clique no header
	[n][14] Indica se a coluna est� deletada
	[n][15] Indica se a coluna ser� exibida nos detalhes do Browse
	[n][16] Op��o de carga dos dados (Ex: 1=Sim, 2=Nï¿½o)
	*/
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return {aColumn}

//===========================================================================================================

Static Function Grava()

(cAliasMark)->(dbGoTop())
	While (cAliasMark)->(!EOF())

		If !Empty((cAliasMark)->OK)
			Alert("Item Marcado")
		else
			Alert("Item Desmarcado")
		END

		(cAliasMark)->(dbSkip())
	ENDDO

Return
	