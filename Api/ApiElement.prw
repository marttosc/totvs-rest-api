#include 'protheus.ch'

/*/{Protheus.doc} ApiElement
Classe respons�vel pelo registro do alias, o qual cont�m objetos do tipo ApiField.
@type class
@author Gustavo Marttos
@since 20/02/2018
@version 1.0
/*/
Class ApiElement
    Data Element    As Array

    Method New() Constructor
    Method Add(oField)
EndClass

/*/{Protheus.doc} New
Construtor da classe ApiElement. Inicia o vetor Element.
@type function
@author Gustavo Marttos
@since 20/02/2018
@version 1.0
@return Self, Inst�ncia da classe.
@example ApiElement():New()
/*/
Method New() Class ApiElement
    ::Element := {}
Return Self

/*/{Protheus.doc} Add
Inclui no vetor ::Element um objeto do tipo ApiField.
@type function
@author Gustavo Marttos
@since 20/02/2018
@version 1.0
@param oField, object, Objeto do tipo ApiField a ser inclu�do no array ::Element.
@return Self, Inst�ncia da classe.
@example
    oElement := ApiElement():New()
    oElement:Add(ApiField():New('R6_TURNO', '520'))
/*/
Method Add(oField) Class ApiElement
    aAdd(::Element, oField)
Return Self
