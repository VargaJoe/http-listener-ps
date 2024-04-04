function Show-ComicsController($requestObject) {
    Write-Output "$($requestObject.Settings.comicsPaths[0].pathString)"
    $rootPath = $($requestObject.Settings.comicsPaths[0].pathString)
    
    $model = Get-ChildItem -Path $rootPath -Recurse
    Show-View $requestObject "category" $model
}
