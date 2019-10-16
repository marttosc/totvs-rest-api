#include 'protheus.ch'

/*/{Protheus.doc} ApiField
Classe respons�vel pelo dado por campo �nico.
@type class
@author Gustavo Marttos
@since 20/02/2018
@version 1.0
/*/
Class ApiField
    Data Field  As String
    Data Value  As String

    Method New(cField, cValue) Constructor
    Method GetField()
    Method GetValue()
EndClass

/*/{Protheus.doc} New
Construtor da classe ApiField.
@type function
@author Gustavo Marttos
@since 20/02/2018
@version 1.0
@param cField, characters, Nome do campo do alias de acordo com a SX3.
@param cValue, characters, Valor do campo do alias.
@return Self, Inst�ncia da classe.
@example ApiField():New('R6_TURNO', '050')
/*/
Method New(cField, cValue) Class ApiField
    ::Field := cField
    ::Value := cValue
Return Self

/*/{Protheus.doc} GetField
Retorna o nome do campo.
@type function
@author Gustavo Marttos
@since 24/09/2019
@version 1.0
@return characters, Nome do campo.
/*/
Method GetField() Class ApiField
Return ::Field

/*/{Protheus.doc} GetValue
Retorna o valor do campo.
@type function
@author Gustavo Marttos
@since 24/09/2019
@version 1.0
@return characters, Valor do campo.
/*/
Method GetValue() Class ApiField
Return ::Value
