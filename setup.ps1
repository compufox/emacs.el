# Since windows won't let us make symlinks unless we're running
#  as admin, we check here and then restart if needed
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process -FilePath PowerShell.exe -ArgumentList $myinvocation.mycommand.definition -Verb runAs
    Break
}

If (Test-Path -Path $env:appdata\.emacs -PathType Leaf)
{
    mv $env:appdata\.emacs $env:appdata\.emacs.bak
}

If (Test-Path -Path $env:appdata\.emacs.d -PathType Container)
{
    mv $env:appdata\.emacs.d $env:appdata\.emacs.d.bak
}

echo "Making link..."
New-Item -ItemType SymbolicLink -Path $env:appdata\.emacs -Target $PSScriptRoot\emacs.el

echo "Installing fonts..."
$fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
foreach ($file in gci $PSScriptRoot\fonts\*.otf)
{
    $fileName = $file.Name
    if (-not(Test-Path -Path "C:\Windows\fonts\$fileName" )) {
        echo "installing $fileName"
        dir $file | %{ $fonts.CopyHere($_.fullname) }
    }
}
