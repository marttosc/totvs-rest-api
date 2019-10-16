#include 'protheus.ch'

/*/{Protheus.doc} ApiMetadata
Clase respons�vel pelos metadados do resource.
@author Gustavo Marttos
@since 11/06/2019
@version 1.0
/*/
Class ApiMetadata
    Data Alias      As String
    Data Name       As String
    Data Key        As String
    Data Structure  As Array
    Data Custom     As Integer

    Method New(cAlias, aFields, aExcluded, lCustom) Constructor
    Method GetStructure()
    Method GetFields()
    Method GenerateStructure()
    Method AddFieldToStructure(oStructure)
    Method GetFieldType(cField)
    Method SortStructure()
    Method UpdateFieldStructure(cField, cType, nSize)
EndClass

/*/{Protheus.doc} New
Construtor da classe ApiMetadata.
@type function
@author Gustavo Marttos
@since 11/06/2019
@version 1.0
@param cAlias, characters, Nome da tabela a ser consultada.
@param aFields, array, Campos da tabela que devem ser retornados.
@param aExcluded, array, Campos da tabela que devem ser desconsiderados.
@param lCustom, boolean, Se o alias � customizado.
@return Self, Inst�ncia da classe.
/*/
Method New(cAlias, aFields, aExcluded, lCustom) Class ApiMetadata
    Default aFields := {'*'}
    Default aExcluded := {}
    Default lCustom := .F.

    ::Alias := cAlias
    ::Structure := {}
    ::Custom := lCustom

    DbSelectArea('SX2')
    SX2->(DbSetOrder(1))
    SX2->(DbGoTop())
    SX2->(MsSeek(::Alias))

    If SX2->(EoF()) .And. ::Custom == 0
        Return
    EndIf

    If ::Custom == 0
        ::Name := EncodeUTF8(AllTrim(SX2->X2_NOME))
        ::Key := AllTrim(StrTran(StrTran(Upper(SX2->X2_UNICO), 'DTOS(', ''), ')', ''))
    Else
        ::Name := EncodeUTF8(AllTrim(Upper(cAlias)))
        ::Key := ''
    EndIf

    ::GenerateStructure(aFields, aExcluded)
Return Self

/*/{Protheus.doc} GetStructure
Retorna o array com a estrutura da tabela informada.
@type function
@author Gustavo Marttos
@since 12/06/2019
@version 1.0
@return array, Array com a estrutura.
/*/
Method GetStructure() Class ApiMetadata
Return ::Structure

/*/{Protheus.doc} GetFields
Retorna o array com os campos da tabela informada.
@type function
@author Gustavo Marttos
@since 12/06/2019
@version 1.0
@return array, Array com os campos.
/*/
Method GetFields() Class ApiMetadata
    Local aFields := {}
    Local nI := 0

    For nI := 1 To Len(::GetStructure())
        aAdd(aFields, ::GetStructure()[nI]:Field)
    Next
Return aFields

