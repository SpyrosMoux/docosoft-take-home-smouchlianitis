
using Microsoft.AspNetCore.Mvc;

/// <summary>
/// API controller that handles requests related to counting operations
/// </summary>
[ApiController]
[Route("[controller]")]  // Routes requests to this controller using the controller name as route prefix
public class HealthController : ControllerBase
{
  public HealthController()
  {
  }

  [HttpGet]  // Maps this method to HTTP GET requests
  public IActionResult Get()
  {
    return Ok("I'm Alive!");
  }
}
