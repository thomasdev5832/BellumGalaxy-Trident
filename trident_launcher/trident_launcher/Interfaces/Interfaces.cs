using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace trident_interfaces
{
    class LoginResponse
    {
        public string token { get; set; }
    }
    class Games
    {

        public string GameId { get; set; }
        public string Name { get; set; }
        public DateTime Released { get; set; }
        public TimeSpan? TimeLimit { get; set; }
        public string ProcessName { get; set; }
        public string DeveloperCompany { get; set; }
        public TimeSpan? TimePlayed { get; set; }
        public bool IsBlocked { get; set; }
        public string GameImageUrl { get; set; }
        public string GameAddress { get; set; }
        public string Id { get; set; }
        public DateTime CreatedAt { get; set; }
        public string PreviousOwner { get; set; }
        public string Receiver { get; set; }
        public int NftId { get; set; }

    }

    public class Order
    {
        public string gameId { get; set; }
        public string name { get; set; }
        public DateTime released { get; set; }
        public TimeSpan? timeLimit { get; set; }
        public string processName { get; set; }
        public string developerCompany { get; set; }
        public TimeSpan? timePlayed { get; set; }
        public bool isBlocked { get; set; }
        public string gameImageUrl { get; set; }
        public string gameAddress { get; set; }
        public string id { get; set; }
        public DateTime createdAt { get; set; }
        public string previousOwner { get; set; }
        public string receiver { get; set; }
        public int nftId { get; set; }
        // Adicione outros campos necessários de acordo com a resposta da API
    }



}

