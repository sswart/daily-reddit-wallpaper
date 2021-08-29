$CurrentLocation = $args[0]

function EnsureImagesFolderExists {
    $ImagesPath = GetImagesPath
    if ( -not (Test-Path $ImagesPath)){
        New-Item -ItemType Directory -Path $ImagesPath
    }
}

function GetImagesPath {
    $CurrentPath = $CurrentLocation
    "${CurrentPath}/images"
}

# By Jose Espitia
# https://www.joseespitia.com/2017/09/15/set-wallpaper-powershell-function/
Function Set-WallPaper($Image) {
<#
 
    .SYNOPSIS
    Applies a specified wallpaper to the current user's desktop
    
    .PARAMETER Image
    Provide the exact path to the image
  
    .EXAMPLE
    Set-WallPaper -Image "C:\Wallpaper\Default.jpg"
  
#>
  
Add-Type -TypeDefinition @" 
using System; 
using System.Runtime.InteropServices;
  
public class Params
{ 
    [DllImport("User32.dll",CharSet=CharSet.Unicode)] 
    public static extern int SystemParametersInfo (Int32 uAction, 
                                                   Int32 uParam, 
                                                   String lpvParam, 
                                                   Int32 fuWinIni);
}
"@ 
  
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
  
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent
  
    $ret = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
}

$SubRedditsSourceFile = "${CurrentLocation}/subreddits.txt"

EnsureImagesFolderExists

$SubReddit = @(Get-Content $SubRedditsSourceFile) | Get-Random

$Uri = "https://reddit.com/r/${SubReddit}/top/.json?limit=25&t=week"
$Response = Invoke-WebRequest -URI $Uri -UseBasicParsing

$ResponseBody = ConvertFrom-Json $Response.Content
foreach($Post in $ResponseBody.data.children)
{
    $ImageUrl = $Post.data.url
    if ($ImageUrl.EndsWith('.jpg') -or $ImageUrl.EndsWith('.png'))
    {
        $FileName = $ImageUrl.Split('/')[-1]
        $ImagesDirectory = GetImagesPath
        $ImagePath = "${ImagesDirectory}\${FileName}"
        Invoke-WebRequest $ImageUrl -OutFile $ImagePath -UseBasicParsing
        break
    }
}

if (-not ([string]::IsNullOrEmpty($ImagePath))){
    Set-WallPaper -Image $ImagePath
}

