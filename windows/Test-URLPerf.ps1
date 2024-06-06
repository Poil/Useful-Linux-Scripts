 Param(
   [string]$url
 )

 add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# track execution time:
$timeTaken = Measure-Command -Expression {
  $site = Invoke-WebRequest -Uri $url
}

$milliseconds = $timeTaken.TotalMilliseconds

$milliseconds = [Math]::Round($milliseconds, 1)

"This took $milliseconds ms to execute"
