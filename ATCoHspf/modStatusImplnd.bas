Attribute VB_Name = "modStatusImplnd"
Option Explicit
'Copyright 2002 AQUA TERRA Consultants - Royalty-free use permitted under open source license

Public Sub UpdateImplnd(O As HspfOperation, TableStatus As HspfStatus)
  Dim ltable As HspfTable
  Dim i&, t$, f$
  'added flag for snow THJ
  Dim Vkmfg&
  Dim Vrsfg&, Vnnfg&
  Dim Vasdfg&, Vrsdfg&
  Dim Wtfvfg&
  Dim Nqual&, Vpfwfg&, Vqofg&, tabname$
  
  'always can be present
  TableStatus.Change "ACTIVITY", 1, HspfStatusRequired
  TableStatus.Change "PRINT-INFO", 1, HspfStatusOptional
  TableStatus.Change "GEN-INFO", 1, HspfStatusRequired
  
  If O.TableExists("ACTIVITY") Then
    Set ltable = O.Tables("ACTIVITY")
    If ltable.Parms("ATMPFG") = 1 Then
      TableStatus.Change "ATEMP-DAT", 1, HspfStatusOptional
    End If
    If ltable.Parms("SNOWFG") = 1 Then
      TableStatus.Change "ICE-FLAG", 1, HspfStatusOptional
      TableStatus.Change "SNOW-FLAGS", 1, HspfStatusOptional
      If O.TableExists("SNOW-FLAGS") Then
        Vkmfg = O.Tables("SNOW-FLAGS").Parms("VKMFG")
      Else
        Vkmfg = 0
      End If
      TableStatus.Change "SNOW-PARM1", 1, HspfStatusRequired
      TableStatus.Change "SNOW-PARM2", 1, HspfStatusOptional
      If Vkmfg = 1 Then
        TableStatus.Change "MON-MELT-FAC", 1, HspfStatusOptional
      End If
      TableStatus.Change "SNOW-INIT1", 1, HspfStatusOptional
      TableStatus.Change "SNOW-INIT2", 1, HspfStatusOptional
    End If
    If ltable.Parms("IWATFG") = 1 Then
      TableStatus.Change "IWAT-PARM1", 1, HspfStatusOptional
      If O.TableExists("IWAT-PARM1") Then
        Vrsfg = O.Tables("IWAT-PARM1").Parms("VRSFG")
        Vnnfg = O.Tables("IWAT-PARM1").Parms("VNNFG")
        If ltable.Parms("SNOWFG") = 1 Then
          O.Tables("IWAT-PARM1").Parms("CSNOFG") = 1
        End If
      Else
        Vrsfg = 0
        Vnnfg = 0
      End If
      TableStatus.Change "IWAT-PARM2", 1, HspfStatusRequired
      TableStatus.Change "IWAT-PARM3", 1, HspfStatusOptional
      If Vrsfg = 1 Then
        TableStatus.Change "MON-RETN", 1, HspfStatusOptional
      End If
      If Vnnfg = 1 Then
        TableStatus.Change "MON-MANNING", 1, HspfStatusOptional
      End If
      TableStatus.Change "IWAT-STATE1", 1, HspfStatusOptional
    End If
    If ltable.Parms("SLDFG") = 1 Then
      TableStatus.Change "SLD-PARM1", 1, HspfStatusOptional
      If O.TableExists("SLD-PARM1") Then
        Vasdfg = O.Tables("SLD-PARM1").Parms("VASDFG")
        Vrsdfg = O.Tables("SLD-PARM1").Parms("VRSDFG")
      Else
        Vasdfg = 0
        Vrsdfg = 0
      End If
      TableStatus.Change "SLD-PARM2", 1, HspfStatusRequired
      If Vasdfg = 1 Then
        TableStatus.Change "MON-SACCUM", 1, HspfStatusOptional
      End If
      If Vrsdfg = 1 Then
        TableStatus.Change "MON-REMOV", 1, HspfStatusOptional
      End If
      TableStatus.Change "SLD-STOR", 1, HspfStatusOptional
    End If
    If ltable.Parms("IWGFG") = 1 Then
      TableStatus.Change "IWT-PARM1", 1, HspfStatusOptional
      If O.TableExists("IWT-PARM1") Then
        Wtfvfg = O.Tables("IWT-PARM1").Parms("WTFVFG")
      Else
        Wtfvfg = 0
      End If
      TableStatus.Change "IWT-PARM2", 1, HspfStatusOptional
      TableStatus.Change "LAT-FACTOR", 1, HspfStatusOptional
      If Wtfvfg = 1 Then
        TableStatus.Change "MON-AWTF", 1, HspfStatusOptional
        TableStatus.Change "MON-BWTF", 1, HspfStatusOptional
      End If
      TableStatus.Change "IWT-INIT", 1, HspfStatusOptional
    End If
    If ltable.Parms("IQALFG") = 1 Then
      TableStatus.Change "NQUALS", 1, HspfStatusOptional
      If O.TableExists("NQUALS") Then
        Nqual = O.Tables("NQUALS").Parms("NQUAL")
      Else
        Nqual = 1
      End If
      TableStatus.Change "IQL-AD-FLAGS", 1, HspfStatusOptional
      TableStatus.Change "LAT-FACTOR", 1, HspfStatusOptional
      'i'm assuming that it is ok to set this twice - either section can ask
      'for it.  same for PERLND LAT-FACTOR (PWTGAS, PQUAL); PERLND SOIL-DATA
      '(PWATER, PEST, NITR, PHOS); PERLND SOIL-DATA2 (PWATER,NITR).  THJ
      'need more here for monthly values - what do you refer to here? THJ
      For i = 1 To Nqual
        TableStatus.Change "QUAL-PROPS", i, HspfStatusRequired
        If i > 1 Then
          tabname = "QUAL-PROPS:" & i
        Else
          tabname = "QUAL-PROPS"
        End If
        If O.TableExists(tabname) Then
          Vpfwfg = O.Tables(tabname).Parms("VPFWFG")
          Vqofg = O.Tables(tabname).Parms("VQOFG")
        Else
          Vpfwfg = 0
          Vqofg = 0
        End If
        TableStatus.Change "QUAL-INPUT", i, HspfStatusOptional
        If Vpfwfg = 1 Then
          TableStatus.Change "MON-POTFW", i, HspfStatusRequired
        End If
        If Vqofg = 1 Then
          TableStatus.Change "MON-ACCUM", i, HspfStatusRequired
          TableStatus.Change "MON-SQOLIM", i, HspfStatusRequired
        End If
      Next i
      'the use of "i" here is inaccurate.  E.G. if you have four quals, but
      'only the first and fourth are solids associated, then the fourth qual
      'will look for the second occurrence of MON-POTFW (assuming VPFWFG is 1
      'for both), not the fourth.
      'On the other hand, if all four are solids associated, but only the first
      'and fourth have VPFWFG=1, then the fourth *will* look for the fourth
      'occurrence, meaning that there have to be dummy tables for the second
      'and third! I think your code finds this correctly, but are you also
      'planning to be able to build a uci from scratch with this code?  If
      'so, then you'll have to add those dummy tables yourself if needed. THJ
    End If
  End If
End Sub

