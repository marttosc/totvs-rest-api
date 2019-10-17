#include 'protheus.ch'

#define _EVAL '~>'

/*/{Protheus.doc} ApiData
Classe responsável pelo registro dos dados, o qual contém objetos do tipo ApiElement.
@type class
@author Gustavo Marttos
@since 20/02/2018
@version 1.0
/*/
Class ApiData
    Data Elements       As Array
    Data Metadata       As ApiMetadata
    Data Total          As Integer
    Data HasNext        As Integer
    Data IgnoreEmpty    As Integer

    Method New(cAlias, aFields, aExcluded, lCustom) Constructor
    Method Get()
    Method Add(oElement)
    Method Run(nCount, nIndex, cFilter, cAlias)
    Method SetIgnoreEmpty(lIgnore)
    Method IsIgnoringEmpty()
EndClass

/*/{Protheus.doc} New
Construtor da classe ApiData. Inicia o vetor Elements.
@type function
@author Gustavo Marttos
@since 20/02/2018
@version 1.0
@param cAlias, characters, Nome da tabela a ser consultada.
@param aFields, array, Campos da tabela que devem ser retornados.
@param aExcluded, array, Campos da tabela que devem ser desconsiderados.
@param lCustom, boolean, Se o alias é customizado.
@return Self, Instância da classe.
@example ApiData():New(cAlias)
/*/
Method New(cAlias, aFields, aExcluded, lCustom) Class ApiData
    ::Elements := {}
    ::Total := 0
    ::HasNext := 0

    ::SetIgnoreEmpty(.F.)

    ::Metadata := ApiMetadata():New(cAlias, aFields, aExcluded, lCustom)
Return Self

/*/{Protheus.doc} Add
Inclui no vetor ::Elements um objeto do tipo ApiElement.
@type function
@author Gustavo Marttos
@since 20/02/2018
@version 1.0
@param oElement, object, Objeto do tipo ApiElement a ser incluído no array ::Elements.
@return Self, Instância da classe.
/*/
Method Add(oElement) Class ApiData
    aAdd(::Elements, oElement)
Return Self

/*/{Protheus.doc} Get
Retorna o array com os dados.
@type function
@author Gustavo Marttos
@since 21/02/2018
@version 1.0
@return array, Array com os dados.
/*/
Method Get() Class ApiData
Return ::Elements

/*/{Protheus.doc} SetIgnoreEmpty
Define a propriedade booleana IgnoreEmpty.
Se .T., será validado se a concatenação de todos os dados da linha é vazia.
@type function
@author Gustavo Marttos
@since 24/09/2019
@version 1.0
@param lIgnore, boolean, Se deve ignorar resultados vazios ou não (default .F.).
@return Self, Instância da classe.
/*/
Method SetIgnoreEmpty(lIgnore) Class ApiData
    Default lIgnore := .F.

    ::IgnoreEmpty := lIgnore
Return Self

/*/{Protheus.doc} IsIgnoringEmpty
Verifica por meio do valor da propriedade booleana IgnoreEmpty se deve ignorar valores vazios.
@type function
@author Gustavo Marttos
@since 24/09/2019
@version 1.0
@return boolean, Se os resultados vazios deverão ser ignorados.
/*/
Method IsIgnoringEmpty() Class ApiData
Return ::IgnoreEmpty == 1

