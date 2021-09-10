Requirements:

 - choco install azure-functions-core-tools-3 --params "'/x64'"
If you aren't running the x64 version of Visual Studio Code, no need to pass the parameter. It will default to x86.
https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-cosmosdb
 - dotnet add package Microsoft.Azure.WebJobs.Extensions.CosmosDB

