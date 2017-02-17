'
'e-mail: MBochar0ff @ gmail com 
' 09.11.2015


Dim objXmlHttpMain , URL

iNumberOfArguments = WScript.Arguments.Count
Set colNamedArguments = WScript.Arguments.Named

' Check argument to parse sript
If Not colNamedArguments.Exists("CN") Then
  CN = "---"
  Wscript.Echo "Usage: /CN:%CN "
Else
  CN = colNamedArguments.Item("CN")  
End If 

If Not colNamedArguments.Exists("NAME") Then
  WScript.Echo "Usage: /NAME:%FULL_NAME"
  FULL_NAME = "---"
Else
  FULL_NAME = colNamedArguments.Item("NAME")
End If 

If Not colNamedArguments.Exists("CONTEXT") Then
  WScript.Echo "Usage: /CONTEXT:%LOGIN_CONTEXT"
  LOGIN_CONTEXT = "---"
Else 
  LOGIN_CONTEXT = colNamedArguments.Item("CONTEXT")  
End If 
  

strComputer = "."
Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")


' SYSTEM INFO
Set colSettings = objWMIService.ExecQuery _
    ("Select * from Win32_ComputerSystem")

strJSONToSend = "{" 

For Each objComputer in colSettings 
    strJSONToSend =  strJSONToSend +" ""Novell CN"" : """ & CN & ""","
        strJSONToSend =  strJSONToSend +" ""Novell FullName"" : """ & FULL_NAME & ""","
        strJSONToSend =  strJSONToSend +" ""LOGIN_CONTEXT"" : """ & LOGIN_CONTEXT & ""","

    strJSONToSend =  strJSONToSend +" ""System Name"" : """ & objComputer.Name & ""","
    strJSONToSend =  strJSONToSend +" ""System Manufacturer"" : """ & objComputer.Manufacturer  & ""","
    strJSONToSend =  strJSONToSend +" ""System Model"" : """ & objComputer.Model  & ""","
    strJSONToSend =  strJSONToSend +" ""Time Zone"" : """ & objComputer.CurrentTimeZone  & ""","
    strJSONToSend =  strJSONToSend +" ""Total Physical Memory"" : """ & objComputer.TotalPhysicalMemory  & ""","
Next

Set colSettings = objWMIService.ExecQuery _
    ("Select * from Win32_Processor")

For Each objProcessor in colSettings 
    strJSONToSend =  strJSONToSend +" ""System Type"" : """ & objProcessor.Architecture & """," 
    strJSONToSend =  strJSONToSend +" ""Processor"" : """ & objProcessor.Description & ""","
Next

' Operation System information 
Set colSettings = objWMIService.ExecQuery _
    ("Select * from Win32_OperatingSystem")

For Each os in colSettings 
    strJSONToSend =  strJSONToSend +" ""OS Name"" : """ & os.Caption & ""","
    strJSONToSend =  strJSONToSend +" ""Version"" : """ & os.Version & ""","
    strJSONToSend =  strJSONToSend +" ""Service Pack"" : """ &  os.ServicePackMajorVersion  & "." & os.ServicePackMinorVersion  & ""","
    strJSONToSend =  strJSONToSend +" ""OS Manufacturer"" : """ & os.Manufacturer & ""","
        strJSONToSend =  strJSONToSend +" ""Serial Number"" : """ & os.SerialNumber & ""","
    ' Необходимо предусмотреть экранирование косых
        ' strJSONToSend =  strJSONToSend +" ""Windows Directory"": """ & os.WindowsDirectory & ""","
    strJSONToSend =  strJSONToSend +" ""Locale"" : """ & os.Locale & ""","
    strJSONToSend =  strJSONToSend +" ""Available Physical Memory"" : """ & os.FreePhysicalMemory & ""","
    strJSONToSend =  strJSONToSend +" ""Total Virtual Memory"" : """ &  os.TotalVirtualMemorySize & ""","
    strJSONToSend =  strJSONToSend +" ""Available Virtual Memory"" : """ & os.FreeVirtualMemory & ""","
    strJSONToSend =  strJSONToSend +" ""Size stored in paging files"" : """ &  os.SizeStoredInPagingFiles & ""","
        strJSONToSend =  strJSONToSend +" ""Registered User"" : """ & os.RegisteredUser & ""","
Next

'---------  User info session
Set objNetwork = CreateObject("Wscript.Network")
strJSONToSend =  strJSONToSend +" ""Current User"" : """ & objNetwork.UserName & ""","


Set colSessions = objWMIService.ExecQuery _ 
    ("Select * from Win32_LogonSession Where LogonType = 10") 


If colSessions.Count = 0 Then 
   strJSONToSend =  strJSONToSend +" ""Login"" : ""No interactive users found"", "  
Else 
'   WScript.Echo "RDP Sessions:"
   strJSONToSend =  strJSONToSend +" ""Login"" : ""RDP found"", "  
   For Each objSession in colSessions 

     Set colList = objWMIService.ExecQuery("Associators of " _ 
         & "{Win32_LogonSession.LogonId=" & objSession.LogonId & "} " _ 
         & "Where AssocClass=Win32_LoggedOnUser Role=Dependent" ) 
     For Each objItem in colList 
 '      WScript.Echo "Username: " & objItem.Name & " FullName: " & objItem.FullName 
     Next 
   Next 
End If 


strJSONToSend =  strJSONToSend +" ""END"": ""END"" "
strJSONToSend =  strJSONToSend + " }"

'strJSONToSend =  strJSONToSend +"  strJSONToSend

URL="http://[%DRUPAL-SITE%]/it-connect/postin/" 
Set objXmlHttpMain = CreateObject("Msxml2.ServerXMLHTTP") 
'on error resume next 
objXmlHttpMain.open "POST",URL, False 
objXmlHttpMain.setRequestHeader "Authorization", "Bearer <api secret id>"
objXmlHttpMain.setRequestHeader "Content-Type", "application/json"


objXmlHttpMain.send strJSONToSend

set objJSONDoc = nothing 
set objResult = nothing
