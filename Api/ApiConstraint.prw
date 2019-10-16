#include 'protheus.ch'

/*/{Protheus.doc} ApiConstraint
Classe responsável pela estrutura das constraints.
@type class
@author Gustavo Marttos
@since 01/10/2019
@version 1.0
/*/
Class ApiConstraint
    Data Field      As String
    Data Operator   As String
    Data Value      As String
    Data Expression As String

    Method New(cField, cValue, cOperator) Constructor
    Method ToSql()
EndClass

/*/{Protheus.doc} New
Construtor da classe ApiConstraint. Inicia os vetores e strings como vazias.
@type function
@author Gustavo Marttos
@since 01/10/2019
@version 1.0
@param cField, characters, Nome do campo ou o conteúdo da expressão SQL.
@param cValue, characters, Valor do campo.
@param cOperator, characters, Operador lógico entre o campo e o valor.
@return Self, Instância da classe.
@example ApiConstraint():New(cField, cValue, cOperator)
@obs
    oConstraint := ApiConstraint():New('RA_FILIAL', '0101')
    oConstraint := ApiConstraint():New('RA_FILIAL', 'XXXX', '<>')
    oConstraint := ApiConstraint():New('RA_FILIAL NOT IN ("XYZ")')
/*/
Method New(cField, cValue, cOperator) Class ApiConstraint
    Local lExpr := .F.

    ::Field := ''
    ::Operator := ''
    ::Value := ''
    ::Expression := ''

    If Empty(AllTrim(cField))
        cField := Nil
    EndIf

    If Empty(AllTrim(cValue))
        cValue := Nil
    ElseIf cValue == '_EMPTY'
        cValue := ' '
    EndIf

    If Empty(AllTrim(cOperator))
        cOperator := Nil
    EndIf

    If cOperator == Nil .And. cValue == Nil
        ::Expression := cField

        lExpr := .T.
    EndIf

    If cOperator == Nil
        cOperator := '='
    EndIf

    If ! lExpr
        ::Field := cField
        ::Operator := cOperator
        ::Value := cValue
    EndIf

    ::Value := StrTran(::Value, '"', "'")
    ::Expression := StrTran(StrTran(::Expression, '"', "'"), '~', '"')
Return Self

/*/{Protheus.doc} ToSql
Retorna o SQL da constraint.
@type function
@author Gustavo Marttos
@since 01/10/2019
@version 1.0
@return cSql, characters, Expressão SQL da constraint.
@example ApiConstraint():New(cField, cValue, cOperator):ToSql()
@obs
    oConstraint := ApiConstraint():New('RA_FILIAL', '0101')
    ConOut(oConstraint:ToSql()) // RA_FILIAL = "0101"
/*/
Method ToSql() Class ApiConstraint
    Local cSql := ''

    If ! Empty(AllTrim(::Expression))
        Return StrTran(::Expression, ';', '+')
    EndIf

    cSql := StrTran(::Field, ';', '+') + ' ' + ::Operator + ' '

    If At(',', ::Value) > 0 .Or. At('(', ::Value) > 0 .Or. At(')', ::Value) > 0 .Or. At('_', ::Value) > 0 .Or. At(';', ::Value) > 0
        cSql += StrTran(::Value, ';', '+')
    Else
        cSql += "'" + ::Value + "'"
    EndIf

    cSql += ' '
Return cSql
