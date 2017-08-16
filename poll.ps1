# @version(1.0.0)
# @since(13/08/17)
# @author(MARTINET Bryan - https://maarti.net)

# Classes
Add-Type -Language CSharp @"
public class Restaurant{
    public int id;
    public string name;
    public int time;
    public int nbVotes;
    public string[] voters;
}
"@;


# Functions
function Get-User {
    Param([string]$id)
    [xml]$xmlUsers = Get-Content -Path ".\dat\users.xml"
    $user = $xmlUsers.GetElementById($id)
    if ($user){
        return $user
    }else{
        return $null
    }
}
 
 
# Intro
Write-Host "                 " -BackgroundColor White
For($i=0; $i -le 2; $i++){
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
For($i=0; $i -le 2; $i++){
    Write-Host " " -BackgroundColor White -NoNewline
    Write-Host "               " -BackgroundColor Black -NoNewline
    Write-Host " " -BackgroundColor White}
Write-Host "  On mange où ?  `n" -BackgroundColor White  -ForegroundColor Black
 
 
# Identification
Set-Location -Path C:\Users\bryan\workspace\PowerPoll
$userId = $env:UserName
$currentuser = Get-User -id $userId
if (!$currentuser) {
    Write-Host "L'utilisateur $($userId) n'est pas connu.`nAjoutez-le dans users.xml"
    exit
}
Write-Host "Bonjour $($currentuser.prenom), où mange-t-on aujourd'hui ?`n"
 
 
# Initialization
$today = Get-Date -UFormat "%Y/%m/%d"
$fileRestau = Get-Item -Path '.\dat\restaurants.xml'
$xmlRestau = [xml](Get-Content $fileRestau)
[System.Collections.ArrayList]$lstRestau = @()
$lstRestaurantsNodes = $xmlRestau.SelectNodes("restaurants/restaurant")
foreach ($r in $lstRestaurantsNodes) {
    [System.Collections.ArrayList]$lstVoters = @()
    if($r.votes){
        if($r.votes.date -ne $today){
            $r.RemoveChild($r.votes)
        }else{
            $lstVotes = $r.votes.SelectNodes("vote")            
            foreach ($vote in $lstVotes) {
               $voter = Get-User -id $vote.user
               $null = $lstVoters.Add($voter.prenom)
            }
        }
    }
    $nbVotes = $lstVoters.Count
    $obj = New-Object Restaurant -prop @{id=$r.id;name=$r.name;time=$r.time;nbVotes=$nbVotes;voters=$lstVoters}
    $null = $lstRestau.Add($obj)
    $null = $lstVoters.Clear
}
$xmlRestau.Save($fileRestau)
$lstRestau = $lstRestau | Sort-Object -Property @{Expression = {$_.nbVotes}; Ascending = $false}, id


# Voting Loop
Do {
    # Display Infos
    foreach($restau in $lstRestau){
        Write-Host $restau.id.toString().PadLeft(2, ' ') -ForegroundColor Red -BackgroundColor Black -NoNewline
        if($restau.id -eq 0){
            Write-Host " $($restau.name.PadRight(17, ' ')) : " -ForegroundColor DarkGray -NoNewline
            Write-Host $restau.voters -ForegroundColor DarkGray
        }else{
            Write-Host " $($restau.name.PadRight(12, ' '))" -NoNewline
            Write-Host "$($restau.time.toString().PadLeft(2, ' '))min : " -ForegroundColor DarkGray -NoNewline
            Write-Host $restau.voters -ForegroundColor Yellow
        }
    
    }
    Write-Host "`nSaisissez le " -NoNewline
    Write-Host "numéro" -ForegroundColor Red -BackgroundColor Black -NoNewline
    Write-Host " d'un restaurant pour voter ou tapez " -NoNewline
    Write-Host "q" -ForegroundColor Red -BackgroundColor Black -NoNewline
    Write-Host " pour quitter : " -NoNewline
    $input = Read-Host


    # Vote
    <#$xmlRestau = [xml](Get-Content $fileRestau)
    $restauNode = ($xmlRestau.restaurants.restaurant|where {$_.id -eq $input})
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
        }#>

}while(@("q","Q","quit") -notcontains $input)
$xmlRestau.Save($fileRestau)
exit