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
using System;

namespace My.Function
{
  public static class Main
  {
    [FunctionName("PostNewsItem")]
    public static async Task<IActionResult> Post(
      [CosmosDB(databaseName: "Website", collectionName: "News", ConnectionStringSetting = "CosmosDbConnectionString")] IAsyncCollector<dynamic> documentsOut,
      [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "newsitem")] HttpRequest req,
      ILogger log)
    {
      log.LogInformation("Request received.");

      string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
      var data = JsonConvert.DeserializeObject<News>(requestBody);
      
      string responseMessage = data == null
          ? "This HTTP triggered function executed successfully. Pass a valid json to save it to the website. Example: { \"Title\": \"This is an interesting title\", \"Description\": \"This is a less interesting description\"}"
          : $"Your article with title '{data.Title}' was saved successfully.";

      if (data != null)
      {
        data.Date = System.DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff");
        await documentsOut.AddAsync(data);
      }

      return new OkObjectResult(responseMessage);
    }

    [FunctionName("GetNewsByTitle")]
    public static async Task<IActionResult> GetByTitle(
      [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "news/{title}")] HttpRequest req,
      [CosmosDB(databaseName: "Website", 
                collectionName: "News", 
                ConnectionStringSetting = "CosmosDbConnectionString", 
                SqlQuery = "SELECT * FROM c WHERE c.Title = {title}"                
                )] IEnumerable<News> newsItems,
      ILogger log,
      string title)
    {
      log.LogInformation($"Triggered with {title}");

      if (!newsItems.Any())
      {
        return new NotFoundResult();
      }

      var firstNewsItem = newsItems.OrderBy(x => DateTime.Parse(x.Date)).First();

      return new OkObjectResult($@"Congrats! You entered something that seems to exist ({newsItems.Count()} times). 
You called this with '{title}', by the by. 
-By date, the first result is from '{firstNewsItem.Date}'.
-Its description is: '{firstNewsItem.Description}'");
    }

    [FunctionName("GetAllNews")]
    public static async Task<IActionResult> GetAll(
      [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "news/")] HttpRequest req,
      [CosmosDB(databaseName: "Website", 
                collectionName: "News", 
                ConnectionStringSetting = "CosmosDbConnectionString", 
                SqlQuery = "SELECT * FROM c"
                )] IEnumerable<News> newsItems,
      ILogger log)
      {
        log.LogInformation($"Triggered HTTP Function.");

        return new ObjectResult(newsItems);
      }
  }
}