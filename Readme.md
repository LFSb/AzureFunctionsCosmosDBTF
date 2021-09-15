Requirements:

 - choco install azure-functions-core-tools-3 --params "'/x64'"
If you aren't running the x64 version of Visual Studio Code, no need to pass the parameter. It will default to x86.
https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-cosmosdb
 - dotnet add package Microsoft.Azure.WebJobs.Extensions.CosmosDB: If you want to create your own project. It is included in this solution.
 - Terraform: https://www.terraform.io/downloads.html
 - Azure CLI: https://docs.microsoft.com/en-us/cli/azure/
 	-Make sure to run AZ login before continuing.

Make sure to include the Terraform binary somewhere that's already in your Path environment variable, as it is required to automatically deploy it to Azure.

After this, run the Terraform Init task before publishing and deploying to make sure Terraform has installed all the necessary plugins.

Running the "Clean, Publish and Deploy" task in Visual Studio Code will:
1. Ensure the existance of a `publish/` directory at the root of the workspace. It is include in the .gitignore to avoid committing publish results.
2. Clean, and then Publish the Azure Functions app defined in the `src/` folder to said `publish/` directory created by the previous step.
3. Terraform apply will be then executed in the `infra/` folder. The terminal will display the output generated from the Terraform Apply command, detailing what is either going to be changed or created. After confirming, Terraform will go to work.

The contents of the `publish/` will be zipped up, and uploaded to an Azure Storage Blob. This Azure Storage Blob will exist in a newly created Azure Resource Group, that will also hold the CosmoDB account and database that is connected to the Azure Functions application.

Terraform will then define an SAS to the files in said Storage Blob, which is then passed along to the actual Azure Function App. The Azure Function app is set up to run itself from the pacakge which is defined and shared with the Azure Function App using the SAS, ensuring that with each deploy, the latest version of the application will be used to refresh the application.

You can use the Postman Collection/Environment included in the repository to test out the API.

After you're done, run the "Destroy (functions)" task in Visual Studio Code in order to remove all the created infrastructure and applications.

Testing:

If you want, you can also try to run the automated testing using TerraTest. For this you'll need to install and setup Go.

Once you have everything set up, run the TerraTest task, and TerraTest will automatically Terraform init, apply, await the creation of the environment, and use the url of the created Azure Functions API and do two test calls to make sure everything is up and running before destroying the environment again. 

Keep in mind that there's a 60m timeout on this test, as destroying the azurerm_cosmosdb_account.acc takes 15-25 minutes (much to my annoyance).