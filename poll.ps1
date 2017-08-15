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
[xml]$users = Get-Content -Path ".\users.xml"
$userId = $env:UserName
$currentuser = $users.GetElementById($userId)
if (!$currentuser) {
    Write-Host "$($userId) n'est pas connu.`nAjoutez-le dans users.xml"
    exit
}
Write-Host "Bonjour $($currentuser.prenom), où mange-t-on aujourd'hui ?"

# Vote
$idRestau = "1";
$rFile = Get-Item -Path '.\restaurants.xml'
$xml = [xml](Get-Content $rFile)
$restauNode = ($xml.restaurants.restaurant|where {$_.id -eq $idRestau})
#$restauNode.RemoveChild($restauNode.votes)
$votesExists = $restauNode.votes

# If there already are <votes>
if($votesExists){
    $target = ($restauNode.votes.vote|where {$_.user -eq $userId})
    if(!$target){
    $newVote = $xml.CreateElement("vote")
    $restauNode.votes.AppendChild($newVote)
    $newVote.SetAttribute(“user”,”bryan”)
    }else{
        echo 'deja vote'
    }
}else{
    echo 'initialisation de la balise <votes>'
    #<votes>
    $date = Get-Date -UFormat "%Y/%m/%d"
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
