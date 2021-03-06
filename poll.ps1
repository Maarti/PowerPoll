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
function Write-Instructions {
    Param([int]$line)
    $instructions = ("╔".PadRight(50, '═')+"╗"),
                 ("║ Instructions :".PadRight(50, ' ')+"║"),
                 ("║   * Entrez le numéro d'un restau pour voter".PadRight(50, ' ')+"║"),
                 ("║   * Vous pouvez voter pour plusieurs restau".PadRight(50, ' ')+"║"),
                 ("║   * Votez à nouveau sur le même restau pour".PadRight(50, ' ')+"║"),
                 ("║     annuler votre vote".PadRight(50, ' ')+"║"),
                 ("╚".PadRight(50, '═')+"╝")
    Write-Host "     " -NoNewline
    Write-Host $instructions[$line]  -ForegroundColor White
}
 
# Colors
cmd /c color 17
$host.ui.RawUI.ForegroundColor="White"
 
# Main Loop
Do{
 
    # Intro
    Write-Host "http://maarti.net" -BackgroundColor White -ForegroundColor Gray -NoNewline
    Write-Instructions -line 0
    For($i=0; $i -le 3; $i++){
        Write-Host " " -BackgroundColor White -NoNewline
        Write-Host "               " -BackgroundColor Red -NoNewline
        Write-Host " " -BackgroundColor White -NoNewLine
        Write-Instructions -line ($i+1)}
    Write-Host " " -BackgroundColor White -NoNewline
    Write-Host "  "  -BackgroundColor Red -NoNewline
    Write-Host " Power     " -ForegroundColor Gray  -BackgroundColor White -NoNewline
    Write-Host "  "  -BackgroundColor Red -NoNewline
    Write-Host " " -BackgroundColor White -NoNewline
    Write-Instructions -line 5
    Write-Host " " -BackgroundColor White -NoNewline
    Write-Host "  "  -BackgroundColor Black -NoNewline
    Write-Host "      Poll "  -ForegroundColor Gray -BackgroundColor White -NoNewline
    Write-Host "  "  -BackgroundColor Black -NoNewline
    Write-Host " " -BackgroundColor White -NoNewline
    Write-Instructions -line 6
    For($i=0; $i -le 3; $i++){
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
                $null = $r.RemoveChild($r.votes)
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
 
 
    # Display Infos
    foreach($restau in $lstRestau){
        Write-Host $restau.id.toString().PadLeft(2, ' ') -ForegroundColor Red -BackgroundColor Black -NoNewline
        if($restau.id -eq 0){
            Write-Host " $($restau.name.PadRight(17, ' ')) : " -ForegroundColor DarkGray -NoNewline
            Write-Host $restau.voters -ForegroundColor DarkGray
        }elseif($restau.id -eq 99){
            Write-Host " $($restau.name.PadRight(17, ' ')) : " -ForegroundColor Yellow -NoNewline
            if($restau.voters.Length -eq 0){
                Write-Host $($restau.voters) -ForegroundColor Yellow
            }elseif($restau.voters.Length -eq 1){
                Write-Host "$($restau.voters) vous suivra où que vous alliez !" -ForegroundColor Yellow
            }else{
                Write-Host "$($restau.voters) vous suivront où que vous alliez !" -ForegroundColor Yellow
            }
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
    Write-Host ""
 
    # Vote
    $xmlRestau = [xml](Get-Content $fileRestau)
    $restauNode = $xmlRestau | Select-XML -XPath "//restaurants/restaurant[@id='$($input)']"
    $restauNode = $restauNode.Node
    if($restauNode){
        $votes = $restauNode.SelectSingleNode("votes")
        # If there already are <votes>
        if($votes){
            $target = ($restauNode.votes.vote|where {$_.user -eq $userId})
            if(!$target){
                $newVote = $xmlRestau.CreateElement("vote")
                [void]$restauNode.votes.AppendChild($newVote)
                $newVote.SetAttribute(“user”,$userId)
            }else{
                [void]$restauNode.votes.RemoveChild($target)
            }
        }else{
            #<votes>
            $xmlVotes = $xmlRestau.CreateElement("votes")
            [void]$restauNode.AppendChild($xmlVotes) #cast to [void] to cancel the output written in the console
            $xmlVotes.SetAttribute(“date”,$today)
            #<vote>
            $newVote = $xmlRestau.CreateElement("vote")
            [void]$restauNode.SelectSingleNode("votes").AppendChild($newVote) 
            $newVote.SetAttribute(“user”,$userId)
        }
    }
    cls
    $xmlRestau.Save($fileRestau)
}while(@("q","Q","quit") -notcontains $input)
$xmlRestau.Save($fileRestau)
exit