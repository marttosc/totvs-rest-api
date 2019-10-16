/*/{Protheus.doc} ApiOrder
Classe responsável pela estrutura dos dados a serem ordenados.
@type class
@author Gustavo Marttos
@since 07/10/2019
@version 1.0
/*/
Class ApiOrder
    Data Field  As String
    Data Order  As String

    Method New(cField, cOrder) Constructor
    Method ToSql()
EndClass

/*/{Protheus.doc} New
Construtor da classe ApiOrder. Define o campo e o tipo de ordenação.
@type function
@author Gustavo Marttos
@since 07/10/2019
@version 1.0
@param cField, characters, Nome do campo.
@param cOrder, characters, Ordem do campo ASC ou DESC.
@return Self, Instância da classe.
@example ApiOrder():New()
/*/
Method New(cField, cOrder) Class ApiOrder
    Default cOrder := 'ASC'

    cField := AllTrim(cField)
    cOrder := AllTrim(cOrder)

    If Empty(cField)
        cField := 'IDX'
    EndIf

    If Empty(cOrder) .Or. (Upper(cOrder) != 'ASC' .And. Upper(cOrder) != 'DESC')
        cOrder := 'ASC'
    EndIf

    ::Field := cField
    ::Order := cOrder
Return Self

/*/{Protheus.doc} ToSql
Retorna o SQL da ordenação.
@type function
@author Gustavo Marttos
@since 07/10/2019
@version 1.0
@return cSql, characters, Expressão SQL da ordenação.
/*/
Method ToSql() Class ApiOrder
    Local cSql := ::Field + ' ' + ::Order
Return cSql
