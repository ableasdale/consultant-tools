If(!$args[0]){
Write-Host "---------------------------------------------------------------------------------------------------------------"
Write-Host "Please provide the path to your properties file as the first argument (e.g. .\recordloader.ps1 properties.props"
Write-Host "---------------------------------------------------------------------------------------------------------------"
} Else {
java -cp "jars\recordloader.jar;jars\marklogic-xcc-4.1.7.jar;jars\xpp3-1.1.4c.jar" com.marklogic.ps.RecordLoader $args[0]
}