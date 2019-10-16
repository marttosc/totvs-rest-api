#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

/*/{Protheus.doc} RunQuery
Executa uma query e a atribui a um alias.
@type function
@author Gustavo Marttos
@since 16/10/2019
@version 1.0
@return void
/*/
User Function RunQuery(cSql, cAlias)
    Local aStruct := {}
    Local nInd := 0
    Local nRegSx3 := SX3->(Recno())
    Local nOrdSx3 := SX3->(IndexOrd())

    If Select(cAlias) > 0
        (cAlias)->(DbCloseArea())
    EndIf

    TcQuery cSql New Alias &(cAlias)

    DbSelectArea(cAlias)

    aStruct := DbStruct()

    SX3->(DbSetOrder(2))

    For nInd := 1 To Len(aStruct)
        If SX3->(MsSeek(aStruct[nInd, 1])) <> .And. SX3->X3_TIPO <> 'C'
            TcSetField(cAlias, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL)
        EndIf
    Next

    SX3->(DbGoTop(nRegSx3))
    SX3->(DbSetOrder(nOrdSx3))
Return
