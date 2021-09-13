Requirements:

 - choco install azure-functions-core-tools-3 --params "'/x64'"
If you aren't running the x64 version of Visual Studio Code, no need to pass the parameter. It will default to x86.
https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-cosmosdb
 - dotnet add package Microsoft.Azure.WebJobs.Extensions.CosmosDB: If you want to create your own project. It is included in this solution.
 - Terraform: https://www.terraform.io/downloads.html
 - Azure CLI: https://docs.microsoft.com/en-us/cli/azure/

Make sure to include the Terraform binary somewhere that's already in your Path environment variable, as it is required to automatically deploy it to Azure. Also, run Terraform Init before attempting to publish to install the necessary plugins.