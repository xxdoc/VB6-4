VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ssHUC"
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
  'Code must be set for this MCD before this will work
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
'    sql = "SELECT STATION.* FROM [STATION] WHERE " & _
'          "STATION.HUC='" & pCode & "' AND StateCode='" & pDB.State.Code & _
'          "' ORDER BY StaID;"
    sql = "SELECT STATION.* FROM " & _
          "[StationState] INNER JOIN STATION ON [StationState].[StaID]=[STATION].[StaID] " & _
          "WHERE STATION.HUC='" & pCode & "' AND [StationState].[StateCode]='" & pDB.State.code & _
          "' ORDER BY STATION.StaID;"
    Set stationRec = pDB.DB.OpenRecordset(sql, dbOpenForwardOnly)
    While Not stationRec.EOF
      Set newStation = New ssStation
      With newStation
        Set .DB = pDB
        Set .HUC = Me
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
        
        'Now set the true State this new station is actually in
        If .StateCode = .State.code Then
          Set .StateLoc = Me.State
        Else
          Set .StateLoc = New nssState
          
          Dim myRec As Recordset
          Dim sql2 As String
          sql2 = "SELECT * FROM States WHERE StateCode='" & .StateCode & "';"
          Set myRec = pDB.DB.OpenRecordset(sql2, dbOpenForwardOnly)
          Dim lROIData As nssROI
          Set lROIData = New nssROI
          With .StateLoc
            Set .DB = pDB
            .Name = myRec.Fields("State")
            .Abbrev = myRec.Fields("ST")
            .code = myRec.Fields("StateCode")
            .Metric = myRec.Fields("Metric")
            Set lROIData.DB = pDB
            lROIData.StateCode = .code
            lROIData.ClimateFactor = myRec.Fields("ROIClimateFactor")
            lROIData.Distance = myRec.Fields("ROIDistance")
            lROIData.Regress = myRec.Fields("ROIBackStepRegression")
            lROIData.UseRegions = myRec.Fields("ROIRegions")
            lROIData.SimStations = myRec.Fields("ROISimStations")
    '       lCode = Right(.code, 2)
    '       If States.KeyExists(lCode) Then
    '         'just add other ROI data from this 2nd occurrence
    '         If CInt(.code) > 10000 Then
    '           Set States(lCode).ROILowData = lROIData
    '         Else
    '           Set States(lCode).ROIPeakData = lROIData
    '         End If
    '       Else 'add state (and this ROI data) to collection
    '         If CInt(.code) > 10000 Then 'low flow ROI data
    '           .code = lCode
    '           Set .ROILowData = lROIData
    '         Else
    '           Set .ROIPeakData = lROIData
    '         End If
    '       End If
          End With
          myRec.Close
        End If
                
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

