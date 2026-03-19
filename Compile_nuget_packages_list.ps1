param($root, $projectlocation)

$SOLUTIONROOT = "BaseDirectory" #Base directory for the repository
[System.Collections.ArrayList]$packageslist = @();

Function ListAllPackages ($BaseDirectory)
{
    Write-Host "Starting Package List - This may take a few minutes ..."
    $PACKAGECONFIGS = Get-ChildItem -Recurse -Force $BaseDirectory -ErrorAction SilentlyContinue | 
        Where-Object { ($_.PSIsContainer -eq $false) -and  ( $_.Name -eq "packages.config")}
        
    ForEach($PACKAGECONFIG in $PACKAGECONFIGS)
        {
            $path = $PACKAGECONFIG.FullName
            
            $xml = [xml]$packages = Get-Content $path
            
                            foreach($package in $packages.packages.package)
                            {
                                if($package.developmentDependency -ne "true") {
                                     $entry = "<PackageReference Include=`"$($package.id)`" Version=`"$($package.version)`" Framework=`"$($package.targetFramework)`" />"
                                     $packageslist.Add($entry)
                                    
                                 }
                             }

        }
}

$projectlocation = "text output" #Output file

Function CreateProjectFile ($projectlocation)
{
    $uniqueList = $packageslist | Sort-Object  | Get-Unique

    $start = '<Project Sdk="Microsoft.NET.Sdk.Web">

      <PropertyGroup>
        <TargetFramework>net48</TargetFramework>
      </PropertyGroup>

      <ItemGroup>'

      $end = "</ItemGroup>

    </Project>"

$total = $start + $uniqueList + $end
$total | Out-File $projectlocation
    
}

ListAllPackages $SOLUTIONROOT
CreateProjectFile $projectlocation

Write-Host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

