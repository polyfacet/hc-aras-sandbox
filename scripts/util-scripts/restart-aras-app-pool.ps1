# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
     $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
     Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
     Write-Host -ForegroundColor Yellow  "Press Enter when the elevated script has restarted the appliction pool!"
     Read-Host
     Exit
    }
}

$applicationPoolName = "Aras Innovator AppPool ASP.NET Core"
Write-Host -ForegroundColor Cyan "Restarting application pool: $applicationPoolName"   
Restart-WebAppPool -Name $applicationPoolName