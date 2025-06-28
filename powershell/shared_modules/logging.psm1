param(
    [parameter(Position=0,Mandatory=$true)][string]$LogFile,
    [parameter(Position=1,Mandatory=$false)][int]$MaxLogLines=10000  
)

# Initialize
If( -not (Test-Path -Path "$($ScriptPath.Directory.FullName)/$($LogFile)" -PathType Leaf) ){
    New-Item -Path "$($ScriptPath.Directory.FullName)/$($LogFile)" -Force
}

function LogInfo {
    param(
        [string] $Message
    )
    (get-date -format "yyyy-MM-dd HH:mm:ss ") + "INFO $Message" >> "$($ScriptPath.Directory.FullName)/$($LogFile)"
}

function LogError {
    param(
        [string] $Message
    )
    (get-date -format "yyyy-MM-dd HH:mm:ss ") + "ERROR $Message" >> "$($ScriptPath.Directory.FullName)/$($LogFile)"
}

function LogWarning {
    param(
        [string] $Message
    )
    (get-date -format "yyyy-MM-dd HH:mm:ss ") + "WARNING $Message" >> "$($ScriptPath.Directory.FullName)/$($LogFile)"
}

function LogException {
    param(
        [system.object] $ErrorRecord,
        [string] $Message
    )
    LogError "Line $($ErrorRecord.InvocationInfo.ScriptLineNumber). $($ErrorRecord.Exception.Message). $Message"
}

function ShrinkLog {
    $Tail = Get-content -Tail $MaxLogLines -Path "$($ScriptPath.Directory.FullName)/$($LogFile)"
    $Tail > "$($ScriptPath.Directory.FullName)/$($LogFile)" 
}