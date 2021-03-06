﻿$exePath = ($Env:BUILD_REPOSITORY_LOCALPATH + "\mdoc\mdoc.exe")
Write-Output $exePath

$azureLibs = ($Env:BUILD_REPOSITORY_LOCALPATH + "\nue-out")
Write-Output $azureLibs

$outputFolder = ($Env:BUILD_REPOSITORY_LOCALPATH + "\mdoc-output")
Write-Output $outputFolder

$individualPackages = Get-ChildItem -Path $azureLibs -Directory

Write-Output "Current packages:"
foreach($package in $individualPackages)
{
    if (-Not ($package.Name -Eq 'dependencies')){
        # Write-Output $package.FullName
        New-Item $outputFolder\$package -Type Directory -force

        $dlls = Get-ChildItem -Path ($package.FullName + "\*") -Include *.dll,*.exe
        foreach($dll in $dlls)
        {
            # Write-Output $dll.FullName
            $reflectionTarget = [io.path]::GetFileNameWithoutExtension($dll.FullName)

            $docPath = ($package.FullName + "\" + $reflectionTarget + ".xml")
            $documentationXmlExists = Test-Path $docPath

            $resolutionPath = ($azureLibs + "\dependencies\" + $package.Name)
            Write-Output ("Resolving from " + $resolutionPath)

            if ($documentationXmlExists)
            {
                Write-Output "Found XML documentation file!"
                Write-Output $dll.FullName
                & $exePath update -i $docPath -o ($outputFolder) $dll.FullName -L $resolutionPath --use-docid
            }
            else
            {
                Write-Output "There is no XML documentation file."
                Write-Output $dll.FullName
                & $exePath update -o ($outputFolder) $dll.FullName -L $resolutionPath --use-docid
            }
        }
    }
}
