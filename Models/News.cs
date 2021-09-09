namespace My.Function.Models
{
  public class News
  {
    public News()
    {
      Date = Date == null 
        ? System.DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff") 
        : Date;
    }

    public string Date { get; set; }

    public string Title { get; set; }

    public string Description { get; set; }
  }
}