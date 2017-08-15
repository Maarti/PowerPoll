# BMA - 13/08/17

# Classes
Add-Type -Language CSharp @"
public class Votes{    
    public string Restaurant;
    public int Total;
    public System.DateTime TimeStamp;
}
"@;


# Identification
[xml]$xmlUsers = Get-Content -Path ".\users.xml"
$userId = $env:UserName
$currentuser = $xmlUsers.GetElementById($userId)
if (!$currentuser) {
    Write-Host "$($userId) n'est pas connu.`nAjoutez-le dans users.xml"
    exit
}
Write-Host "Bonjour $($currentuser.prenom), où mange-t-on aujourd'hui ?"


# Initialization
$today = Get-Date -UFormat "%Y/%m/%d"
$fileRestau = Get-Item -Path '.\restaurants.xml'
$xmlRestau = [xml](Get-Content $fileRestau)
#[xml]$xmlRestau = Get-Content -Path ".\restaurants.xml"
$objs = @()
$restaurants = $xmlRestau.SelectNodes("restaurants/restaurant")
foreach ($r in $restaurants) {
    $r.name
    if($r.votes.date -ne $today){
        "remove votes"
         $r.RemoveChild($r.votes)
    }
    $obj = new-object psobject -prop @{ID=$r.id;NAME=$r.name}
    $objs += $obj

}
$objs.NAME
$xmlRestau.Save($fileRestau)

<#
# Vote
$idRestau = "1";
$rFile = Get-Item -Path '.\restaurants.xml'
$xml = [xml](Get-Content $rFile)
$restauNode = ($xml.restaurants.restaurant|where {$_.id -eq $idRestau})
#
$votes = $restauNode.SelectSingleNode("votes")


# If there already are <votes>
if($votes){
    $votesDate = $votes.GetAttribute("date")
    if($votesDate -ne $today){
        "anciens votes"
        $restauNode.RemoveChild($restauNode.votes)
    }

    $target = ($restauNode.votes.vote|where {$_.user -eq $userId})
    if(!$target){
        $newVote = $xml.CreateElement("vote")
        $restauNode.votes.AppendChild($newVote)
        $newVote.SetAttribute(“user”,”bryan”)
    }else{
        'deja vote'
    }
}else{
    #<votes>
    'initialisation de la balise <votes>'
    $xmlVotes = $xml.CreateElement("votes")
    [void]$restauNode.AppendChild($xmlVotes) #cast to [void] to cancel the output written in the console
    $xmlVotes.SetAttribute(“date”,$date)
    #<vote>
    $newVote = $xml.CreateElement("vote")
    $node = $restauNode.SelectSingleNode("votes").AppendChild($newVote)    
    $newVote.SetAttribute(“user”,”bryan”)
    }
    
$xml.Save($rFile)



# Print Votes
<#$votes = New-Object Votes
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
   
Write-Host (@($votes,$votes2) | Format-Table | Out-String)#>
