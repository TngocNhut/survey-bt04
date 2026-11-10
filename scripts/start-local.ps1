param(
    [string]$TomcatHome = (Join-Path $PSScriptRoot '../../.reference/runtime/apache-tomcat-9.0.123')
)
$ErrorActionPreference = 'Stop'
$taskProject = Split-Path $PSScriptRoot -Parent
$taskEnvFile = Join-Path $taskProject '.runtime/local-env.ps1'
if (Test-Path -LiteralPath $taskEnvFile) { . $taskEnvFile }
foreach ($taskKey in @('DB_HOST', 'DB_NAME', 'DB_USER', 'DB_PASSWORD')) {
    if (-not [Environment]::GetEnvironmentVariable($taskKey)) {
        throw "Set environment variable $taskKey before starting Tomcat. See .env.example."
    }
}
$taskTomcat = (Resolve-Path -LiteralPath $TomcatHome).Path
Push-Location $taskProject
try {
    & mvn -B -ntp package
    if ($LASTEXITCODE -ne 0) { throw 'Maven build failed.' }
    Copy-Item -LiteralPath 'target/ch04survey.war' -Destination (Join-Path $taskTomcat 'webapps/ch04survey.war')
    $env:CATALINA_HOME = $taskTomcat
    # Short socket path avoids the Windows/JDK 25 temporary-path issue.
    $env:CATALINA_OPTS = "$env:CATALINA_OPTS -Djdk.net.unixdomain.tmpdir=C:/Windows/Temp"
    & (Join-Path $taskTomcat 'bin/catalina.bat') run
} finally {
    Pop-Location
}
