using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using My.Function.Models;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Linq;

namespace My.Function
{
  public static class HttpExampleService
  {
    [FunctionName("newsitem")]
    public static async Task<IActionResult> Post(
      [CosmosDB(databaseName: "lfs-cosmos-20210831", collectionName: "my-container", ConnectionStringSetting = "CosmosDbConnectionString")] IAsyncCollector<dynamic> documentsOut,
      [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = null)] HttpRequest req,
      ILogger log)
    {
      log.LogInformation("Request received.");

      string name = req.Query["name"];

      string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
      dynamic data = JsonConvert.DeserializeObject(requestBody);
      name = name ?? data?.name;

      string responseMessage = string.IsNullOrEmpty(name)
          ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."
          : $"Hello, {name}. This HTTP triggered function executed successfully.";

      if (!string.IsNullOrEmpty(name))
      {
        await documentsOut.AddAsync(new
        {
          id = System.Guid.NewGuid().ToString(),
          name = name
        });
      }

      return new OkObjectResult(responseMessage);
    }

    [FunctionName("news")]
    public static async Task<IActionResult> Get(
      [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "news/{id}")] HttpRequest req,
      [CosmosDB(databaseName: "lfs-cosmos-20210831", 
                collectionName: "my-container", 
                ConnectionStringSetting = "CosmosDbConnectionString", 
                SqlQuery = "SELECT * FROM c WHERE c.name = {id}"                
                )] IEnumerable<Name> nameItem,
      ILogger log,
      string id)
    {
      log.LogInformation($"Triggered with {id}");

      if (!nameItem.Any())
      {
        return new NotFoundResult();
      }

      return new OkObjectResult($"Congrats! You entered something that seems to exist. You called this with {id}, by the by.");
    }
  }
}