VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ssCounty"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private pName As String
Private pCode As String
Private pDB As nssDatabase
Private pState As nssState
Private pStation As ssStation
Private pStations As FastCollection 'of ssStations

Public Property Get Name() As String
  Name = pName
End Property
Public Property Let Name(ByVal newValue As String)
  pName = newValue
End Property

Public Property Get code() As String
  code = pCode
End Property
Public Property Let code(ByVal newValue As String)
  pCode = newValue
End Property

Public Property Get DB() As nssDatabase
  Set DB = pDB
End Property
Public Property Set DB(newValue As nssDatabase)
  Set pDB = newValue
End Property

Public Property Get State() As nssState
  Set State = pState
End Property
Public Property Set State(ByVal newValue As nssState)
  Set pState = newValue
End Property

Public Property Get Station() As ssStation
  Set Station = pStation
End Property
Public Property Set Station(ByVal newValue As ssStation)
  Set pStation = newValue
End Property

Public Property Set Stations(ByRef newValue As FastCollection)
  Set pStations = newValue
End Property
Public Property Get Stations() As FastCollection
  ' Code must be set for this County before this will work
  If pStations Is Nothing Then PopulateStations
  Set Stations = pStations
End Property

Public Sub PopulateStations()
  Dim newStation As ssStation
  Dim stationRec As Recordset
  Dim sql$
  
  Set pStations = New FastCollection
  If pDB Is Nothing Then
    ssMessageBox "Cannot read Stations" & vbCr & "DB not set."
  Else
'    sql = "SELECT * FROM [Station] WHERE " & _
'          "CountyCode='" & pCode & "' AND StateCode='" & pDB.State.Code & _
'          "' ORDER BY StaID;"
    sql = "SELECT STATION.* FROM " & _
          "[StationState] INNER JOIN STATION ON [StationState].[StaID]=[STATION].[StaID] " & _
          "WHERE CountyCode='" & pCode & "' AND [StationState].[StateCode]='" & pDB.State.code & _
          "' ORDER BY STATION.StaID;"
    Set stationRec = pDB.DB.OpenRecordset(sql, dbOpenForwardOnly)
    While Not stationRec.EOF
      Set newStation = New ssStation
      With newStation
        Set .DB = pDB
        Set .County = Me
        .Id = stationRec("StaID")
        If Not IsNull(stationRec("StationName")) Then .Name = stationRec("StationName")
        If Not IsNull(stationRec("StationName")) Then .Label = stationRec("StationName")
        If Not IsNull(stationRec("Agency_cd")) Then .AgencyCode = stationRec("Agency_cd")
        If Not IsNull(stationRec("StationTypeCode")) Then Set .StationType = GetStationType(stationRec("StationTypeCode"))
        If Not IsNull(stationRec("IsRegulated")) Then .IsRegulated = stationRec("IsRegulated")
        If Not IsNull(stationRec("PeriodOfRecord")) Then .Period = stationRec("PeriodOfRecord")
        If Not IsNull(stationRec("StationRemarks")) Then .Remarks = stationRec("StationRemarks")
        If Not IsNull(stationRec("Latitude")) Then .Latitude = stationRec("Latitude")
        If Not IsNull(stationRec("Longitude")) Then .Longitude = stationRec("Longitude")
        If Not IsNull(stationRec("HUC")) Then .HUCCode = stationRec("HUC")
        If Not IsNull(stationRec("Statebasin")) Then .StatebasinCode = (stationRec("Statebasin"))
        If Not IsNull(stationRec("CountyCode")) Then .CountyCode = stationRec("CountyCode")
        'If Not IsNull(stationRec("MCDCode")) Then .MCDCode = stationRec("MCDCode")
        If Not IsNull(stationRec("Directions")) Then .Directions = stationRec("Directions")
        'If Not IsNull(stationRec("HasData")) Then .HasData = stationRec("HasData")
        If Not IsNull(stationRec("StateCode")) Then .StateCode = stationRec("StateCode")
        If Not IsNull(stationRec("DistrictCode")) Then .DistrictCode = stationRec("DistrictCode")
        If Not IsNull(stationRec("HCDN")) Then .HCDN = stationRec("HCDN")
        If Not IsNull(stationRec("Station_md")) Then .StationMd = Split(stationRec("Station_md").Value)(0)
        Set .State = Me.State
        .IsNew = False
      End With
      
      If Not pStations.KeyExists(newStation.Id) Then
        'handles the case of multiple stations on StationState table for ROI
        pStations.Add newStation, newStation.Id
      End If
      
      
      Set newStation = Nothing
      stationRec.MoveNext
    Wend
    stationRec.Close
  End If
End Sub

Private Function GetStationType(TypeCode As String) As ssStationType
  Dim myRec As Recordset
  
  Set GetStationType = New ssStationType
  Set myRec = pDB.DB.OpenRecordset("STATIONTYPE", dbOpenSnapshot)
  With myRec
    .FindFirst "StationTypeCode='" & TypeCode & "'"
    If Not .NoMatch Then
      Set GetStationType.DB = pDB
      GetStationType.code = .Fields("StationTypeCode")
      GetStationType.Name = .Fields("StationType")
    End If
  End With
End Function

Private Sub Class_Initialize()
  pName = "Not Assigned"
End Sub

