#include 'protheus.ch'

/*/{Protheus.doc} ApiDataset
Classe responsável pela estrutura dos dados a serem retornados.
@type class
@author Gustavo Marttos
@since 01/10/2019
@version 1.0
/*/
Class ApiDataset
    Data Table          As String
    Data TableAlias     As String
    Data Fields         As Array
    Data Constraints    As Array
    Data Relationships  As Array
    Data Orders         As Array
    Data Dataset        As ApiData
    Data Offset         As Integer
    Data Fetch          As Integer

    Method New(cTable, aFields, nOffset, nFetch) Constructor
    Method SetTable(cTable)
    Method SetFields(aFields)
    Method AddRelationship(oRelationship)
    Method AddConstraint(oConstraint)
    Method AddOrder(oOrder)
    Method ToSql()
    Method Execute()
EndClass

/*/{Protheus.doc} New
Construtor da classe ApiDataset. Inicia os vetores e strings como vazias.
@type function
@author Gustavo Marttos
@since 01/10/2019
@version 1.0
@param cTable, characters, Nome da tabela.
@param aFields, array of string, Campos a serem retornados.
@param nOffset, integer, Quantidade de linhas a serem puladas.
@param nFetch, integer, Quantidade de linhas a serem retornadas.
@return Self, Instância da classe.
@example ApiDataset():New()
/*/
Method New(cTable, aFields, nOffset, nFetch) Class ApiDataset
    Default nOffset := 0, nFetch := 100

    ::Table := ''
    ::TableAlias := ''
    ::Fields := {}
    ::Constraints := {}
    ::Relationships := {}
    ::Orders := {}
    ::Dataset := ApiData():New('DATASET', {}, {}, .T.)
    ::Offset := nOffset
    ::Fetch := nFetch

    ::SetTable(cTable)
    ::SetFields(aFields)

    ::AddConstraint(ApiConstraint():New(::TableAlias + '.D_E_L_E_T_', '_EMPTY'))
Return Self

/*/{Protheus.doc} SetTable
Define a tabela principal da consulta.
@type function
@author Gustavo Marttos
@since 01/10/2019
@version 1.0
@param cTable, characters, Nome da tabela principal.
@return Self, Instância da classe.
/*/
Method SetTable(cTable) Class ApiDataset
    ::Table := IIf(Len(AllTrim(cTable)) == 3, RetSqlName(cTable), cTable)
    ::TableAlias := cTable
Return Self

/*/{Protheus.doc} SetFields
Define os campos da tabela principal.
@type function
@author Gustavo Marttos
@since 01/10/2019
@version 1.0
@param aFields, array of characters, Array contendo os campos a serem retornados.
@return Self, Instância da classe.
/*/
Method SetFields(aFields) Class ApiDataset
    Local nI := 0
    Local cField := ''
    Local cOrder := 'ZA'
    Local aOtherFld := {}
    Local aMetadata := {}
    Local lCustom := .F.

    For nI := 1 To Len(aFields)
        lCustom := .F.

        If ValType(aFields[nI]) == 'C' .And. RAt('|', aFields[nI]) > 0
            lCustom := .T.
        EndIf

        If ValType(aFields[nI]) == 'C' .And. RAt('.', aFields[nI]) == 0 .And. ! lCustom
            aAdd(::Fields, aFields[nI])

            Loop
        EndIf

        If ValType(aFields[nI]) == 'C' .And. ! lCustom
            aAdd(::Fields, aFields[nI] + ' AS ' + SubStr(aFields[nI], RAt('.', aFields[nI]) + 1))

            Loop
        EndIf

        If ValType(aFields[nI]) != 'C'
            oField := aFields[nI]:GetJsonText('field')
            oSize := aFields[nI]:GetJsonText('size')
            oType :=aFields[nI]:GetJsonText('type')
            oName := aFields[nI]:GetJsonText('name')
            oExp := aFields[nI]:GetJsonText('expression')
            oOrder := aFields[nI]:GetJsonText('order')
        EndIf

        If lCustom
            /**
             * aFields[nI] can be a custom field using the possibilities below:
             * 'field[1]|expression[2]' - 1 pipe.
             * 'field[1]|expression[2]|type[3]' - 2 pipes.
             * 'field[1]|expression[2]|type[3]|size[4]' - 3 pipes.
             * 'field[1]|expression[2]|type[3]|size[4]|order[5]' - 4 pipes.
             * 'field[1]|expression[2]|type[3]|size[4]|order[5]|name[6]' - 5 pipes.
             */

            While At('||', aFields[nI]) > 0
                aFields[nI] := StrTran(aFields[nI], '||', '| |')
            EndDo

            aData := StrTokArr2(aFields[nI], '|')

            oField := aData[1]
            oExp := aData[2]
            oType := ''
            oSize := ''
            oOrder := ''
            oName := ''

            If Len(aData) == 2
                oType := 'C'
            EndIf

            If Len(aData) >= 3
                oType := aData[3]
            EndIf

            If Len(aData) >= 4
                oSize := aData[4]
            EndIf

            If Len(aData) >= 5
                oOrder := aData[5]
            EndIf

            If Len(aData) >= 6
                oName := aData[6]
            EndIf
        EndIf

        If Empty(AllTrim(oField)) .Or. Empty(AllTrim(oExp)) .Or. Len(AllTrim(oType)) > 1 .Or. ! (AllTrim(oType) $ 'C/N/D')
            Loop
        EndIf

        If ! Empty(AllTrim(oSize))
            oSize := Val(oSize)
        Else
            oSize := 11
        EndIf

        If Empty(AllTrim(oOrder))
            oOrder := cOrder

            cOrder := Soma1(cOrder)
        EndIf

        aAdd(aOtherFld, ApiStructure():New(oField, oOrder, oType, oSize, oName))

        aAdd(::Fields, oExp + ' AS ' + oField)
    Next

    For nI := 1 To Len(::Fields)
        cField := StrTran(::Fields[nI], ' AS ', '&')

        If RAt('&', cField) == 0
            aAdd(aMetadata, ::Fields[nI])

            Loop
        EndIf

        aAdd(aMetadata, SubStr(cField, RAt('&', cField) + 1))
    Next

    ::Dataset:Metadata:GenerateStructure(aMetadata, {})

    For nI := 1 To Len(aOtherFld)
        ::Dataset:Metadata:AddFieldToStructure(aOtherFld[nI])
    Next

    ::Dataset:Metadata:SortStructure()