/*/{Protheus.doc} Run
Popula ::Elements com os dados da tabela.
@type function
@author Gustavo Marttos
@since 12/06/2019
@version 1.0
@param nCount, numeric, Quantidade de registros a serem retornados.
@param nIndex, numeric, índice a partir do qual deve ser retornado.
@param cFilter, characters, Filtro em AdvPL a ser aplicado no alias.
@param cAlias, characters, Nome do alias de consulta.
@return Self, Instância da classe.
@obs
    - Filtros não podem conter funções de usuário;
    - Se o valor do campo for de tipo caracter, for customizado e começar com const::_EVAL (~>),
        será interpretado que este deve ser executado como um comando AdvPL.
        Exemplo: campo Z99_DTOS com o valor '~>DToS(dDatabase)'.
/*/
Method Run(nCount, nIndex, cFilter, cAlias) Class ApiData
    Local aFields := {}
    Local cType := ''
    Local uValue := Nil
    Local oElement := Nil
    Local oField := Nil
    Local nI := 0
    Local lAlias := .F. // Alias da SX3.
    Local cVldVal := '' // Used to validate the value when the data must not be empty.
    Local lIsValid := .T. // Same as cVldVal.

    Default nCount := 0
    Default nIndex := 0
    Default cFilter := ''
    Default cAlias := Nil

    If cAlias == Nil
        cAlias := ::Metadata:Alias

        lAlias := .T.
    EndIf

    DbSelectArea(cAlias)

    If lAlias
        (cAlias)->(DbSetOrder(1))
    EndIf

    (cAlias)->(DbGoTop())

    If ! Empty(AllTrim(cFilter)) .And. lAlias
        If ! (' U_' $ cFilter) .And. SubStr(AllTrim(cFilter), 1, 2) != 'U_'
            (cAlias)->(DbSetFilter({|| &cFilter}, cFilter))
            (cAlias)->(DbGoTop())
        EndIf
    EndIf

    If (cAlias)->(EoF())
        Return Self
    EndIf

    If nIndex > 0
        // Zero-based numbering.
        (cAlias)->(DbSkip(nIndex - 1))
    EndIf

    While ! (cAlias)->(EoF())
        If nCount > 0 .And. Len(::Get()) == nCount
            Exit
        EndIf

        oElement := ApiElement():New()

        aFields := ::Metadata:GetFields()

        For nI := 1 To Len(aFields)
            If aFields[nI] == 'RECNO'
                Loop
            EndIf

            cType := ::Metadata:GetFieldType(aFields[nI])
            uValue := (cAlias)->&(aFields[nI])

            If ! lAlias .And. cType == 'C' .And. ValType(uValue) != 'C'
                cType := ValType(uValue)

                ::Metadata:UpdateFieldStructure(aFields[nI], cType)
            EndIf

            If ! lAlias .And. cType == 'C' .And. SubStr(uValue, 1, 2) == _EVAL
                uValue := &(SubStr(uValue, 3))

                cType := ValType(uValue)

                ::Metadata:UpdateFieldStructure(aFields[nI], cType)
            EndIf

            If cType == 'D' .And. ValType(uValue) == 'D'
                uValue := DToS(uValue)
            ElseIf cType == 'C'
                uValue := EncodeUTF8(uValue)
            EndIf

            If cType == 'D' .And. ValType(uValue) == 'C'
                If Empty(AllTrim(uValue))
                    uValue := Nil
                Else
                    uValue := SubStr(uValue, 1, 4) + '-' + SubStr(uValue, 5, 2) + '-' + SubStr(uValue, 7)
                EndIf
            EndIf

            If ValType(uValue) == 'C'
                uValue := AllTrim(StrTran(StrTran(uValue, '"', ''), '\', '\\'))
            EndIf

            oField := ApiField():New(aFields[nI], uValue)

            oElement:Add(oField)
        Next

        oElement:Add(ApiField():New('RECNO', (cAlias)->(Recno())))

        lIsValid := .T.
        cVldVal := ''

        If ::IsIgnoringEmpty()
            For nI := 1 To Len(oElement:Element)
                If (oElement:Element[nI]:GetField() == 'RECNO')
                    Loop
                EndIf

                cVldVal += cValToChar(oElement:Element[nI]:GetValue())
            Next

            If Empty(AllTrim(cVldVal))
                lIsValid := .F.
            EndIf
        EndIf

        If lIsValid
            ::Add(oElement)
        EndIf

        (cAlias)->(DbSkip())
    EndDo

    If (cAlias)->(EoF())
        ::HasNext := 0
    Else
        ::HasNext := 1
    EndIf

    If lAlias
        (cAlias)->(DbClearFilter())
    EndIf

    ::Total := Len(::Get())
Return Self
