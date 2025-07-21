# # Self-elevate the script if required
# if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
#   if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
#     $CommandLine = "-NoExit -File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
#     Start-Process -Wait -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
#     Exit
#   }
# }

# setx PathExt "%PathExt%;.sh" -m

# set PATHEXT=.sh;%PATHEXT%
# assoc .sh=ShellScript
# ftype ShellScript=bash.exe %1 %*

# https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/creating-profiles?view=powershell-7.5#how-to-create-your-personal-profile
if (!(Test-Path -Path $PROFILE)) {
  New-Item -ItemType File -Path $PROFILE -Force
}

# $symlinkParams = @{
#   Path = $PROFILE
#   Value = "$gitRepoPath/PowerShell/Microsoft.PowerShell_profile.ps1"
#   ItemType = 'SymbolicLink'
#   Force = $true
# }
# New-Item @symlinkParams