/*/{Protheus.doc} GenerateStructure
Cria o array de metadados dos campos da tabela.
@type function
@author Gustavo Marttos
@since 11/06/2019
@version 1.0
@param aFields, array, Campos da tabela que devem ser retornados.
@param aExcluded, array, Campos da tabela que devem ser desconsiderados.
@return Self, Inst�ncia da classe.
/*/
Method GenerateStructure(aFields, aExcluded) Class ApiMetadata
    Local aKeys := StrTokArr2(::Key, '+')
    Local nI := 0

    DbSelectArea('SX3')

    If ::Custom == 0 .And. aFields[1] == '*'
        aFields := {}

        SX3->(DbSetOrder(1))
        SX3->(DbGoTop())
        SX3->(MsSeek(::Alias))

        While ! SX3->(EoF()) .And. SX3->X3_ARQUIVO == ::Alias
            If SX3->X3_CONTEXT == 'V' .Or. aScan(aExcluded, { |x| AllTrim(x) == AllTrim(SX3->X3_CAMPO) }) > 0 .Or. SX3->X3_NIVEL > 5
                SX3->(DbSkip())

                Loop
            EndIf

            aAdd(aFields, SX3->X3_CAMPO)

            ::AddFieldToStructure(ApiStructure():New(SX3->X3_CAMPO, SX3->X3_ORDEM, SX3->X3_TIPO, SX3->X3_TAMANHO + SX3->X3_DECIMAL, SX3->X3_TITULO))

            SX3->(DbSkip())
        EndDo
    Else
        SX3->(DbSetOrder(2))
        SX3->(DbGoTop())

        For nI := 1 To Len(aKeys)
            If aScan(aFields, aKeys[nI]) == 0
                aAdd(aFields, aKeys[nI])
            EndIf
        Next

        For nI := 1 To Len(aFields)
            If nI > Len(aFields)
                Exit
            EndIf

            If ::GetFieldType(aFields[nI]) == Nil
                If SX3->(MsSeek(aFields[nI]))
                    If SX3->X3_CONTEXT == 'V' .Or. SX3->X3_NIVEL > 5
                        Loop
                    EndIf

                    ::AddFieldToStructure(ApiStructure():New(SX3->X3_CAMPO, SX3->X3_ORDEM, SX3->X3_TIPO, SX3->X3_TAMANHO + SX3->X3_DECIMAL, SX3->X3_TITULO))
                EndIf
            EndIf
        Next
    EndIf

    ::SortStructure()

    If ::GetFieldType('RECNO') == Nil
        ::AddFieldToStructure(ApiStructure():New('RECNO', 'ZZ', 'N', 11, 'Record Number'))
    EndIf
Return Self

/*/{Protheus.doc} AddFieldToStructure
Adiciona um novo campo � estrutura.
@type function
@author Gustavo Marttos
@since 12/06/2019
@version 1.0
@param oStructure, object, Objeto do tipo ApiStructure.
@return Self, Inst�ncia da classe.
/*/
Method AddFieldToStructure(oStructure) Class ApiMetadata
    aAdd(::Structure, oStructure)
Return Self

/*/{Protheus.doc} GetFieldType
Retorna o tipo do campo informado de acordo com a SX3.
@type function
@author Gustavo Marttos
@since 12/06/2019
@version 1.0
@param cField, characters, Nome do campo cadastrado na SX3.
@return characters, Tipo do campo informado.
/*/
Method GetFieldType(cField) Class ApiMetadata
    Local cType := Nil
    Local nI := 0

    If (nI := aScan(::GetStructure(), {|x| x:Field == cField })) > 0
        cType := ::GetStructure()[nI]:Type
    EndIf
Return cType

/*/{Protheus.doc} SortStructure
Ordena os campos da estrutura.
@type function
@author Gustavo Marttos
@since 12/06/2019
@version 1.0
/*/
Method SortStructure() Class ApiMetadata
    ::Structure := aSort(::GetStructure(), , , { |x, y| x:Order < y:Order })
Return

/*/{Protheus.doc} UpdateFieldStructure
Ordena os campos da estrutura.
@type function
@author Gustavo Marttos
@since 12/06/2019
@version 1.0
@param cField, characters, Campo a ser atualizado.
@param cType, characters, Novo tipo do dado do campo.
@param nSize, numeric, Novo tamanho do campo.
/*/
Method UpdateFieldStructure(cField, cType, nSize) class ApiMetadata
    Local nI := 0
    Local oStructure

    Default nSize := Nil

    If (nI := aScan(::GetStructure(), { |x| x:Field == cField })) > 0
        oStructure := ::GetStructure()[nI]

        oStructure:Type := cType

        If nSize != Nil
            oStructure:Size := nSize
        EndIf

        ::GetStructure()[nI] := oStructure
    EndIf
Return
