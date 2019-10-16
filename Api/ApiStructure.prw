#include 'protheus.ch'

/*/{Protheus.doc} ApiStructure
Classe respons�vel pelo dado por campo �nico.
@type class
@author Gustavo Marttos
@since 21/02/2018
@version 1.0
/*/
Class ApiStructure
    Data Field  As String
    Data Order  As String
    Data Type   As String
    Data Size   As Integer
    Data Name   As String

    Method New(cField, cOrder, cType, nSize, cName) Constructor
EndClass

/*/{Protheus.doc} New
Construtor da classe ApiStructure.
@type function
@author Gustavo Marttos
@since 21/02/2018
@version 1.0
@param cField, characters, Nome do campo, preferencialmente na SX3.
@param cOrder, characters, Ordem do campo, preferencialmente na SX3.
@param cType, characters, Tipo do campo, preferencialmente na SX3.
@param nSize, numeric, Tamanho do campo, preferencialmente na SX3.
@param cName, characters, Tome do campo, preferencialmente na SX3.
@return Self, Inst�ncia da classe.
/*/
Method New(cField, cOrder, cType, nSize, cName) Class ApiStructure
    ::Name := EncodeUTF8(AllTrim(cName))
    ::Order := AllTrim(cOrder)
    ::Field := AllTrim(cField)
    ::Type := AllTrim(cType)
    ::Size := nSize
Return Self