Return Self

/*/{Protheus.doc} SetRelationship
Adiciona um relacionamento.
@type function
@author Gustavo Marttos
@since 01/10/2019
@version 1.0
@param oRelationship, ApiRelationship, Objeto de ApiRelationship com os respectivos dados.
@return Self, Instância da classe.
/*/
Method AddRelationship(oRelationship) Class ApiDataset
    aAdd(::Relationships, oRelationship)
Return Self

/*/{Protheus.doc} AddConstraint
Adiciona uma constraint da tabela principal.
@type function
@author Gustavo Marttos
@since 01/10/2019
@version 1.0
@param oConstraint, ApiConstraint, Objeto de ApiConstraint.
@return Self, Instância da classe.
/*/
Method AddConstraint(oConstraint) Class ApiDataset
    aAdd(::Constraints, oConstraint)
Return Self

/*/{Protheus.doc} AddOrder
Adiciona uma ordenação.
@type function
@author Gustavo Marttos
@since 07/10/2019
@version 1.0
@param oOrder, ApiOrder, Objeto de ApiOrder.
@return Self, Instância da classe.
/*/
Method AddOrder(oOrder) Class ApiDataset
    aAdd(::Orders, oOrder)
Return Self

/*/{Protheus.doc} ToSql
Retorna o SQL do dataset.
@type function
@author Gustavo Marttos
@since 01/10/2019
@version 1.0
@return cSql, characters, Expressão SQL do dataset.
/*/
Method ToSql() Class ApiDataset
    Local cSql := ''
    Local cSqlAux := ''
    Local nI := 1

    cSql := ' SELECT ROW_NUMBER() OVER (ORDER BY ' + ::TableAlias + '.R_E_C_N_O_) AS IDX '

    If Len(::Fields) > 0
        cSql += ', '
    EndIf

    For nI := 1 To Len(::Fields)
        cSql += StrTran(::Fields[nI], ';', '+')

        If nI < Len(::Fields)
            cSql += ', '
        EndIf
    Next

    cSql += ' FROM ' + ::Table + ' ' + ::TableAlias + ' WITH (NOLOCK) '

    For nI := 1 To Len(::Relationships)
        cSql += ' ' + ::Relationships[nI]:ToSql() + ' '
    Next

    If Len(::Constraints) > 0
        cSql += ' WHERE '

        For nI := 1 To Len(::Constraints)
            cSql += ::Constraints[nI]:ToSql()

            If nI < Len(::Constraints)
                cSql += ' AND '
            EndIf
        Next
    EndIf

    cSqlAux := cSql

    cSql := ' SELECT * FROM (' + cSqlAux + ') AS SPI '
    cSql += ' WHERE IDX BETWEEN ' + cValToChar(::Offset) + ' AND ' + cValToChar(::Offset + ::Fetch) + ' '

    If Len(::Orders) > 0
        cSql += ' ORDER BY '

        For nI := 1 To Len(::Orders)
            cSql += ::Orders[nI]:ToSql()

            If nI < Len(::Orders)
                cSql += ', '
            EndIf
        Next
    EndIf
Return cSql

/*/{Protheus.doc} Execute
Executa as configurações do dataset.
@type function
@author Gustavo Marttos
@since 01/10/2019
@version 1.0
@return oData, ApiData, Objeto de ApiData com os dados.
/*/
Method Execute() Class ApiDataset
    U_RunQuery(::ToSql(), 'QSPI99')

    ::Dataset:Run(::Fetch, 0, /* Filter */, 'QSPI99')
Return ::Dataset
