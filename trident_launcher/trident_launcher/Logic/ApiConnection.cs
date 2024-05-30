using System.Text;
using System.Net.Http.Headers;
using System.Text.Json;
using trident_interfaces;
namespace tridentApi
{   

    public class ApiClient
    {
        private static readonly HttpClient client = new HttpClient();
        public string token;

        public async Task<string> LoginAsync(string email, string password)
        {
            var loginUrl = "http://64.227.122.74:3000/auth/login";
            var payload = new
            {
                email = email,
                password = password
            };

            var jsonPayload = JsonSerializer.Serialize(payload);
            var content = new StringContent(jsonPayload, Encoding.UTF8, "application/json");

            var response = await client.PostAsync(loginUrl, content);
            if (response.IsSuccessStatusCode)
            {
                var responseBody = await response.Content.ReadAsStringAsync();
                var loginResponse = JsonSerializer.Deserialize<LoginResponse>(responseBody);
                token = loginResponse.token;
                return token;
            }

            return null;
        }

        public async Task<List<Order>> GetUserOrdersAsync(string token)
        {
            var ordersUrl = $"http://64.227.122.74:3000/order/user/all";

            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
            var response = await client.GetAsync(ordersUrl);

            if (response.IsSuccessStatusCode)
            {
                var responseBody = await response.Content.ReadAsStringAsync();
                var orders = JsonSerializer.Deserialize<List<Order>>(responseBody);
                return orders;
            }

            return null;
        }

        

       
    }
  
}


