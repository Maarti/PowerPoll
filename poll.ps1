# BMA - 13/08/17

# Classes
Add-Type -Language CSharp @"
public class Restaurant{
    public int id;
    public string name;
    public int nbVotes;
    public string[] voters;
}
"@;
 
 
# Intro
Write-Host "                 " -BackgroundColor White
For($i=0; $i -le 3; $i++){
    Write-Host " " -BackgroundColor White -NoNewline
    Write-Host "               " -BackgroundColor Red -NoNewline
    Write-Host " " -BackgroundColor White}
Write-Host " " -BackgroundColor White -NoNewline
Write-Host "  "  -BackgroundColor Red -NoNewline
Write-Host " Power     " -ForegroundColor Gray  -BackgroundColor White -NoNewline
Write-Host "  "  -BackgroundColor Red -NoNewline
Write-Host " " -BackgroundColor White
Write-Host " " -BackgroundColor White -NoNewline
Write-Host "  "  -BackgroundColor Black -NoNewline
Write-Host "      Poll "  -ForegroundColor Gray -BackgroundColor White -NoNewline
Write-Host "  "  -BackgroundColor Black -NoNewline
Write-Host " " -BackgroundColor White
For($i=0; $i -le 3; $i++){
    Write-Host " " -BackgroundColor White -NoNewline
    Write-Host "               " -BackgroundColor Black -NoNewline
    Write-Host " " -BackgroundColor White}
Write-Host "  On mange où ?  " -BackgroundColor White  -ForegroundColor Black
 
 
# Identification
Set-Location -Path C:\Users\bryan\workspace\PowerPoll
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
$lstRestau = @()
$lstRestaurants = $xmlRestau.SelectNodes("restaurants/restaurant")
foreach ($r in $lstRestaurants) {
    $r.name
    $nbVotes = 0
    if($r.votes){
        if($r.votes.date -ne $today){
            "remove votes"
            $r.RemoveChild($r.votes)
        }else{
            $lstVotes = $r.votes
            $lstVoters
            $lstVoters = @()
            foreach ($vote in $lstVotes) {
               $nbVotes++
                $lstVoters += $vote.user
            }
        }
    }
   
    $obj = New-Object Restaurant -prop @{id=$r.id;name=$r.name;nbVotes=$nbVotes;voters=$lstVoters}
    $lstRestau += $obj
    $obj.nbVotes
    $obj.voters
}
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