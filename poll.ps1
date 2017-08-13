# Classes
Add-Type -Language CSharp @"
public class Votes{    
    public string Restaurant;
    public int Total;
    public System.DateTime TimeStamp;
}
"@;


# User
[xml]$users = Get-Content -Path ".\users.xml"
$userid = $env:UserName
$currentuser = $users.GetElementById($userid)

# Print Votes
$votes = New-Object Votes
$votes.Restaurant = "Entracte"
$votes.Timestamp = Get-Date
$votes.Total = 15
$votes | Add-Member -type NoteProperty -name VME -value "1"
$votes | Add-Member -type NoteProperty -name BMA -value "0"

$votes2 = New-Object Votes
$votes2.Restaurant = "Volpone"
$votes2.Timestamp = Get-Date
$votes2.Total = 1
$votes2 | Add-Member -type NoteProperty -name BMA -value "1"
   
Write-Host (@($votes,$votes2) | Format-Table | Out-String)