#include 'protheus.ch'
#include 'restful.ch'
#include 'fwmvcdef.ch'

/*/{Protheus.doc} Rest
Escopo do webservice Restful para manipulação de dados.
@type class
@author Gustavo Marttos
@since 16/10/2019
@version 1.0
/*/
WsRestful Rest Description 'Serviço REST para manipulação de dados.'
    WsData Offset       As Integer
    WsData Fetch        As Integer
    WsData Filter       As String
    WsData Structure    As Integer
    WsData Json         As String

    WsMethod Get Data Description 'Retorna os dados necessários por meio de um payload em JSON.' WsSyntax '/data' Path '/data'
End WsRestful

/*/{Protheus.doc} Get Data
Função responsável pelo retorno de dados do Protheus de acordo com os possíveis relacionamentos.
@type function
@author Gustavo Marttos
@since 16/10/2019
@version 1.0
@return boolean | JsonFault | JsonResponse, Retorno da consulta ao dataset.
/*/
WsMethod Get Data WsReceive Offset, Fetch, Json WsService Rest
    Local aArea := GetArea()
    Local nI := 0
    Local nJ := 0

    Default ::Offset := 0, ::Fetch := 100, ::Json := ''

    ::SetContentType('application/json')

    If ::Json == Nil .Or. Empty(AllTrim(::Json))
        SetRestFault(400, 'The json query parameter is not configured.')

        Return .F.
    EndIf

    oJson := JsonObject():New()
    oJson:fromJson(::Json)

    cTable := oJson:GetJsonText('table')

    oFields := oJson:GetJsonObject('fields')
    oConstraints := oJson:GetJsonObject('constraints')
    oRelationships := oJson:GetJsonObject('relationships')
    oOrders := oJson:GetJsonObject('orders')

    If Empty(AllTrim(cTable)) .Or. ValType(oFields) <> 'A'
        SetRestFault(400, 'Your request is invalid.')

        Return .F.
    EndIf

    oDataset := ApiDataset():New(cTable, oFields, ::Offset, ::Fetch)

    If ValType(oConstraints) == 'A'
        For nI := 1 To Len(oConstraints)
            cField := oConstraints[nI]:GetJsonText('field')
            cValue := oConstraints[nI]:GetJsonText('value')
            cOperator := oConstraints[nI]:GetJsonText('operator')
            cExpression := oConstraints[nI]:GetJsonText('expression')

            If ! Empty(AllTrim(cExpression))
                oDataset:AddConstraint(ApiConstraint():New(cExpression))
            Else
                oDataset:AddConstraint(ApiConstraint():New(cField, cValue, cOperator))
            EndIf
        Next
    EndIf

    If ValType(oRelationships) == 'A'
        For nI := 1 To Len(oRelationships)
            oRelation := oRelationships[nI]

            cTable := oRelation:GetJsonText('table')
            cType := oRelation:GetJsonText('type')
            cAlias := oRelation:GetJsonText('alias')

            If Empty(AllTrim(cTable))
                Loop
            EndIf

            If Empty(AllTrim(cType))
                cType := Nil
            EndIf

            If Empty(AllTrim(cAlias))
                cAlias := Nil
            EndIf

            oRelationship := ApiRelationship():New(cTable, cType, cAlias)

            oConstraints := oRelation:GetJsonObject('constraints')

            If ValType(oConstraints) == 'A'
                For nJ := 1 To Len(oConstraints)
                    cField := oConstraints[nJ]:GetJsonText('field')
                    cValue := oConstraints[nJ]:GetJsonText('value')
                    cOperator := oConstraints[nJ]:GetJsonText('operator')
                    cExpression := oConstraints[nJ]:GetJsonText('expression')

                    If ! Empty(AllTrim(cExpression))
                        oRelationship:AddConstraint(ApiConstraint():New(cExpression))
                    Else
                        oRelationship:AddConstraint(ApiConstraint():New(cField, cValue, cOperator))
                    EndIf
                Next
            EndIf

            oDataset:AddRelationship(oRelationship)
        Next
    EndIf

    If ValType(oOrders) == 'A'
        For nI := 1 To Len(oOrders)
            oOrder := oOrders[nI]

            cField := oOrder:GetJsonText('field')
            cOrder := oOrder:GetJsonText('order')

            oDataset:AddOrder(ApiOrder():New(cField, cOrder))
        Next
    EndIf

    ::SetResponse(FWJsonSerialize(oDataset:Execute(), .F.))

    RestArea(aArea)
Return .T.
