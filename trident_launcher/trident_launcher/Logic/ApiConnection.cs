using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net.Http;
using System.Security.Cryptography.X509Certificates;
using trident_interfaces;
namespace tridentApi
{
    internal class ApiConnection
    {
        private readonly HttpClient _httpClient;
        private string _apiKey;

        private List<Games> games;

        public List<Games> getGames()
        {
            games = new List<Games> {
            new Games { Name = "Roblox", Isbloked = true, durationGame = new DateTime(2024, 5, 2, 10, 0, 0)},
            new Games { Name = "BlackDesert", Isbloked = false, durationGame = new DateTime(2024, 5, 2, 10, 0, 0)},
        };
            return games;
        }

        public string sendTimeLoggedInGame(string game)
        {
            return "";
        }

        public void loginUser(string username, string password)
        {

        }
        public void verifyGameBlocked(string game)
        {

        }

    }
}


