#include 'protheus.ch'

/*/{Protheus.doc} ApiRelationship
Classe responsável pela estrutura dos relacionamentos.
@type class
@author Gustavo Marttos
@since 01/10/2019
@version 1.0
/*/
Class ApiRelationship
    Data Table          As String
    Data TableAlias     As String
    Data Type           As String
    Data Constraints    As Array

    Method New(cTable, cType, cAlias) Constructor
    Method AddConstraint(oConstraint)
    Method ToSql()
EndClass

/*/{Protheus.doc} New
Construtor da classe ApiRelationship.
@type function
@author Gustavo Marttos
@since 01/10/2019
@version 1.0
@param cTable, characters, Nome da tabela.
@param cType, characters, Tipo do relacionamento (INNER, LEFT ou RIGHT).
@param cAlias, characters, Alias da tabela.
@return Self, Instância da classe.
@example ApiRelationship():New(cTable, cType, cAlias)
@obs
    oRelationship := ApiRelationship():New('CTT')
    oRelationship := ApiRelationship():New('CTT', 'left')
    oRelationship := ApiRelationship():New('CTT', 'inner', 'CTT_2')
/*/
Method New(cTable, cType, cAlias) Class ApiRelationship
    Default cType := 'inner'

    If ! (AllTrim(Lower(cType)) $ 'inner/right/left')
        cType := 'inner'
    EndIf

    ::Table := IIf(Len(AllTrim(cTable)) == 3, RetSqlName(cTable), cTable)
    ::TableAlias := IIf(cAlias == Nil, cTable, cAlias)
    ::Type := Upper(cType)
    ::Constraints := {}

    ::AddConstraint(ApiConstraint():New(::TableAlias + '.D_E_L_E_T_', '_EMPTY'))
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
Method AddConstraint(oConstraint) Class ApiRelationship
    aAdd(::Constraints, oConstraint)
Return Self

/*/{Protheus.doc} ToSql
Retorna o SQL do relacionamento.
@type function
@author Gustavo Marttos
@since 01/10/2019
@version 1.0
@return cSql, characters, Expressão SQL do relacionamento.
/*/
Method ToSql() Class ApiRelationship
    Local cSql := ''
    Local nI := 1

    cSql := ::Type + ' JOIN ' + ::Table + ' ' + ::TableAlias + ' WITH (NOLOCK) '

    If Len(::Constraints) > 0
        cSql += ' ON '

        For nI := 1 To Len(::Constraints)
            cSql += ::Constraints[nI]:ToSql()

            If nI < Len(::Constraints)
                cSql += ' AND '
            EndIf
        Next
    EndIf
Return cSql
